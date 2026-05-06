import typing

import build123d as bd

from common import *
from parameters import Parameters

class Base(Component):
    """"""

    def __init__(
        self,
        parameters: Parameters,
        label: str = "Base",
        **kwargs
    ):
        self.parameters = parameters
        try:
            color
        except NameError:
            color = seq_to_color(self.parameters.Base.color)
        super().__init__(label=label, color=color, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters
        with bd.BuildPart() as base:
            with bd.BuildSketch(bd.Plane.XZ.move(bd.Pos(Y=-p.Base.offset))):
                bd.add(self.profile())
                bd.offset(
                    objects=self.profile(),
                    amount=-p.Print.wall_thickness,
                    mode=bd.Mode.SUBTRACT
                )
            bd.extrude(
                amount=p.Base.depth,
                dir=(0, 1, 0)
            )
            with bd.Locations((0, p.Trackball.position_y, 0)):
                inner_radius = p.Trackball.diameter/2 + p.Trackball.clearance
                outer_radius = inner_radius + p.Print.wall_thickness
                bd.Sphere(
                    radius=outer_radius
                )
                bd.Cylinder(
                    radius=outer_radius,
                    height=p.Base.angled_height,
                    align=Align.Top
                )
                bd.Sphere(
                    radius=inner_radius,
                    mode=bd.Mode.SUBTRACT
                )
                bd.Cylinder(
                    radius=inner_radius,
                    height=BIG,
                    align=Align.Top,
                    mode=bd.Mode.SUBTRACT
                )
            bd.extrude(
                to_extrude=self.profile(),
                amount=BIG,#-p.Base.depth,
                both=True,
                mode=bd.Mode.INTERSECT
            )
        return base.part

    def _locate(self):
        pass

    def profile(self) -> bd.Sketch:
        p = self.parameters
        with bd.BuildSketch(bd.Plane.XZ) as sketch:
            top_point = bd.Vector(0, p.Base.vertical_height)
            bottom_point = bd.Vector(p.Base.width/2, -p.Base.angled_height)
            bottom_inner_point = bottom_point + bd.Vector(-p.Base.foot_width, 0)
            with bd.BuildLine() as outline:
                bd.Wire(bd.Polyline(
                    (0, 0),
                    bottom_inner_point,
                    bottom_point,
                    bottom_point + bd.Vector(0, p.Base.vertical_height),
                    top_point
                ))
            bd.mirror(outline.line, about=bd.Plane.YZ)
            bd.make_face()
            bd.fillet(sketch.vertices(), radius=p.Frame.fillet_radius)
        return sketch.sketch

if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    base = Base(androphage.parameters)
    show(
        base,
        # base.profile()
    )