import typing
from os import PathLike
import copy

import build123d as bd

import layout
from components.frame import Frame
from common import *
from parameters import *

class Androphage(bd.BasePartObject):
    """Build a model of an Androphage keyboard based on a parameter file."""

    def __init__(
        self,
        angle: float = 0,
        build: bool = True,
        parameter_path: PathLike = "cad/androphage.yaml",
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
            part = self._build()
            super().__init__(part=part, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters
        left_half = self._build_half(half=Half.LEFT)
        right_half = self._build_half(half=Half.RIGHT)
        # left_half = bd.Part(
        #     label="Left Half",
        #     children=component_list
        # ).rotate(angle=self.angle, axis=bd.Axis.Y)
        # print("Building Right Half.")
        # right_half = bd.Part(
        #     label="Right Half",
        #     children=mirror_preserve(component_list, about=bd.Plane.YZ)
        # ).rotate(angle=-self.angle, axis=bd.Axis.Y)
        # Hinge
        # print("Building Hinges.")
        # from components.knife_hinge import KnifeHinge
        # hinge_locations = [
        #     bd.Pos(
        #         (
        #             top_plate.edges()
        #             .group_by(bd.Axis.X)[-1]
        #             .group_by(bd.Axis.Z)[-1]
        #             .sort_by(bd.Axis.Y)[i]
        #             .vertices()
        #             .sort_by(bd.Axis.Y)[i]
        #             .center()
        #         )
        #         + bd.Vector(
        #             0,
        #             (1 + 2*i)*(p.Hinge.width/2 + 2*p.Frame.lip_depth),
        #             0
        #         )
        #     )
        #     for i in [0, -1]
        # ]
        # hinge_list: list[bd.Part] = []
        # orientations = (
        #     (1, 0, -1, 0),
        #     (0, 0, 1, -1),
        #     (0, 0, -1, 1),
        #     (-1, 0, 1, 0)
        # )
        # for i in range(len(hinge_locations)):
        #     for j in range(4):
        #         hinge_list.append(
        #             hinge_locations[i]
        #             * bd.Pos(Z=(-p.Hinge.height if (j > 1) else 0))
        #             * KnifeHinge(
        #                 parameters=self.parameters,
        #                 knuckle_orientations=orientations[j],
        #                 rotation=(90, 180*j + 180*i, 0)
        #             )
        #         )
        # hinges = bd.Part(children=hinge_list)
        # hinges.label = "Hinges"
        # Trackball
        print("Building Trackball.")
        trackball = (
            bd.Pos(Y=p.Trackball.position_y) 
            * bd.Sphere(
                radius=p.Trackball.diameter/2
            )
        )
        trackball.color = seq_to_color(p.Trackball.color)
        trackball.label = "Trackball"
        # Base
        print("Building Base.")
        from components.base import Base
        base_location = bd.Pos(Z=-p.Hinge.height)
        base_left = base_location * Base(self.parameters, label="Left Base")
        base_right = bd.mirror(objects=base_left, about=bd.Plane.YZ)
        base_right.label = "Right Base"
        base_right.color = seq_to_color(p.Base.color)
        return bd.Part(
            label="Androphage",
            children=[
                left_half,
                right_half,
                base_left,
                base_right,
                # hinges,
                trackball
            ]
        )

    def _build_base(self, half: Half.LEFT) -> bd.Part:
        if half == Half.RIGHT:
            mirror = True
            label = "Right"
        else:
            mirror = False
            label = "Left"
        print(f"Building {label} Base.")
        p = self.parameters
        component_list: list[bd.Part] = []
        from components.base import Base
        base_location = bd.Pos(Z=-p.Hinge.height)
        base = (
            base_location
            * Base(
                self.parameters,
                mirror=mirror,
                label=f"{label} Base"
            )
        )
        component_list.append(base)
        return bd.Part(children=component_list)

    def _build_half(self, half: Half = Half.LEFT) -> bd.Part:
        if half == Half.RIGHT:
            mirror = True
            label = "Right"
        else:
            mirror = False
            label = "Left"
        print(f"Building {label} Half.")
        p = self.parameters
        component_list: list[bd.Part] = []
        # Top Plate
        from components.plate import Plate, PlateType
        top_plate = Plate(
            parameters=self.parameters,
            plate_type=PlateType.TOP,
            draft_center=True,
            mirror=mirror
        ).move(bd.Pos(Z=p.Plates.Top.position_z))
        component_list.append(top_plate)
        # Switch Plate
        print("    Building Switch Plate.")
        switch_plate = Plate(
            parameters=self.parameters,
            plate_type=PlateType.SWITCH,
            mirror=mirror
        ).move(bd.Pos(
            0,
            p.Plates.Top.edge - p.Plates.Switch.edge,
            p.Plates.Switch.position_z
        ))
        component_list.append(switch_plate)
        # PCB
        print("    Building PCB.")
        pcb = Plate(
            parameters=self.parameters,
            plate_type=PlateType.PCB,
            mirror=mirror
        ).move(bd.Pos(
            0,
            p.Plates.Top.edge - p.Plates.Switch.edge,
            p.Plates.PCB.position_z
        ))
        component_list.append(pcb)
        # Bottom Plate
        print("    Building Bottom Plate.")
        bottom_plate = Plate(
            parameters=self.parameters,
            plate_type=PlateType.BOTTOM,
            mirror=mirror
        ).move(bd.Pos(
            0,
            (
                p.Plates.Top.edge
                - p.Plates.Bottom.edge
                + p.Hinge.width
                + 2*p.Frame.lip_depth
                - p.Plates.Bottom.clearance
            ),
            p.Plates.Bottom.position_z
        ))
        component_list.append(bottom_plate)
        # Center Block
        print("    Building Center Block.")
        from components.center_block import CenterBlock
        center_block = CenterBlock(
            parameters=self.parameters,
            mirror=mirror
        ).move(bd.Pos(0, p.Frame.lip_depth, p.Plates.Top.position_z))
        component_list.append(center_block)
        # Magnetic Connector
        print("    Building Magnetic Connector.")
        from components.magnetic_connector import MagneticConnector
        magnetic_connector = MagneticConnector(
            parameters=self.parameters,
            mirror=mirror
        ).move(bd.Pos(
            bd.Vector(p.MagneticConnector.position)
            + (0, p.Frame.lip_depth, p.Plates.Top.position_z)
        ))
        component_list.append(magnetic_connector)
        # Trackball Sensor
        print("    Building Trackball Sensor.")
        from components.trackball_sensor import TrackballSensor
        trackball_location = bd.Pos(Y=p.Trackball.position_y)
        trackball_sensor = TrackballSensor(parameters=self.parameters).move(
            trackball_location
            * bd.Rot(Y=180 + p.TrackballSensor.angle)
            * bd.Pos(Z=p.Trackball.diameter/2)
        )
        component_list.append(trackball_sensor)
        # BTUs
        print("    Building BTUs.")
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
                parameters=self.parameters,
                mirror=mirror
            ).move(loc)
            btu.label = f"BTU {i+1}"
            btu_list.append(btu)
        component_list.append(bd.Part(children=btu_list, label="BTUs"))
        # Frame
        print("    Building Frame.")
        from components.frame import Frame
        frame = Frame(parameters=self.parameters, usb_cutout=False)
        component_list.append(frame)
        # USB-C Port
        print("    Building USB-C Port.")
        from bd_keyboard.src.connectors.usb_c import USB_C_Port
        usb_c_port = (
            layout.usb_c_port_location(
                self.parameters,
                outline=(
                    # Select the top face of the PCB.
                    pcb.faces()
                    .group_by(bd.SortBy.AREA)[-1]
                    .sort_by(bd.Axis.Z)[-1]
                )
            )
            * USB_C_Port()
        )
        component_list.append(usb_c_port)
        # Battery
        from components.battery import Battery
        # Key Switches
        print("    Building Key Switches.")
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
        print("    Building Keycaps.")
        print("    Building Hinge")
        print("    Building Screws.")
        # Screws
        # from bd_warehouse.fastener import CounterSunkScrew, HeatSetNut, HexNut
        return bd.Part(children=component_list)



if __name__ == "__main__":
    from ocp_vscode import show
    androphage = (
        Androphage(angle=0)#.move(bd.Pos(Y=-200)),
        # Androphage(angle=50),
        # Androphage(angle=100).move(bd.Pos(Y=200))
    )
    show(androphage)