# import typing
from dataclasses import dataclass
from os import PathLike

from dataclass_wizard import YAMLWizard

vector2 = tuple[float, float]
vector3 = tuple[float, float, float]
vector4 = tuple[float, float, float, float]

colorLike = any

@dataclass
class Column:
    keys: int = 1
    shift: vector2 = (0, 0)
    skip: bool = False
    splay: float = 0
    spread: float = 1
    stagger: float = 0

@dataclass
class Columns:
    thumb_inner: Column = None
    thumb_home: Column = None
    thumb_outer1: Column = None
    thumb_outer2: Column = None
    finger_inner: Column = None
    finger_index: Column = None
    finger_middle: Column = None
    finger_ring: Column = None
    finger_pinky: Column = None
    finger_outer: Column = None

@dataclass
class Component:
    visible: bool

@dataclass
class Battery(Component):
    size: vector3

@dataclass
class BTU(Component):
    angles: vector3
    clearance: float
    d: float
    D: float
    D1: float
    H: float
    L: float
    L1: float

@dataclass
class Frame(Component):
    chordAngle: float
    filletRadius: float
    lipDepth: float
    mainRadius: float
    notchDepth: float
    thickness: float
    # extraLength: 3

@dataclass
class CenterBlock(Component):
    ribSize: vector2
    screwCount: int
    wallThickness: float

@dataclass
class Desk(Component):
    size: vector3
    position: vector3

@dataclass
class Hinge(Component):
    diameter: float
    knuckleDepth: float
    length: float
    leafThickness: float
    leafWidth: float
    offset: float
    pinDiameter: float

@dataclass
class Insert(Component):
    diameter: float
    height: float
    holeDiameter: float
    holeDepth: float
    wallThickness: float

@dataclass
class Keycap(Component):
    clearance: float
    # testClearance: bool
    profile: str
    saddle: bool
    spacingType: str
    customSpacing: vector2

@dataclass
class LED(Component):
    present: bool
    count: int
    holeRadius: float
    holeShape: str
    holeSize: float
    holeSpacing: vector2
    positionY: float

@dataclass
class MagneticConnector(Component):
    size: vector3
    lip: vector3
    lipOffset: float

@dataclass
class MCU(Component):
    chipSize: vector3
    location: str
    radius: float
    size: vector3
    usbOverhang: float
    usbRadius: float
    usbSize: vector3
    usbCutSize: vector3

@dataclass
class OLED(Component):
    present: bool
    holeRadius: float
    pcbSize: vector2
    position: vector2
    screenSize: vector2

@dataclass
class PCB(Component):
    color: colorLike
    thickness: float

@dataclass
class BottomPlate(Component):
    thickness: float
    clearance: float

@dataclass
class SwitchPlate(Component):
    present: bool
    clearance: float
    edge: float
    radius: float

@dataclass
class TopPlate(Component):
    thickness: float
    innerRadius: float

@dataclass
class Screw(Component):
    diameter: float
    minorDiameter: float
    headDiameter: float
    headAngle: float
    offset: float

@dataclass
class Switch(Component):
    cutout: vector2
    radius: float
    type: str
    travel: float
    maxTravel: float
    chocColor: str
    glpColor: str
    mxStemColor: colorLike
    mxTopColor: colorLike
    mxBottomColor: colorLike

@dataclass
class Trackball(Component):
    diameter: float
    positionY: float
    clearance: float

@dataclass
class TrackballSensor(Component):
    pcbSize: vector2
    size: vector3
    lensSize: vector3
    clearance: float
    holeSize: float
    angle: float
    holderHeight: float
    holderThickness: float

@dataclass
class Parameters(YAMLWizard):
    spacing: vector2
    angles: vector3
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


if __name__ == '__main__':
    print(Parameters.from_yaml_file('cad/androphage.yaml'))