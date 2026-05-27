import typing
from collections.abc import Iterable, Sequence
from dataclasses import dataclass
from enum import Enum, StrEnum, auto
from math import cos, sin, tan, acos, asin, atan, radians, degrees
import copy as copy_module

import build123d as bd

# Geometry Definitions
BIG = 1000
EPS = 0.001
INCH = 25.4

def cosd(angle: float) -> float:
    return cos(radians(angle))

def sind(angle: float) -> float:
    return sin(radians(angle))

def tand(angle: float) -> float:
    return tan(radians(angle))

def acosd(x: float) -> float:
    return degrees(acos(x))

def asind(x: float) -> float:
    return degrees(asin(x))

def atand(x: float) -> float:
    return degrees(atan(x))

# Utility Functions
def seq_to_color(color_seq: Sequence = []) -> bd.Color:
    if color_seq is None:
        return bd.Color()
    if isinstance(color_seq, str):
        return bd.Color(color_seq)
    match len(color_seq):
        case 0:
            return bd.Color()
        case 1:
            return bd.Color(color_seq[0])
        case 2:
            if isinstance(color_seq[0], str):
                return bd.Color(
                    name=color_seq[0],
                    alpha=color_seq[1]
                )
            else:
                return bd.Color(
                    color_code=color_seq[0],
                    alpha=color_seq[1]
                )
        case 3:
            return bd.Color(
                red=color_seq[0],
                green=color_seq[1],
                blue=color_seq[2]
            )
        case n if n >= 4:
            return bd.Color(
                red=color_seq[0],
                green=color_seq[1],
                blue=color_seq[2],
                alpha=color_seq[3]
            )


def mirror_preserve(
    objects: bd.MirrorType | Iterable[bd.MirrorType] | None = None,
    about: bd.Plane = bd.Plane.XZ,
    mode: bd.Mode = bd.Mode.ADD,
) -> list[bd.MirrorType]:
    """Wrapper for build123d.mirror that preserves object metadata."""
    mirrored: list[bd.MirrorType] = []
    for obj in objects:
        if len(obj.children) > 0:
            metadata = (obj.label, obj.color)
            location = obj.location
            mirrored_obj = bd.Part(
                children=mirror_preserve(
                    objects=obj.children,
                    about=about,
                    mode=mode
                )
            )
            (mirrored_obj.label, mirrored_obj.color) = metadata
            if mirrored_obj.label == "Trackball Sensor":
                # Bodge the trackball sensor location.
                mirrored_obj.location = location.mirror(bd.Plane.YZ) * bd.Rot(Z=180)
            else:
                mirrored_obj.location = location
        else:
            metadata = (obj.label, obj.color)
            mirrored_obj = bd.mirror(obj, about=about, mode=mode)
            (mirrored_obj.label, mirrored_obj.color) = metadata
        mirrored.append(mirrored_obj)
    return mirrored


# Datatype Definitions
vector = {
    2: tuple[float, float],
    3: tuple[float, float, float],
    4: tuple[float, float, float, float]
}

# Enums
class Color(Enum):
    black = 0x303030

class CutoutType(StrEnum):
    NONE = auto()
    SMALL = auto()
    BIG = auto()

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

class Half(StrEnum):
    LEFT = auto()
    RIGHT = auto()

class SpacingType(StrEnum):
    CHOC = auto()
    MX = auto()
    MX_INCH = auto()
    CUSTOM = auto()

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
        build: bool = True,
        color: bd.ColorLike = "CornflowerBlue",
        label: str = None,
        locate: bool = True,
        **kwargs
    ):
        if build:
            part = self._build()
            super().__init__(
                part=part,
                **kwargs
            )
        else:
            part = None
        if locate:
            self._locate()
        if label is not None:
            self.label = label
        if color is not None:
            self.color = color

    def _build(self) -> bd.Part:
        raise NotImplementedError()

    def _locate(self):
        pass


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


class Tube(bd.BasePartObject):
    def __init__(
        self,
        radius_outer: float,
        radius_inner: float,
        height_: float,
        align: AlignLike = Align.Center,
        **kwargs
    ):
        self.radius_outer = radius_outer
        self.radius_inner = radius_inner
        self.height_ = height_
        self.align = align
        with bd.BuildPart() as bp:
            outer = bd.Cylinder(
                radius_outer,
                height_,
                align=align
            )
            with bd.Locations(bp.part.center()):
                bd.Cylinder(
                    radius_inner,
                    height_,
                    align=Align.Center,
                    mode=bd.Mode.SUBTRACT
                )
        super().__init__(bp.part, align=align, **kwargs)

class CenterPie(bd.BaseSketchObject):

    _applies_to = [bd.BuildSketch._tag]

    def __init__(
        self,
        center: bd.VectorLike,
        radius: float,
        start_angle: float,
        arc_size: float,
        align: AlignLike = (bd.Align.CENTER, bd.Align.CENTER),
        mode: bd.Mode = bd.Mode.ADD,
    ):
        context: bd.BuildSketch | None = bd.BuildSketch._get_context(self)
        bd.validate_inputs(context, self)

        self.center = center
        self.radius = radius
        self.start_angle = start_angle
        self.arc_size = arc_size

        arc = bd.CenterArc(
            center=center,
            radius=radius,
            start_angle=start_angle,
            arc_size=arc_size
        )
        face = bd.make_face([
            arc,
            bd.Line(
                arc.start_point(),
                center
            ),
            bd.Line(
                center,
                arc.end_point()
            )
        ])

        super().__init__(face, rotation=0, mode=mode)


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
        bd.validate_inputs(context, self)

        self.radius = radius
        self.arc_size = arc_size
        self.align = bd.tuplify(align, 2)

        face = (
            bd.Face(bd.Wire.make_circle(radius))
            if arc_size == 360.0
            else bd.Face.revolve(bd.Edge.make_line((radius, 0), (0, 0)), arc_size, bd.Axis.Z)
        )
        super().__init__(face, 0, self.align, mode)