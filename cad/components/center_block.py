import typing

import build123d as bd

from common import *

class CenterBlock(Component):
    """The center block of the Androphage case."""

    def __init__(
        self,
        outline: bd.Sketch,
        color: bd.ColorLike = "CornflowerBlue",
        label: str = "Center Block",
        h: float = 20,
        wall_thickness: float = 2,
        **kwargs
    ):
        self.outline = outline
        self.wall_thickness = wall_thickness
        self.h: float = h
        super().__init__(label, color=color, **kwargs)

    def build(self) -> bd.Part:
        with bd.BuildPart() as part:
            with bd.BuildSketch() as sketch:
                outline = bd.add(self.outline, mode=bd.Mode.PRIVATE)
                edge = outline.edges().sort_by(bd.Axis.X)[-1]
                bd.add(bd.Face.extrude(edge, (-self.wall_thickness, 0)))
            bd.extrude(amount=self.h)
        return part.part

if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    show(CenterBlock(androphage.build_plate_outline(edge=5)))