import typing
from dataclasses import dataclass

from dataclass_wizard import YAMLWizard

from common import vector

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

@dataclass
class Battery(Component):
    size: vector[3]
    color: str | int = None

@dataclass
class BTU(Component):
    clearance: float
    ball_diameter: float
    ball_height: float
    flange_diameter: float
    flange_height: float
    housing_diameter: float
    housing_height: float
    model: str
    color: str | int = None

@dataclass
class CenterBlock(Component):
    btu_angles: vector[3]
    rib_size: vector[2]
    screw_count: int
    wall_thickness: float
    color: str | int = None

@dataclass
class Desk(Component):
    size: vector[3]
    position: vector[3]
    color: str | int = None

@dataclass
class Frame(Component):
    chord_angle: float
    fillet_radius: float
    lip_depth: float
    main_radius: float
    notch_depth: float
    screw_count: int
    thickness: float
    color: str | int = None

@dataclass
class Hinge(Component):
    diameter: float
    knuckle_depth: float
    length: float
    leaf_thickness: float
    leaf_width: float
    offset: float
    pin_diameter: float
    color: str | int = None

@dataclass
class Insert(Component):
    diameter: float
    height: float
    hole_diameter: float
    hole_depth: float
    wall_thickness: float
    color: str | int = None

@dataclass
class Keycap(Component):
    clearance: float
    profile: str
    saddle: bool
    spacing_type: str
    custom_spacing: vector[2] | None
    color: str | int = None

@dataclass
class LED(Component):
    present: bool
    count: int
    hole_radius: float
    hole_shape: str
    hole_size: float
    hole_spacing: vector[2]
    position_y: float
    color: str | int = None

@dataclass
class MagneticConnector(Component):
    lip: vector[3]
    lip_offset: float
    position_y: float
    screw_offset: float
    size: vector[3]
    color: str | int = None

@dataclass
class MCU(Component):
    chip_size: vector[3]
    location: str
    radius: float
    size: vector[3]
    usb_overhang: float
    usb_radius: float
    usb_size: vector[3]
    usb_cut_size: vector[3]

@dataclass
class OLED(Component):
    present: bool
    hole_radius: float
    pcb_size: vector[2]
    position: vector[2]
    screen_size: vector[2]

@dataclass
class PCB(Component):
    thickness: float
    color: str | int = None

@dataclass
class BottomPlate(Component):
    thickness: float
    clearance: float
    color: str | int = None

@dataclass
class SwitchPlate(Component):
    present: bool
    clearance: float
    edge: float
    radius: float
    color: str | int = None

@dataclass
class TopPlate(Component):
    thickness: float
    radius_inner: float
    color: str | int = None

@dataclass
class Screw(Component):
    diameter: float
    minor_diameter: float
    head_diameter: float
    head_angle: float
    offset: float
    color: str | int = None

@dataclass
class Switch(Component):
    cutout: vector[2]
    radius: float
    type: str
    travel: float
    max_travel: float
    choc_color: str
    glp_color: str
    mx_stem_color: any
    mx_top_color: any
    mx_bottom_color: any
    color: str | int = None

@dataclass
class Trackball(Component):
    diameter: float
    position_y: float
    clearance: float
    color: str | int = None

@dataclass
class TrackballSensor(Component):
    pcb_size: vector[3]
    chip_size: vector[3]
    lens_size: vector[3]
    clearance: float
    hole_size: float
    angle: float
    holder_height: float
    holder_thickness: float
    color: str | int = None

@dataclass
class Parameters(YAMLWizard):
    overhang_angle: float
    tent_angle: float
    Columns: Columns
    Battery: Battery
    BTU: BTU
    Frame: Frame
    CenterBlock: CenterBlock
    Desk: Desk
    Hinge: Hinge
    Insert: Insert
    Keycap: Keycap
    LED: LED
    MagneticConnector: MagneticConnector
    MCU: MCU
    OLED: OLED
    PCB: PCB
    BottomPlate: BottomPlate
    SwitchPlate: SwitchPlate
    TopPlate: TopPlate
    Screw: Screw
    Switch: Switch
    Trackball: Trackball
    TrackballSensor: TrackballSensor


if __name__ == "__main__":
    print(Parameters.from_yaml_file("cad/androphage.yaml"))