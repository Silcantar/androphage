import typing
from os import PathLike

import build123d as bd

from common import *
import layout
from parameters import *

# Passed to __main__
test_layout = True

class Androphage(bd.BasePartObject):
    """Build a model of an Androphage keyboard based on a parameter file."""

    def __init__(
        self,
        build: bool = True,
        parameter_path: PathLike = "cad/androphage.yaml",
        test_layout: bool = False,
        main_half: Half = Half.LEFT,
        **kwargs
    ):
        self.main_half = main_half
        self.parameters = self.import_parameters(parameter_path)
        self.column_locations = layout.build_column_locations(self.parameters)
        if build:
            part = self._build(test_layout)
            super().__init__(part=part, **kwargs)

    def import_parameters(self, parameter_path: PathLike) -> Parameters:
        """Load parameters from a YAML file."""
        return self._set_derived_parameters(
            Parameters.from_yaml_file(parameter_path)
        )

    def _build(self, test_layout) -> bd.Part:
        from components.battery import Battery
        from components.plate import Plate, PlateType
        from components.frame import Frame
        from components.center_block import CenterBlock
        p = self.parameters
        components: list[bd.Part] = []
        if test_layout:
            components.append(self.test_layout())
        # Top Plate
        components.append(
            Plate(
                parameters=self.parameters,
                plate_type=PlateType.TOP
            ).move(bd.Pos(Z=p.Plates.Top.z_pos))
        )
        # Frame
        components.append(Frame(parameters=self.parameters))
        # Center Block
        components.append(
            CenterBlock(
                parameters=self.parameters
            ).move(bd.Pos(0, 2*p.Frame.lip_depth, p.Plates.Top.z_pos))
        )
        components.append(
            Plate(
                parameters=self.parameters,
                plate_type=PlateType.SWITCH
            ).move(bd.Pos(0, p.Frame.lip_depth, p.Plates.Switch.z_pos))
        )
        components.append(
            Plate(
                parameters=self.parameters,
                plate_type=PlateType.PCB,
            ).move(bd.Pos(0, p.Frame.lip_depth, p.Plates.PCB.z_pos))
        )
        # Bottom Plate
        components.append(
            Plate(
                parameters=self.parameters,
                plate_type=PlateType.BOTTOM
            ).move(bd.Pos(Z=p.Plates.Bottom.z_pos))
        )
        return bd.Part(label="Androphage", children=components)

    def _set_derived_parameters(self, p: Parameters) -> Parameters:
        """Get the key spacing distance based on the spacing type specified in
        the parameters.
        """
        p.spacing = bd.Vector(p.Keycap.spacing)
        # Heights
        p.key_height = (
            p.Switch.model.height.lower
            + p.Switch.model.height.upper
            + p.Keycap.profile.height
        )
        p.height = max(
            (
                p.key_height
                + p.Plates.PCB.clearance
                + p.Plates.Bottom.thickness
            ),
            (
                p.Trackball.diameter/2
                + p.Plates.Bottom.thickness
                + p.Print.min_wall_thickness
            )
        )
        # Plate Parameters
        p.Plates.Switch.thickness = p.Switch.model.plate_thickness
        p.Plates.Top.z_pos = -p.Plates.Top.thickness / cosd(p.tent_angle)
        p.Plates.Switch.z_pos = (
            - p.Keycap.profile.height
            - p.Switch.model.height.upper
            - p.Plates.Switch.thickness
        ) / cosd(p.tent_angle)
        p.Plates.PCB.z_pos = p.Plates.Switch.z_pos + (
            - p.Switch.model.height.lower
            - p.Plates.PCB.thickness
        ) / cosd(p.tent_angle)
        p.Plates.Bottom.z_pos = -p.height / cosd(p.tent_angle)
        p.Plates.Top.center_width = (
            p.Plates.Top.z_pos
            - p.Plates.Bottom.z_pos
        ) * tand(p.tent_angle)
        p.Plates.Switch.center_width = (
            p.Plates.Switch.z_pos
            - p.Plates.Bottom.z_pos
        ) * tand(p.tent_angle)
        p.Plates.PCB.center_width = (
            p.Plates.PCB.z_pos
            - p.Plates.Bottom.z_pos
        ) * tand(p.tent_angle)
        p.Plates.Bottom.center_width = 0
        p.Plates.Top.edge = p.Plates.Switch.edge + p.Frame.lip_depth
        p.Plates.PCB.edge = p.Plates.Switch.edge
        p.Plates.Bottom.edge = p.Plates.Top.edge
        return p

    def test_layout(self) -> bd.Part:
        with bd.BuildPart() as keys:
            with layout.build_key_locations(self.parameters).locations():
                bd.Box(
                    self.parameters.spacing.X,
                    self.parameters.spacing.Y,
                    1,
                    align=Align.Bottom
                )
        with bd.BuildPart() as plate:
            outline = bd.extrude(
                self._build_plate_outline(
                    edge=4,
                    center_width=5
                ),
                amount=-1
            )
        keys.part.label = "keys"
        plate.part.label = "plate"
        plate.part.color = "Plum"
        return bd.Compound(
            label="Layout test",
            children=[keys.part, plate.part]
        )


if __name__ == "__main__":
    from ocp_vscode import show
    androphage = Androphage()
    show(androphage)