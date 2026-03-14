import typing
from collections.abc import Iterable

import build123d as bd

from common import *

class BTU(Component):
    '''
        Bosch Rexroth KU-B8-OFK Ball Transfer Unit.

        Origin is the top of the ball.

        Parameter names and values are taken from:
        https://store.boschrexroth.com/en/us/p/ball-transfer-unit-r053010810.
    '''
    def __init__(
        self,
        angles: bd.RotationLike = (60, 0, 45),
        a: float = 1.9,
        b: float = 3.2,
        d: float = 7.938,
        D: float = 12.6,
        D1: float = 17,
        h: float = 4.8,
        H: float = 11.2,
        clearance: float = 10.0,
        color: bd.ColorLike = 'DarkGray',
        **kwargs
    ):
        self.angles = angles
        self.a = a
        self.b = b
        self.d = d
        self.D = D
        self.D1 = D1
        self.h = h
        self.H = H
        self.clearance = clearance
        super().__init__(color=color, **kwargs)

    def build(self):
        with bd.BuildPart() as btu:
            bd.Sphere(radius=self.d/2, align=Align.Top)
            with bd.Locations((0, 0, -self.h)):
                # Flange
                bd.Cylinder(
                    radius=self.D1/2,
                    height=self.a,
                    align=Align.Bottom
                )
                # Main Housing
                bd.Cylinder(
                    radius=self.D/2,
                    height=self.H-self.h,
                    align=Align.Top
                )
                # Clearance cutter
                if self.mode == bd.Mode.SUBTRACT:
                    bd.Cylinder(
                        radius=self.D1/2,
                        height=self.clearance,
                        align=Align.Bottom
                    )
        return btu.part

    @property
    def angles(self):
        return self._angles

    @angles.setter
    def angles(self, value: bd.RotationLike):
        self._angles = bd.Rotation(value)

if __name__ == '__main__':
    from ocp_vscode import show
    show(BTU(mode=bd.Mode.ADD))