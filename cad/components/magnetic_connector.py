import typing

import build123d as bd

from common import *
from parameters import Parameters

class MagneticConnector(Component):
    """12-pin magnetic pogo pin connector."""

    def __init__(
        self,
        parameters: Parameters,
        label: str = "Magnetic Connector",
        **kwargs
    ):
        self.parameters = parameters
        try:
            color
        except NameError:
            color = seq_to_color(self.parameters.MagneticConnector.color)
        super().__init__(label, color=color, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters.MagneticConnector
        size = bd.Vector(p.size)
        lip = bd.Vector(p.lip)
        with bd.BuildPart() as mag_con:
            with bd.BuildSketch(bd.Plane.YZ) as main_sketch:
                bd.RectangleRounded(
                    width=size.Y,
                    height=size.Z,
                    radius=size.Z/2 - EPS
                )
            bd.extrude(amount=size.X, dir=(-1, 0, 0))
            lip_plane = bd.Plane.YZ.move(bd.Pos(-p.lip_offset, 0, 0))
            with bd.BuildSketch(lip_plane) as lip_sketch:
                bd.RectangleRounded(
                    width=lip.Y,
                    height=lip.Z,
                    radius=lip.Z/2 - EPS
                )
            bd.extrude(amount=lip.X, dir=(-1, 0, 0))
        return mag_con.part


if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    show(MagneticConnector(androphage.parameters))