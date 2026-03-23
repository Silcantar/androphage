import typing
from dataclasses import dataclass
from enum import StrEnum, auto
from math import cos, sin, tan, radians

import build123d as bd

# Geometry Definitions
EPS = 0.001

def cosd(angle: float) -> float:
    return cos(radians(angle))

def sind(angle: float) -> float:
    return sin(radians(angle))

def tand(angle: float) -> float:
    return tan(radians(angle))

# Datatype Definitions
vector = {
    2: tuple[float, float],
    3: tuple[float, float, float],
    4: tuple[float, float, float, float]
}

# Enums
class Finger(StrEnum):
    REACH = auto()
    HOME = auto()
    TUCK = auto()
    TUCK2 = auto() # Not used
    INNER = auto()
    INDEX = auto()
    MIDDLE = auto()
    RING = auto()
    PINKY = auto()
    OUTER = auto()

class SpacingType(StrEnum):
    CHOC = auto()
    MX = auto()
    MX_INCH = auto()
    CUSTOM = auto()

class Half(StrEnum):
    LEFT = auto()
    RIGHT = auto()

# Alignment Shorthands
AlignLike = (
    bd.Align
    | tuple[bd.Align, bd.Align]
    | tuple[bd.Align, bd.Align, bd.Align]
)

MIN = bd.Align.MIN
CENTER = bd.Align.CENTER
MAX = bd.Align.MAX

@dataclass(frozen=True)
class Align:
    LeftFrontBottom     = (MIN,     MIN,    MIN)
    LeftFront           = (MIN,     MIN,    CENTER)
    LeftFrontTop        = (MIN,     MIN,    MAX)
    LeftBottom          = (MIN,     CENTER, MIN)
    Left                = (MIN,     CENTER, CENTER)
    LeftTop             = (MIN,     CENTER, MAX)
    LeftBackBottom      = (MIN,     MAX,    MIN)
    LeftBack            = (MIN,     MAX,    CENTER)
    LeftBackTop         = (MIN,     MAX,    MAX)
    FrontBottom         = (CENTER,  MIN,    MIN)
    Front               = (CENTER,  MIN,    CENTER)
    FrontTop            = (CENTER,  MIN,    MAX)
    Bottom              = (CENTER,  CENTER, MIN)
    Center              = (CENTER,  CENTER, CENTER)
    Top                 = (CENTER,  CENTER, MAX)
    BackBottom          = (CENTER,  MAX,    MIN)
    Back                = (CENTER,  MAX,    CENTER)
    BackTop             = (CENTER,  MAX,    MAX)
    RightFrontBottom    = (MAX,     MIN,    MIN)
    RightFront          = (MAX,     MIN,    CENTER)
    RightFrontTop       = (MAX,     MIN,    MAX)
    RightBottom         = (MAX,     CENTER, MIN)
    Right               = (MAX,     CENTER, CENTER)
    RightTop            = (MAX,     CENTER, MAX)
    RightBackBottom     = (MAX,     MAX,    MIN)
    RightBack           = (MAX,     MAX,    CENTER)
    RightBackTop        = (MAX,     MAX,    MAX)


# Classes
class Component(bd.BasePartObject):
    """Extension of Build123d BasePartObject that adds support for
    setting the part"s color and declares a stub method for building
    the part that should be defined by subclasses.
    """
    def __init__(
        self,
        label: str,
        color: bd.ColorLike = "CornflowerBlue",
        # visible: bool = true,
        **kwargs
    ):
        part = self._build()
        super().__init__(
            part=part,
            **kwargs
        )
        self.label = label
        self.color = color

    def _build(self) -> bd.Part:
        raise NotImplementedError()


class KeyLocation(bd.Location):
    """Extended version of build123d.Location that includes additional
    information about the key that will be at the location."""

    def __init__(
        self,
        location: bd.Location,
        row: int,
        connect: int = 0,
        cutout: bool = False,
        **kwargs
    ):
        # self.location = location
        self.row = row
        self.connect = connect
        self.cutout = cutout
        super().__init__(location, **kwargs)


class KeyLocationDict(dict[str, KeyLocation]):
    """Dictionary with string keys and containing Build123d Locations.

    Defines one additional method to return a Build123d LocationList.
    """

    def locations(self) -> bd.LocationList:
        return bd.LocationList(list(self.values()))


class Circle(bd.BaseSketchObject):
    """Sketch Object: Circle

    Create a circle defined by radius.

    Args:
        radius (float): circle radius
        arc_size (float, optional): angular size of sector. Defaults to 360.
        align (Align | tuple[Align, Align], optional): align MIN, CENTER, or MAX of object.
            Defaults to (Align.CENTER, Align.CENTER)
        mode (Mode, optional): combination mode. Defaults to Mode.ADD
    """

    _applies_to = [bd.BuildSketch._tag]

    def __init__(
        self,
        radius: float,
        arc_size: float = 360.0,
        align: AlignLike = (bd.Align.CENTER, bd.Align.CENTER),
        mode: bd.Mode = bd.Mode.ADD,
    ):
        context: bd.BuildSketch | None = bd.BuildSketch._get_context(self)
        validate_inputs(context, self)

        self.radius = radius
        self.arc_size = arc_size
        self.align = tuplify(align, 2)

        face = (
            bd.Face(bd.Wire.make_circle(radius))
            if arc_size == 360.0
            else bd.Face.revolve(bd.Edge.make_line((radius, 0), (0, 0)), arc_size, bd.Axis.Z)
        )
        super().__init__(face, 0, self.align, mode)