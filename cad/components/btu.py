import typing
from collections.abc import Iterable

import build123d as bd

from common import *


class BTU_Rexroth(Component):
    """Bosch Rexroth KU-B8-OFK Ball Transfer Unit.

        Origin is the top of the ball.

        Parameter names and values are taken from:
        https://store.boschrexroth.com/en/us/p/ball-transfer-unit-r053010810.
    """
    def __init__(
        self,
        a: float = 1.9,
        b: float = 3.2,
        d: float = 7.938,
        D: float = 12.6,
        D1: float = 17,
        h: float = 4.8,
        H: float = 11.2,
        clearance: float = 10.0,
        color: bd.ColorLike = "DarkGray",
        label: str = "BTU",
        mode: bd.Mode = bd.Mode.ADD,
        **kwargs
    ):
        self.a = a
        self.b = b
        self.d = d
        self.D = D
        self.D1 = D1
        self.h = h
        self.H = H
        self.clearance = clearance
        self.mode = mode
        super().__init__(label, color=color, mode=self.mode, **kwargs)

    def _build(self):
        with bd.BuildPart() as btu:
            # Ball
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


class BTU_VCN310(Component):
    """"""
    def __init__(
        self,
        D: float = 9,
        D1: float = 7.5,
        d: float = 4,
        H: float = 1,
        L: float = 4,
        L1: float = 1.1,
        clearance: float = 10,
        color: bd.ColorLike = "DarkGray",
        label: str = "BTU",
        mode: bd.Mode = bd.Mode.ADD,
        **kwargs
    ):
        self.L = L
        self.L1 = L1
        self.D = D
        self.D1 = D1
        self.d = d
        self.H = H
        self.clearance = clearance
        self.mode = mode
        super().__init__(label, color=color, mode=mode, **kwargs)

    def _build(self):
        with bd.BuildPart() as btu:
            # Ball
            bd.Sphere(
                radius=self.d/2,
                align=Align.Top
            )
            with bd.Locations((0, 0, -self.L1)):
                # Flange
                bd.Cylinder(
                    radius=self.D/2,
                    height=self.H,
                    align=Align.Top
                )
                # Main Housing
                bd.Cylinder(
                    radius=self.D1/2,
                    height=self.L + self.H,
                    align=Align.Top
                )
                # Clearance cutter
                if self.mode == bd.Mode.SUBTRACT:
                    bd.Cylinder(
                        radius=self.D/2,
                        height=self.clearance,
                        align=Align.Bottom
                    )
        return btu.part


class BTU_VCN319(Component):
    """"""
    def __init__(
        self,
        L: float = 16,
        L1: float = 1.2,
        D: float = 7,
        d: float = 4.76,
        S: float = 5,
        t: float = 6,
        clearance: float = 10,
        color: bd.ColorLike = "DarkGray",
        label: str = "BTU",
        mode: bd.Mode = bd.Mode.ADD,
        **kwargs
    ):
        self.L = L
        self.L1 = L1
        self.D = D
        self.d = d
        self.S = S
        self.t = t
        self.clearance = clearance
        self.mode = mode
        super().__init__(label, color=color, mode=mode, **kwargs)

    def _build(self):
        with bd.BuildPart() as btu:
            # Ball
            bd.Sphere(
                radius=self.d/2,
                align=Align.Top
            )
            with bd.Locations((0, 0, -self.L1)):
                # Main housing
                bd.Cylinder(
                    radius=self.D/2,
                    height=self.L - self.L1,
                    align=Align.Top
                )
                # Clearance cutter
                if self.mode == bd.Mode.SUBTRACT:
                    bd.Cylinder(
                        radius=self.D/2,
                        height=self.clearance,
                        align=Align.Bottom
                    )
        return btu.part


if __name__ == '__main__':
    from ocp_vscode import show
    mode = bd.Mode.ADD
    show(
        BTU_Rexroth(mode=mode).move(bd.Pos(-20, 0, 0)),
        BTU_VCN310(mode=mode),
        BTU_VCN319(mode=mode).move(bd.Pos(20, 0, 0))
    )