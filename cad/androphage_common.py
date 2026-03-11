import typing
from collections.abc import Iterable, Sequence
from dataclasses import dataclass
from math import cos, sin, radians

import build123d as bd

EPS = 0.001

def cosd(angle: float) -> float:
    return cos(radians(angle))

def sind(angle: float) -> float:
    return sin(radians(angle))

AlignLike = bd.Align | tuple[bd.Align, bd.Align, bd.Align]

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

class Component(bd.BasePartObject):
    def __init__(
        self,
        align: AlignLike = bd.Align.NONE,
        color: bd.ColorLike | str = 'CornflowerBlue',
        mode: bd.Mode = bd.Mode.ADD,
        rotation: bd.RotationLike = [0, 0, 0],
    ):
        self.align = align
        # self.color = color
        self.mode = mode
        self.rotation = rotation
        part = self.build()
        super().__init__(
            part=part,
            rotation=self.rotation,
            align=self.align,
            mode=self.mode
        )
        self.color = color

    def build(self) -> bd.Part:
        raise NotImplementedError()


class Column:
    _defaults = {
        'keys': 1,
        'skip': False,
        'shift': [0, 0],
        'splay': 0,
        'spread': 1,
        'stagger': 0,
    }

    def __init__(self, column_defs: dict[str, any]):
        for key in self._defaults:
            try:
                self.__dict__[key] = column_defs[key]
            except KeyError:
                self.__dict__[key] = self._defaults[key]


class LocationDict(dict):
    def __init__(self, **kwargs):
        super().__init__(kwargs)

    def locations(self) -> bd.LocationList:
        return bd.LocationList(list(self.values()))


def key_locations(
    column_defs: dict[str, any],
    spacing: Sequence[float, float]
) -> LocationDict:
    spc = bd.Vector(spacing)
    locations = LocationDict()
    origin = bd.Location((0, 0))
    for column_key in column_defs:
        column = Column(column_defs[column_key])
        if column.skip:
            continue
        origin *= bd.Location(
            position=[column.spread*spc.X, column.stagger*spc.Y],
            orientation=[0, 0, -column.splay]
        )
        for i in range(0, column.keys):
            loc = (
                origin * bd.Location(position=[
                    spc.X*column.shift[0],
                    spc.Y*(i + column.shift[1])
                ])
            )
            loc.label = f'{column_key}_{i}'
            locations[loc.label] = loc
    return locations


def plate_outline(
    key_locations: LocationDict,
    spacing: Sequence[float, float],
    hinge_length: float,
    offset: float = 0,
) -> bd.Face:
    spc = bd.Vector(spacing)
    bottom = 0
    top = spc.Y
    left = 0
    right = spc.X
    center = spc.X/2
    middle = spc.Y/2
    hinge_back_point = (
        key_locations['thumb_inner_0']
        * bd.Pos(left, top)
        * bd.Rot(Z=-45)
        * bd.Pos(0, hinge_length)
    )
    with bd.BuildSketch() as sketch:
        with bd.BuildLine() as outline:
            front_outer_arc = bd.ThreePointArc(
                (key_locations['thumb_outer2_0'] * bd.Pos(center, bottom)).position,
                (key_locations['finger_ring_0'] * bd.Pos(right, bottom)).position,
                (key_locations['finger_pinky_0'] * bd.Pos(right, bottom)).position,
            )
            outside_line = bd.Line(
                (key_locations['finger_pinky_0'] * bd.Pos(right, bottom)).position,
                (key_locations['finger_pinky_2'] * bd.Pos(right, top)).position,
            )
            # back_line = bd.Line(
            #     (key_locations['finger_middle_3'] * bd.Pos(right, top)).position,
            #     (key_locations['finger_middle_3'] * bd.Pos(left, top)).position,
            # )
                #(key_locations['finger_inner_2'] * bd.Pos(left, top)).position,
            back_center_arc = bd.TangentArc(
                hinge_back_point.position,
                (key_locations['finger_middle_3'] * bd.Pos(left, top)).position,
                tangent=(bd.Rot(hinge_back_point.orientation) * bd.Pos(1,0)).position
            )
            back_outside_arc = bd.TangentArc(
                back_center_arc.end_point(),
                (key_locations['finger_pinky_2'] * bd.Pos(right, top)).position,
                tangent=back_center_arc.tangent_at(1)
                # (key_locations['finger_ring_3'] * bd.Pos(right, top)).position,
                # (key_locations['finger_middle_3'] * bd.Pos(right, top)).position,
            )
            center_polyline = bd.Polyline(
                hinge_back_point.position,
                (key_locations['thumb_inner_0'] * bd.Pos(left, top)).position,
                (key_locations['thumb_inner_0'] * bd.Pos(left, bottom)).position,
                (key_locations['thumb_inner_0'] * bd.Pos(center, bottom)).position
            )
            front_arc = bd.ThreePointArc(
                (key_locations['thumb_inner_0'] * bd.Pos(center, bottom)).position,
                (key_locations['thumb_home_0'] * bd.Pos(right, bottom)).position,
                (key_locations['thumb_outer2_0'] * bd.Pos(center, bottom)).position
            )
            bd.offset(amount=offset, kind=bd.Kind.INTERSECTION)
        bd.make_face()

    return sketch.face()