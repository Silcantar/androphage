import typing
from os import PathLike
import copy

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
        ).move(bd.Pos(Z=p.Plates.Top.position_z))
        component_list.append(top_plate)
        # Frame
        frame = Frame(parameters=self.parameters)
        component_list.append(frame)
        # Center Block
        from components.center_block import CenterBlock
        center_block = CenterBlock(
            parameters=self.parameters
        ).move(bd.Pos(0, p.Frame.lip_depth, p.Plates.Top.position_z))
        component_list.append(center_block)
        # Switch Plate
        switch_plate = Plate(
            parameters=self.parameters,
            plate_type=PlateType.SWITCH
        ).move(bd.Pos(
            0,
            p.Plates.Top.edge - p.Plates.Switch.edge,
            p.Plates.Switch.position_z
        ))
        component_list.append(switch_plate)
        # PCB
        pcb = Plate(
            parameters=self.parameters,
            plate_type=PlateType.PCB,
        ).move(bd.Pos(
            0,
            p.Plates.Top.edge - p.Plates.Switch.edge,
            p.Plates.PCB.position_z
        ))
        component_list.append(pcb)
        # Bottom Plate
        bottom_plate = Plate(
            parameters=self.parameters,
            plate_type=PlateType.BOTTOM
        ).move(bd.Pos(
            0,
            p.Plates.Top.edge - p.Plates.Bottom.edge,
            p.Plates.Bottom.position_z
        ))
        component_list.append(bottom_plate)
        # Magnetic Connector
        from components.magnetic_connector import MagneticConnector
        magnetic_connector = MagneticConnector(
            parameters=self.parameters
        ).move(bd.Pos(
            bd.Vector(p.MagneticConnector.position)
            + (0, p.Frame.lip_depth, p.Plates.Top.position_z)
        ))
        component_list.append(magnetic_connector)
        # Trackball Sensor
        from components.trackball_sensor import TrackballSensor
        trackball_location = bd.Pos(Y=p.Trackball.position_y)
        trackball_sensor = TrackballSensor(parameters=self.parameters).move(
            trackball_location
            * bd.Rot(Y=180 + p.TrackballSensor.angle)
            * bd.Pos(Z=p.Trackball.diameter/2)
        )
        component_list.append(trackball_sensor)
        # BTUs
        from components.btu import BTU
        btu_locations = bd.Locations([
            trackball_location
            * bd.Rot(
                0,
                p.CenterBlock.btu_angles[1],
                i*p.CenterBlock.btu_angles[2],
                ordering=bd.Extrinsic.XYZ
            )
            * bd.Pos(Z=-p.Trackball.diameter/2)
            for i in (1, -1)
        ])
        btu_list: list[bd.Part] = []
        for i in range(len(btu_locations.locations)):
            loc = btu_locations.locations[i]
            btu = BTU(
                parameters=self.parameters
            ).move(loc)
            btu.label = f"BTU {i+1}"
            btu_list.append(btu)
        component_list.append(bd.Part(children=btu_list, label="BTUs"))
        from components.battery import Battery
        left_half = bd.Part(label="Left Half", children=component_list)
        right_half = bd.Part(
            label="Right Half",
            children=mirror_preserve(component_list, about=bd.Plane.YZ)
        )
        # Hinge
        from components.hinge import Hinge
        hinge = Hinge(
            parameters=self.parameters
        ).move(bd.Pos(0, p.Hinge.position_y + p.Frame.lip_depth, 0))
        # Trackball
        trackball = bd.Sphere(
            radius=p.Trackball.diameter/2
        ).move(trackball_location)
        trackball.color = seq_to_color(p.Trackball.color)
        trackball.label = "Trackball"
        return bd.Part(
            label="Androphage",
            children=[left_half, right_half, hinge, trackball]
        )

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
        p.Plates.Top.position_z = -p.Plates.Top.thickness / cosd(p.tent_angle)
        p.Plates.Switch.position_z = (
            - p.Keycap.profile.height
            - p.Switch.model.height.upper
            - p.Plates.Switch.thickness
        ) / cosd(p.tent_angle)
        p.Plates.PCB.position_z = p.Plates.Switch.position_z + (
            - p.Switch.model.height.lower
            - p.Plates.PCB.thickness
        ) / cosd(p.tent_angle)
        p.Plates.Bottom.position_z = -p.height / cosd(p.tent_angle)
        p.Plates.Top.center_width = (
            p.Plates.Top.position_z
            - p.Plates.Bottom.position_z
        ) * tand(p.tent_angle)
        p.Plates.Switch.center_width = (
            p.Plates.Switch.position_z
            - p.Plates.Bottom.position_z
        ) * tand(p.tent_angle)
        p.Plates.PCB.center_width = (
            p.Plates.PCB.position_z
            - p.Plates.Bottom.position_z
        ) * tand(p.tent_angle)
        p.Plates.Bottom.center_width = 0
        p.Plates.Top.edge = (
            p.Plates.Switch.edge
            + p.Plates.Switch.clearance
            + p.Frame.lip_depth
        )
        p.Plates.PCB.edge = p.Plates.Switch.edge
        p.Plates.Bottom.edge = p.Plates.Top.edge - p.Plates.Bottom.clearance
        # Miscellany
        p.Screws.M2.offset = p.Insert.hole_diameter/2 + p.Insert.wall_thickness
        p.Hinge.diameter = p.Hinge.pin_diameter + 2*p.Hinge.leaf_thickness
        p.Hinge.leaf_width = (p.Hinge.width - p.Hinge.diameter)/2
        p.Hinge.length = p.Hinge.knuckle_length * p.Hinge.knuckle_count
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