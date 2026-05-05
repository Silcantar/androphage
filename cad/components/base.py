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
        super().__init__(label=label, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters
        self.angled_height = p.Base.width*tand(p.tent_angle)/2
        self.vertical_height = p.Base.height - self.angled_height
        with bd.BuildPart() as base:
            with bd.Locations((0, -p.Base.offset, 0)):
                bd.add(self.sketch(hollow=True))
                bd.extrude(
                    amount=p.Base.depth,
                    dir=(0, 1, 0)
                )
            with bd.Locations((
                0,
                p.Trackball.position_y,
                -self.vertical_height
            )):
                inner_radius = p.Trackball.diameter/2 + p.Trackball.clearance
                outer_radius = inner_radius + p.Print.wall_thickness
                bd.Sphere(
                    radius=outer_radius
                )
                bd.Cylinder(
                    radius=outer_radius,
                    height=self.angled_height,
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
            # bd.extrude(
            #     to_extrude=self.sketch(),
            #     amount=BIG,#-p.Base.depth,
            #     both=True,
            #     mode=bd.Mode.INTERSECT
            # )
        return base.part

    def _locate(self):
        pass

    def sketch(self) -> bd.Sketch:
        p = self.parameters
        with bd.BuildSketch(bd.Plane.XZ) as sketch:
            with bd.BuildLine():
                top_line = bd.PolarLine(
                    start=(0, 0),
                    length=p.Base.width/cosd(p.tent_angle)/2,
                    angle=-p.tent_angle
                )
                center_line = bd.PolarLine(
                    start=top_line.start_point(),
                    length=self.vertical_height,
                    direction=(0, -1)
                )
                outer_line = bd.PolarLine(
                    start=top_line.end_point(),
                    length=self.vertical_height,
                    direction=(0, -1)
                )
                bottom_line = bd.Line(
                    center_line.end_point(),
                    outer_line.end_point()
                )
            bd.make_face()
        return bd.Sketch([
            sketch.sketch,
            bd.mirror(sketch.sketch, about=bd.Plane.YZ)
        ])

if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    base = Base(androphage.parameters)
    show(base, base.sketch())