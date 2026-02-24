import typing
from collections.abc import Iterable
# from enum import Enum
from dataclasses import dataclass

import build123d as bd

eps = 0.001

vector2 = tuple[float, float]
vector3 = tuple[float, float, float]
vector4 = tuple[float, float, float, float]

MIN = bd.Align.MIN
CENTER = bd.Align.CENTER
MAX = bd.Align.MAX
@dataclass
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
        align: bd.Align | tuple[bd.Align, bd.Align, bd.Align] = bd.Align.NONE,
        color: Iterable | str = 'silver',
        mode: bd.Mode = bd.Mode.ADD,
        rotation: Iterable = [0, 0, 0],
    ):
        self.align = align
        self.color = color
        self.mode = mode
        self.rotation = rotation
        part = self.build()
        super().__init__(
            part=part,
            rotation=self.rotation,
            align=self.align,
            mode=self.mode
        )

    def build(self) -> bd.Part:
        raise NotImplementedError()

    @property
    def color(self):
        return self._color

    @color.setter
    def color(self, value: Iterable | str):
        self._color = MakeColor(value)

    @property
    def rotation(self):
        return self._rotation

    @rotation.setter
    def rotation(self, value: Iterable):
        self._rotation = bd.Rotation(value)


def MakeColor(value: Iterable | str, alpha: float = 1.0):
    if isinstance(value, str):
        return bd.Color(name=value)
    elif isinstance(value, Iterable):
        alpha = value[3] if len(value) >= 4 else alpha
        return bd.Color(
            r=value[0],
            g=value[1],
            b=value[2],
            a=alpha
        )
    else:
        return bd.Color()

