import typing
# from math import abs

import build123d as bd

import layout
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
            with bd.BuildSketch(bd.Plane.XZ):
                bd.add(self.main_section(fillet=False))
                bd.offset(
                    objects=self.main_section(),
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
                bd.Cylinder(
                    radius=outer_radius*cosd(p.Print.overhang_angle),
                    height=p.Base.vertical_height,
                    align=Align.Bottom
                )
                bd.Sphere(
                    radius=outer_radius,
                    arc_size1=0,
                    align=Align.Bottom
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
            # Bottom opening
            with bd.BuildSketch(bd.Location((
                0,
                p.Hinge.length/2 + p.Hinge.position_y + p.Frame.lip_depth,
                -p.Base.angled_height
            ))):
                bd.RectangleRounded(
                    width=p.Base.width - 2*p.Base.foot_width,
                    height=p.Hinge.length + 2*p.Base.opening_clearance,
                    radius=p.Base.foot_width
                )
            bd.extrude(
                amount=(
                    p.Base.angled_height
                    + p.Print.wall_thickness/cosd(p.tent_angle)
                ),
                mode=bd.Mode.SUBTRACT
            )
            bd.extrude(
                to_extrude=self.main_section(fillet=True),
                amount=BIG,
                both=True,
                mode=bd.Mode.INTERSECT
            )
            with bd.Locations(
                (0, 0, 0),
                bd.Location(
                    position=(0, p.Base.depth, 0),
                    orientation=(0, 0, 180)
                )
            ):
                bd.add(self.end_cap())
        return base.part

    def _locate(self):
        pass

    def end_cap(
        self,
        fillet: bool = False
    ) -> bd.Part:
        p = self.parameters
        with bd.BuildPart() as end_cap:
            with bd.BuildSketch(bd.Location(
                position=(0, 0, -p.Base.angled_height),
                orientation=(0, 0, -90)
            )) as sketch:
                section = bd.add(
                    layout.frame_section(
                        self.parameters,
                        fillet=fillet
                    )
                )
                bd.mirror(section, about=bd.Plane.XZ)
                bd.split(bisect_by=bd.Plane.YZ, keep=bd.Keep.TOP)
                bd.fillet(
                    (
                        sketch.vertices()
                        .filter_by(lambda v: v.center().Y == 0)
                        .sort_by(bd.Axis.X)[-1]
                    ),
                    radius=p.Frame.fillet_radius
                )
                if fillet:
                    bd.fillet(
                        objects=(
                            sketch.vertices()
                            .filter_by(lambda v: v.center().Y == 0)
                            .sort_by(bd.Axis.X)[-1]
                        ),
                        radius=0.5#p.Frame.fillet_radius
                    )
            bd.extrude(amount=p.Base.height)
            bd.extrude(
                to_extrude=self.main_section(fillet=True),
                amount=BIG,
                both=True,
                mode=bd.Mode.INTERSECT
            )
            fillet_edges = (
                end_cap.edges()
                .filter_by(bd.Axis.Y, reverse=True)
                .filter_by(
                    lambda e: (
                        abs(e.center().X) > p.Frame.fillet_radius
                        or e.geom_type != bd.GeomType.LINE
                    )
                )
                .group_by(bd.Axis.Y)[:-1]
            )
            bd.fillet(
                fillet_edges,
                radius=p.Frame.fillet_radius - 10*EPS
            )
        return end_cap.part

    def main_section(
        self,
        fillet: bool = False
    ) -> bd.Sketch:
        p = self.parameters
        with bd.BuildSketch(bd.Plane.XZ) as section:
            top_point = bd.Vector(0, p.Base.vertical_height)
            bottom_point = bd.Vector(p.Base.width/2, -p.Base.angled_height)
            bottom_inner_point = bottom_point + bd.Vector(-p.Base.foot_width, 0)
            with bd.BuildLine() as outline:
                bd.Polyline(
                    (0, 0),
                    bottom_inner_point,
                    bottom_point,
                    bottom_point + bd.Vector(0, p.Base.vertical_height),
                    top_point
                )
                bd.mirror(bd.Wire(outline.line), about=bd.Plane.YZ)
            bd.make_face()
            if fillet:
                bd.fillet(section.vertices(), radius=p.Frame.fillet_radius)
        return section.sketch


if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    base = Base(androphage.parameters)
    show(
        base,
        # base.loft_sections(),
        # base.end_cap(),
    )