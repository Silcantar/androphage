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
        from components.frame import Frame
        p = self.parameters
        component_list: list[bd.Part] = []
        if test_layout:
            return self.test_layout()
        # Top Plate
        from components.plate import Plate, PlateType
        top_plate = Plate(
            parameters=self.parameters,
            plate_type=PlateType.TOP,
            draft_center=True
        ).move(bd.Pos(Z=p.Plates.Top.z_pos))
        component_list.append(top_plate)
        # Frame
        frame = Frame(parameters=self.parameters)
        component_list.append(frame)
        # Center Block
        from components.center_block import CenterBlock
        center_block = CenterBlock(
            parameters=self.parameters
        ).move(bd.Pos(0, 2*p.Frame.lip_depth, p.Plates.Top.z_pos))
        component_list.append(center_block)
        # Switch Plate
        switch_plate = Plate(
            parameters=self.parameters,
            plate_type=PlateType.SWITCH
        ).move(bd.Pos(
            0,
            p.Plates.Top.edge - p.Plates.Switch.edge,
            p.Plates.Switch.z_pos
        ))
        component_list.append(switch_plate)
        # PCB
        pcb = Plate(
            parameters=self.parameters,
            plate_type=PlateType.PCB,
        ).move(bd.Pos(
            0,
            p.Plates.Top.edge - p.Plates.Switch.edge,
            p.Plates.PCB.z_pos
        ))
        component_list.append(pcb)
        # Bottom Plate
        bottom_plate = Plate(
            parameters=self.parameters,
            plate_type=PlateType.BOTTOM
        ).move(bd.Pos(Z=p.Plates.Bottom.z_pos))
        component_list.append(bottom_plate)
        # Magnetic Connector
        from components.magnetic_connector import MagneticConnector
        magcon_size = bd.Vector(p.MagneticConnector.size)
        magnetic_connector = MagneticConnector(
            parameters=self.parameters
        ).move(bd.Pos(
            center_block.edges()
            .group_by(bd.Axis.X)[-1].edges()
            .filter_by(bd.GeomType.CIRCLE).edges()
            .filter_by(
                lambda e: e.radius == magcon_size.Z/2 - EPS
            ).edges()
            .group_by(bd.Axis.Y)[0].edges()
            .sort_by(bd.Axis.Z)[0].edge().start_point()
            + (0, magcon_size.Y/2, 0)
        ))
        component_list.append(magnetic_connector)
        from components.battery import Battery
        return bd.Part(label="Androphage", children=component_list)

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
        p.Plates.Top.edge = (
            p.Plates.Switch.edge
            + p.Plates.Switch.clearance
            + p.Frame.lip_depth
        )
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