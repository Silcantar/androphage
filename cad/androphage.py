import typing
from os import PathLike
import copy

import build123d as bd

import layout
from components.frame import Frame
from common import *
from parameters import *

# Passed to __main__
test_layout = True

class Androphage(bd.BasePartObject):
    """Build a model of an Androphage keyboard based on a parameter file."""

    def __init__(
        self,
        angle: float = 0,
        build: bool = True,
        parameter_path: PathLike = "cad/androphage.yaml",
        test_layout: bool = False,
        main_half: Half = Half.LEFT,
        **kwargs
    ):
        self.main_half = main_half
        self.parameters = layout.set_derived_parameters(
            load_parameters(parameter_path)
        )
        self.angle = max(0, min(angle, 90 + self.parameters.tent_angle))
        self.column_locations = layout.build_column_locations(self.parameters)
        if build:
            part = self._build(test_layout)
            super().__init__(part=part, **kwargs)

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
        print("Building Frame.")
        frame = Frame(parameters=self.parameters)
        component_list.append(frame)
        # Center Block
        print("Building Center Block.")
        from components.center_block import CenterBlock
        center_block = CenterBlock(
            parameters=self.parameters
        ).move(bd.Pos(0, p.Frame.lip_depth, p.Plates.Top.position_z))
        component_list.append(center_block)
        # Switch Plate
        print("Building Switch Plate.")
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
        print("Building PCB.")
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
        print("Building Bottom Plate.")
        bottom_plate = Plate(
            parameters=self.parameters,
            plate_type=PlateType.BOTTOM
        ).move(bd.Pos(
            0,
            (
                p.Plates.Top.edge
                - p.Plates.Bottom.edge
                + p.Hinge.width
                + 2*p.Frame.lip_depth
            ),
            p.Plates.Bottom.position_z
        ))
        component_list.append(bottom_plate)
        # Magnetic Connector
        print("Building Magnetic Connector.")
        from components.magnetic_connector import MagneticConnector
        magnetic_connector = MagneticConnector(
            parameters=self.parameters
        ).move(bd.Pos(
            bd.Vector(p.MagneticConnector.position)
            + (0, p.Frame.lip_depth, p.Plates.Top.position_z)
        ))
        component_list.append(magnetic_connector)
        # Trackball Sensor
        print("Building Trackball Sensor.")
        from components.trackball_sensor import TrackballSensor
        trackball_location = bd.Pos(Y=p.Trackball.position_y)
        trackball_sensor = TrackballSensor(parameters=self.parameters).move(
            trackball_location
            * bd.Rot(Y=180 + p.TrackballSensor.angle)
            * bd.Pos(Z=p.Trackball.diameter/2)
        )
        component_list.append(trackball_sensor)
        # BTUs
        print("Building BTUs.")
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
        # USB-C Port
        print("Building USB-C Port.")
        from bd_keyboard.src.connectors.usb_c import USB_C_Port
        usb_c_port_loc = (
            bd.Location(
                bottom_plate.faces()
                .filter_by(bd.GeomType.CYLINDER)
                .filter_by(lambda f: f.radius > 110 and f.radius < 120)
                .edges()
                .group_by(bd.SortBy.LENGTH)[-1]
                .sort_by(bd.Axis.Z)[-1]
                .reversed()
                .location_at(
                    distance=p.USBPort.position[0],
                    position_mode=bd.PositionMode.LENGTH
                )
            )
            * bd.Rot(90, 0, -90)
            * bd.Pos(0, p.USBPort.position[1], 0)
        )
        usb_c_port = usb_c_port_loc * USB_C_Port()
        component_list.append(usb_c_port)
        # Battery
        from components.battery import Battery
        # Key Switches
        print("Building Key Switches.")
        # from bd_keyboard.src.key_switch.choc_v2 import ChocV2
        # switch_locations = bd.Locations(
        #     list(layout.build_key_locations(self.parameters).values())
        # )
        # switches = bd.Part(children=(
        #     switch_locations
        #     * ChocV2(
        #         lower_color=seq_to_color(p.Switch.color.bottom),
        #         stem_color=seq_to_color(p.Switch.color.stem),
        #         upper_color=seq_to_color(p.Switch.color.top)
        #     )
        # ))
        # component_list.append(switches)
        left_half = bd.Part(
            label="Left Half",
            children=component_list
        ).rotate(angle=self.angle, axis=bd.Axis.Y)
        print("Building Right Half.")
        right_half = bd.Part(
            label="Right Half",
            children=mirror_preserve(component_list, about=bd.Plane.YZ)
        ).rotate(angle=-self.angle, axis=bd.Axis.Y)
        # Hinge
        print("Building Hinges.")
        from components.knife_hinge import KnifeHinge
        hinge_locations = [
            bd.Pos(
                (
                    top_plate.edges()
                    .group_by(bd.Axis.X)[-1]
                    .group_by(bd.Axis.Z)[-1]
                    .sort_by(bd.Axis.Y)[i]
                    .vertices()
                    .sort_by(bd.Axis.Y)[i]
                    .center()
                )
                + bd.Vector(
                    -p.Hinge.thickness/2,
                    (1 + 2*i)*(p.Hinge.width/2 + 2*p.Frame.lip_depth),
                    -p.Hinge.height/2
                )
            )
            for i in [0, -1]
        ]
        hinge_list: list[bd.Part] = []
        for i in range(len(hinge_locations)): #(loc, mirror) in zip(hinge_locations, [False, True]):
            hinge_list.append(
                hinge_locations[i]
                * KnifeHinge(
                    parameters=self.parameters,
                    mirror=(i == 1),
                    rotation=((1 - 2*i)*90, 0, 0)
                )
            )
        hinges = bd.Part(children=hinge_list)
        # Trackball
        print("Building Trackball.")
        trackball = bd.Sphere(
            radius=p.Trackball.diameter/2
        ).move(trackball_location)
        trackball.color = seq_to_color(p.Trackball.color)
        trackball.label = "Trackball"
        # Base
        print("Building Base.")
        # from components.base import Base
        # match self.angle:
        #     case 0:
        #         base_location = bd.Pos(
        #             Z=-p.height/cosd(p.tent_angle) - p.Base.vertical_height
        #         )
        #     case closed_angle if closed_angle == 90 + p.tent_angle:
        #         base_location = bd.Rot(Y=180)
        #     case _:
        #         base_location = bd.Location(
        #             position=(0, 0, -100),
        #             orientation=(0, 180 * self.angle / (90 + p.tent_angle), 0)
        #         )
        # base = Base(self.parameters).move(base_location)
        # Screws
        # from bd_warehouse.fastener import CounterSunkScrew, HeatSetNut, HexNut
        return bd.Part(
            label="Androphage",
            children=[
                left_half,
                right_half,
                hinges,
                trackball,
                # base
            ]
        )

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
    androphage = [
        Androphage(angle=0).move(bd.Pos(Y=-200)),
        # Androphage(angle=50),
        # Androphage(angle=100).move(bd.Pos(Y=200))
    ]
    show(androphage)