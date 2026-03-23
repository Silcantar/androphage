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
    angles: vector[3]
    clearance: float
    a: float
    b: float
    d: float
    D: float
    D1: float
    h: float
    H: float
    color: str | int = None

@dataclass
class Frame(Component):
    chordAngle: float
    filletRadius: float
    lipDepth: float
    mainRadius: float
    notchDepth: float
    thickness: float
    # extraLength: 3
    color: str | int = None

@dataclass
class CenterBlock(Component):
    ribSize: vector[2]
    screwCount: int
    wallThickness: float
    color: str | int = None

@dataclass
class Desk(Component):
    size: vector[3]
    position: vector[3]
    color: str | int = None

@dataclass
class Hinge(Component):
    diameter: float
    knuckleDepth: float
    length: float
    leafThickness: float
    leafWidth: float
    offset: float
    pinDiameter: float
    color: str | int = None

@dataclass
class Insert(Component):
    diameter: float
    height: float
    holeDiameter: float
    holeDepth: float
    wallThickness: float
    color: str | int = None

@dataclass
class Keycap(Component):
    clearance: float
    # testClearance: bool
    profile: str
    saddle: bool
    spacingType: str
    customSpacing: vector[2] | None
    color: str | int = None

@dataclass
class LED(Component):
    present: bool
    count: int
    holeRadius: float
    holeShape: str
    holeSize: float
    holeSpacing: vector[2]
    positionY: float
    color: str | int = None

@dataclass
class MagneticConnector(Component):
    size: vector[3]
    lip: vector[3]
    lipOffset: float
    color: str | int = None

@dataclass
class MCU(Component):
    chipSize: vector[3]
    location: str
    radius: float
    size: vector[3]
    usbOverhang: float
    usbRadius: float
    usbSize: vector[3]
    usbCutSize: vector[3]

@dataclass
class OLED(Component):
    present: bool
    holeRadius: float
    pcbSize: vector[2]
    position: vector[2]
    screenSize: vector[2]

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
    innerRadius: float
    color: str | int = None

@dataclass
class Screw(Component):
    diameter: float
    minorDiameter: float
    headDiameter: float
    headAngle: float
    offset: float
    color: str | int = None

@dataclass
class Switch(Component):
    cutout: vector[2]
    radius: float
    type: str
    travel: float
    maxTravel: float
    chocColor: str
    glpColor: str
    mxStemColor: any
    mxTopColor: any
    mxBottomColor: any
    color: str | int = None

@dataclass
class Trackball(Component):
    diameter: float
    positionY: float
    clearance: float
    color: str | int = None

@dataclass
class TrackballSensor(Component):
    pcbSize: vector[2]
    size: vector[3]
    lensSize: vector[3]
    clearance: float
    holeSize: float
    angle: float
    holderHeight: float
    holderThickness: float
    color: str | int = None

@dataclass
class Parameters(YAMLWizard):
    # angles: vector[3]
    tentAngle: float
    Columns: Columns#dict[str, Column]
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