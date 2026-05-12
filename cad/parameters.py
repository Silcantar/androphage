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
    pass
    foot_width: float
    opening_clearance: float

@dataclass
class Battery(Component):
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
    screw_count: int
    wall_thickness: float

@dataclass
class Desk(Component):
    size: vector[3]
    position: vector[3]

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
    knuckle_count: float
    knuckle_length: float
    leaf_thickness: float
    pin_diameter: float
    position_y: float

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
    profile: KeycapProfile
    spacing: vector[2]

@dataclass
class LED(Component):
    present: bool
    count: int
    hole_radius: float
    hole_shape: str
    hole_size: float
    hole_spacing: vector[2]
    position_y: float

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
    screw_offset: float
    size: vector[3]

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
class M2(Screw):
    pass

@dataclass
class M3(Screw):
    pass

@dataclass
class M4(Screw):
    pass

@dataclass
class Screws:
    M2: M2
    M3: M3
    M4: M4

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
    chip_size: vector[3]
    clearance: float
    holder_height: float
    holder_thickness: float
    hole_size: float
    lens_size: vector[3]
    optical_center: float
    pcb_size: vector[3]

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
    Plates: Plates
    Screws: Screws
    Switch: Switch
    Trackball: Trackball
    TrackballSensor: TrackballSensor


def load_parameters(parameter_path: PathLike) -> Parameters:
    """Load parameters from a YAML file."""
    return set_derived_parameters(
        Parameters.from_yaml_file(parameter_path)
    )

def set_derived_parameters(p: Parameters) -> Parameters:
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
    key_height = (
        p.key_height
        + p.Plates.PCB.clearance
        + p.Plates.Bottom.thickness
    )
    trackball_height = (
        p.Trackball.diameter/2
        + p.Trackball.clearance
        + p.Plates.Bottom.thickness
        + p.Print.min_wall_thickness
    )
    print(f"key height: {key_height} --- trackball height: {trackball_height}")
    p.height = max(key_height, trackball_height)
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
    # bottom_plate_outline = layout.build_plate_outline(
    #     p,
    #     edge=p.Plates.Bottom.edge,
    #     add_center=p.Plates.Bottom.add_center,
    #     center_width=p.Plates.Bottom.center_width,
    #     fillet_radius=p.Plates.Bottom.radius_outer,
    #     sensor_cutout=False
    # )
    # frame_section = layout.frame_section(parameters=p)
    # frame_bottom_width = frame_section.edges().sort_by(bd.Axis.Z)[0].length
    p.Base.width = p.height*2
    # p.Base.height = sind(p.tent_angle) * (
    #     bottom_plate_outline.length
    #     + frame_bottom_width
    # )
    # p.Base.depth = (
    #     bottom_plate_outline.edges().sort_by(bd.Axis.X)[-1].length
    # )
    # p.Base.offset = 0 # 2*p.Frame.lip_depth
    # p.Base.angled_height = (
    #     p.Base.width*tand(p.tent_angle)/2
    #     - p.Base.foot_width*tand(p.tent_angle)
    # )
    # p.Base.vertical_height = p.Base.height - p.Base.angled_height
    p.Hinge.diameter = p.Hinge.pin_diameter + 2*p.Hinge.leaf_thickness
    p.Hinge.width = 2*(p.height - p.Plates.Bottom.thickness)/cosd(p.tent_angle)
    p.Hinge.length = p.Hinge.knuckle_length * p.Hinge.knuckle_count
    return p

if __name__ == "__main__":
    print(load_parameters("cad/androphage.yaml"))