import typing

import build123d as bd

from common import *

class MagneticConnector(Component):
    """12-pin magnetic pogo pin connector."""

    def __init__(
        self,
        size: bd.VectorLike = (4.7, 26.5, 6.0),
        lip: bd.VectorLike = (1.0, 28.5, 8.0),
        lip_offset: float = 1.0,
        color: bd.ColorLike = 0x303030,
        label: str = "Magnetic Connector",
        **kwargs
    ):
        self.size = size
        self.lip = lip
        self.lip_offset = lip_offset
        super().__init__(label, color=color, **kwargs)

    def _build(self) -> bd.Part:
        with bd.BuildPart() as mag_con:
            with bd.BuildSketch(bd.Plane.YZ) as main_sketch:
                bd.RectangleRounded(
                    width=self.size.Y,
                    height=self.size.Z,
                    radius=self.size.Z/2 - EPS
                )
            bd.extrude(amount=self.size.X, dir=(-1, 0, 0))
            lip_plane = bd.Plane.YZ.move(bd.Pos(-self.lip_offset, 0, 0))
            with bd.BuildSketch(lip_plane) as lip_sketch:
                bd.RectangleRounded(
                    width=self.lip.Y,
                    height=self.lip.Z,
                    radius=self.lip.Z/2 - EPS
                )
            bd.extrude(amount=self.lip.X, dir=(-1, 0, 0))
        return mag_con.part

    @property
    def size(self) -> bd.Vector:
        return self._size

    @size.setter
    def size(self, value):
        self._size = bd.Vector(value)

    @property
    def lip(self) -> bd.Vector:
        return self._lip

    @lip.setter
    def lip(self, value):
        self._lip = bd.Vector(value)

if __name__ == "__main__":
    from ocp_vscode import show
    show(MagneticConnector())