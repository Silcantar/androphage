import os.path
from os import PathLike
from copy import copy

import build123d as bd

import layout
from components.frame import Frame
from common import *
from parameters import *

half_names = {Half.LEFT: "Left", Half.RIGHT: "Right"}

class Androphage(bd.BasePartObject):
    """Build a model of an Androphage keyboard based on a parameter file."""

    def __init__(
        self,
        angle: float = 0,
        build: bool = True,
        parameter_path: PathLike = "cad/androphage.yaml",
        main_half: Half = Half.LEFT,
        render_keycaps: bool = False,
        **kwargs
    ):
        self.main_half = main_half
        self.parameters = layout.set_derived_parameters(
            load_parameters(parameter_path)
        )
        self.render_keycaps = render_keycaps
        self.angle = max(0, min(angle, 90 + self.parameters.tent_angle))
        self.column_locations = layout.build_column_locations(self.parameters)
        if build:
            part = self._build()
            super().__init__(part=part, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters
        print(f"Building Androphage at {self.angle}°.")
        left_half = self._build_half(half=Half.LEFT)
        right_half = self._build_half(half=Half.RIGHT)
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
        left_base = self._build_base(half=Half.LEFT)
        right_base = self._build_base(half=Half.RIGHT)
        return bd.Part(
            label="Androphage",
            children=[
                left_half,
                right_half,
                left_base,
                right_base,
                trackball
            ]
        )

    def _build_base(self, half: Half.LEFT) -> bd.Part:
        p = self.parameters
        mirror = (half == Half.RIGHT)
        direction = (1 if mirror else -1)
        angle = self.angle * direction
        angle_limited = min(self.angle, 90 - p.tent_angle) * direction
        print(f"    Building {half_names[half]} Base.")
        component_list: list[bd.Part] = []
        from components.base import Base
        base = Base(
            self.parameters,
            mirror=mirror,
            label=f"{half_names[half]} Base"
            )
        component_list.append(base)
        component_list.extend(self._build_hinges(half=half, base=True))
        assembly = bd.Part(children=component_list)
        assembly.label = f"{half_names[half]} Base"
        base_location = bd.Pos(
            p.Hinge.height*sind(angle_limited),
            0,
            -p.Hinge.height*cosd(angle)
            )
        rotation = bd.Rot(Y=angle_limited)
        return base_location * rotation * assembly

    def _build_half(self, half: Half = Half.LEFT) -> bd.Part:
        p = self.parameters
        mirror = (half == Half.RIGHT)
        tent_angle = p.tent_angle * (1 if mirror else -1)
        print(f"Building {half_names[half]} Half.")
        component_list: list[bd.Part] = []
        # Frame
        print("    Building Frame.")
        from components.frame import Frame
        frame_location = bd.Rot(Y=tent_angle)
        frame = frame_location * Frame(
            parameters=self.parameters,
            usb_cutout=(half==Half.RIGHT),
            mirror=mirror
        )
        component_list.append(frame)
        from components.plate import Plate, PlateType
        # Top Plate
        top_plate_location = (
            bd.Pos(Z=p.Plates.Top.position_z)
            * bd.Rot(Y=tent_angle)
            )
        top_plate = top_plate_location * Plate(
            parameters=self.parameters,
            plate_type=PlateType.TOP,
            draft_center=True,
            half=half,
            mirror=mirror
        )
        component_list.append(top_plate)
        # Switch Plate
        print("    Building Switch Plate.")
        switch_plate_position = (
            bd.Pos(Z=p.Plates.Switch.position_z)
            * bd.Rot(Y=tent_angle)
        )
        switch_plate = switch_plate_position * Plate(
            parameters=self.parameters,
            plate_type=PlateType.SWITCH,
            mirror=mirror
        )
        component_list.append(switch_plate)
        # PCB
        print("    Building PCB.")
        pcb_position = (
            bd.Pos(Z=p.Plates.PCB.position_z)
            * bd.Rot(Y=tent_angle)
        )
        pcb = pcb_position * Plate(
            parameters=self.parameters,
            plate_type=PlateType.PCB,
            mirror=mirror
        )
        component_list.append(pcb)
        # Bottom Plate
        print("    Building Bottom Plate.")
        bottom_plate_position = (
            bd.Pos(Z=p.Plates.Bottom.position_z)
            * bd.Rot(Y=tent_angle)
        )
        bottom_plate = bottom_plate_position * Plate(
            parameters=self.parameters,
            plate_type=PlateType.BOTTOM,
            mirror=mirror
        )
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
        sensor_location = (
            trackball_location
            * bd.Rot(Y=(180 + p.TrackballSensor.angle) * (-1 if mirror else 1))
            * bd.Pos(Z=p.Trackball.diameter/2)
            )
        trackball_sensor = (
            sensor_location
            * TrackballSensor(
                parameters=self.parameters,
                mirror=mirror
                )
            )
        component_list.append(trackball_sensor)
        # Battery
        if half in p.Battery.half:
            from bd_keyboard.src.battery.battery import Battery
            battery_location = sensor_location * bd.Pos(p.Battery.position)
            battery = battery_location * Battery(size=p.Battery.size)
            component_list.append(battery)
        # BTUs
        print("    Building BTUs.")
        from components.btu import BTU
        btu_locations = bd.Locations([
            trackball_location
            * bd.Rot(
                0,
                p.CenterBlock.btu_angles[1] * (-1 if mirror else 1),
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
        # Screen
        if half in p.Screen.half:
            print("    Building Screen.")
            from bd_keyboard.src.display.nice_view import NiceView
            screen_cutout_face = (
                top_plate
                .faces()
                # Select faces whose normal is mostly down.
                .filter_by(lambda f: f.normal_at().Z < -0.7)
                # Select the smallest of these faces.
                .sort_by(bd.SortBy.AREA)[0]
                )
            screen_location = (
                bd.Locations(screen_cutout_face).locations[0]
                * bd.Rot(Y=180)
                * bd.Pos(Y=p.Screen.size[Y]/2 + 1.038)
                )
            screen = screen_location * NiceView()
            component_list.append(screen)
        # USB-C Port
        if half in p.USBPort.half:
            print("    Building USB-C Port.")
            from bd_keyboard.src.connector.usb_c import USB_C_Port
            usb_c_port = (
                layout.usb_c_port_location(
                    self.parameters,
                    outline=(
                        # Select the top face of the PCB.
                        pcb.faces()
                        .group_by(bd.SortBy.AREA)[-1]
                        .sort_by(bd.Axis.Z)[-1]
                    ),
                    mirror=p.USBPort.half == Half.RIGHT
                )
                * USB_C_Port()
            )
            component_list.append(usb_c_port)
        # Key Switches
        print("    Building Key Switches and Keycaps.")
        from bd_keyboard.src.key_switch.choc_v2 import ChocV2
        switch = ChocV2(
            upper_color=seq_to_color(p.Switch.color.top),
            lower_color=seq_to_color(p.Switch.color.bottom),
            stem_color=seq_to_color(p.Switch.color.stem)
            )
        from components.keycap import KeycapSTL, KeycapRow
        keycap_path = os.path.join(
            os.path.dirname(__file__),
            "components",
            "keycaps"
            )
        keycap_rows = {
            row: KeycapSTL(row=row, parameters=p)
            for row in KeycapRow
            }
        switches_list: list[bd.Part] = []
        keycaps_list: list[bd.Part] = []
        i = 1
        switch_joints = [
            joint
            for joint in switch_plate.joints.values()
            if "switch" in joint.label
            ]
        for (i, joint) in zip(range(len(switch_joints)), switch_joints):
            switches_list.append(copy(switch))
            switches_list[-1].label = f"Switch {i+1}"
            joint.connect_to(switches_list[-1].joints["plate"])
            row = min(p.Keycap.rows[i], 6 - p.Keycap.rows[i])
            keycaps_list.append(
                copy(
                    bd.Rot(Z=0 if p.Keycap.rows[i] > 3 else 180)
                    * keycap_rows[f"r{row}"]
                    )
                )
            keycaps_list[-1].label = f"Keycap {i+1}"
            switches_list[-1].joints["keycap"].connect_to(
                keycaps_list[-1].joints["stem"]
                )
        switches = bd.Part(label="Switches", children=switches_list)
        component_list.append(switches)
        keycaps = bd.Part(label="Keycaps", children=keycaps_list)
        if self.render_keycaps:
            component_list.append(keycaps)
        print("    Building Hinge.")
        component_list.extend(self._build_hinges(half=half, base=False))
        print("    Building Screws.")
        # Screws
        # from bd_warehouse.fastener import CounterSunkScrew, HeatSetNut, HexNut
        assembly = bd.Part(children=component_list)
        assembly.label = f"{half_names[half]} Half"
        return bd.Rot(Y=self.angle * (-1 if mirror else 1)) * assembly

    def _build_hinges(
        self,
        half: Half,
        base: bool
        ) -> list[bd.Part]:
        p = self.parameters
        from components.knife_hinge import KnifeHinge
        hinge_locations = [
            bd.Pos(Y=(
                i*p.Plates.depth
                + (1-2*i)*(2*p.Frame.lip_depth + p.Hinge.width/2)
                ))
            * bd.Rot(X=90)
            for i in range(2)
            ]
        if base:
            front_orientation = (
                (0, 0, 1, -1) if half == Half.LEFT
                else (1, 0, -1, 0)
                )
        else:
            front_orientation = (
                (0, 1, 0, -1) if half == Half.LEFT
                else (1, -1, 0, 0)
                )
        orientations = (
            front_orientation,
            front_orientation[::-1] # Reversed
            )
        return [
            location
            * KnifeHinge(
                parameters=self.parameters,
                laminated=False,
                knuckle_orientations=orientation
                )
            for (location, orientation) in zip(hinge_locations, orientations)
            ]

if __name__ == "__main__":
    from ocp_vscode import show
    count = 1
    spacing = 150
    max_angle = 100
    try:
        angle_step = max_angle / (count-1)
    except ZeroDivisionError:
        angle_step = 0
    boards: list[bd.Part] = []
    for i in range(count):
        board = (
            bd.Pos(Y=i*spacing - count*spacing/2)
            * Androphage(angle=i*angle_step)
            )
        board.label = f"Androphage {i*angle_step}°"
        boards.append(board)
    show(boards, render_joints=False)
