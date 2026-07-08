import typing
from dataclasses import dataclass
from os import PathLike

import build123d as bd
from dataclass_wizard import YAMLWizard

from common import Half, vector, cosd, tand

Color = int | str | list[str, float] | list[int, float] | None

@dataclass
class Column:
    connect: int = 0
    cutout: bool = False
    keys: int = 1
    shift: vector[2] = (0, 0)
    skip: bool = False
    splay: float = 0
    spread: float = 1
    stagger: float = 0

Columns = dict[str, Column]

@dataclass
class Component:
    visible: bool
    color: Color

@dataclass
class Base(Component):
    foot_length: float
    foot_width: float
    opening_clearance: float
    trackball_case_round: bool
    waist_point: vector[3]
    wall_thickness: float

@dataclass
class Battery(Component):
    position: vector[3]
    half: Half
    size: vector[3]

@dataclass
class BTU(Component):
    adjust_screw: bool
    ball_diameter: float
    ball_height: float
    clearance: float
    flange_diameter: float
    flange_height: float
    housing_diameter: float
    housing_height: float
    model: str

@dataclass
class CenterBlock(Component):
    btu_angles: vector[3]
    rib_size: vector[2]
    screw_offsets: list[vector[2]]
    wall_thickness: float

@dataclass
class Desk(Component):
    size: vector[3]
    position: vector[3]

@dataclass
class Eye(Component):
    pupil_size: vector[2]
    position: vector[3]
    size: vector[2]

@dataclass
class Frame(Component):
    chord_angle: float
    fillet_radius: float
    lip_depth: float
    main_radius: float
    notch_depth: float
    screw_count: int
    thickness: float

@dataclass
class Hinge(Component):
    offsets: list[float]
    diameter: float
    fillet_radius: float
    multi_connector_width: float
    multi_spacing: float
    pin_diameter: float
    plate_count: int
    plate_thickness: float
    screw: Screw
    screw_position: float
    taper_pin_diameter: float
    taper_pin_position: float
    thickness: float

@dataclass
class Insert(Component):
    diameter: float
    height: float
    hole_diameter: float
    hole_depth: float
    wall_thickness: float

@dataclass
class KeycapProfile:
    height: float

@dataclass
class Keycap(Component):
    offset: vector[3]
    profile: KeycapProfile
    rows: list[int]
    spacing: vector[2]

@dataclass
class Magnet(Component):
    shape: str
    size: vector[3]

@dataclass
class MagneticConnector(Component):
    lip: vector[3]
    lip_offset: float
    pcb_size: vector[3]
    position: vector[3]
    screw: Screw
    screw_offset: float
    size: vector[3]

@dataclass
class Plate(Component):
    radius_outer: float
    add_center: bool

@dataclass
class PCB(Plate):
    clearance: float
    thickness: float

@dataclass
class BottomPlate(Plate):
    clearance: float
    thickness: float

@dataclass
class SwitchPlate(Plate):
    clearance: float
    edge: float

@dataclass
class TopPlate(Plate):
    radius_inner: float
    screen_radius: float
    thickness: float
    thumb_cutout_fillet: bool

@dataclass
class Plates:
    Bottom: BottomPlate
    PCB: PCB
    Switch: SwitchPlate
    Top: TopPlate

@dataclass
class PrintParameters:
    overhang_angle: float
    wall_thickness: float
    min_wall_thickness: float

@dataclass
class Screen(Component):
    bezel: float
    chip_size: vector[3]
    display_area: vector[2]
    fillet_radius: float
    half: Half
    hole_count: int
    hole_id: float
    hole_od: float
    hole_spacing: float
    pcb_size: vector[3]
    position: float
    size: vector[3]

@dataclass
class Screw(Component):
    counter_sink_diameter: float
    diameter: float
    drive_depth: float
    drive_width: float
    head_diameter: float
    head_angle: float
    hole_diameter: float
    minor_diameter: float

@dataclass
class Screws:
    M2: Screw
    M3: Screw
    M4: Screw

@dataclass
class SwitchColor:
    bottom: Color
    stem: Color
    top: Color

@dataclass
class SwitchHeight:
    stem: float
    upper: float
    lower: float
    legs: float

@dataclass
class SwitchModel:
    cutout: vector[2]
    height: SwitchHeight
    max_travel: float
    name: str
    plate_thickness: float
    radius: float

@dataclass
class Switch(Component):
    color: SwitchColor
    model: SwitchModel

@dataclass
class Trackball(Component):
    diameter: float
    position_y: float
    clearance: float

@dataclass
class TrackballSensor(Component):
    angle: float
    bottom_chip_size: vector[3]
    chip_size: vector[3]
    clearance: float
    holder_height: float
    holder_thickness: float
    hole_size: float
    hook_angle: float
    hook_thickness: float
    lens_size: vector[3]
    optical_center: float
    pcb_size: vector[3]
    screw: Screw
    screw_position: vector[3]

@dataclass
class USBPort(Component):
    cut_size: vector[3]
    cut_radius: float
    half: Half
    inside_depth: float
    position: vector[3]
    radius: float
    size: vector[3]
    thickness: float
    tongue_size: vector[3]
    tongue_radius: float

@dataclass
class Parameters(YAMLWizard):
    main_half: Half
    tent_angle: float
    center_width: float
    pivot_depth: float
    Print: PrintParameters
    Columns: Columns
    Base: Base
    Battery: Battery
    BTU: BTU
    CenterBlock: CenterBlock
    Desk: Desk
    Eye: Eye
    Frame: Frame
    Hinge: Hinge
    Insert: Insert
    Keycap: Keycap
    MagneticConnector: MagneticConnector
    # MCU: MCU
    Plates: Plates
    Screen: Screen
    Screws: Screws
    Switch: Switch
    Trackball: Trackball
    TrackballSensor: TrackballSensor
    USBPort: USBPort


def load_parameters(parameter_path: PathLike) -> Parameters:
    """Load parameters from a YAML file."""
    return Parameters.from_yaml_file(parameter_path)


if __name__ == "__main__":
    print(load_parameters("cad/androphage.yaml"))