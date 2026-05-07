import typing

import build123d as bd

import layout
from common import *
from parameters import Parameters

class BaseComplex(Component):
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
            with bd.Locations(
                (0, 0, 0),
                bd.Location(
                    position=(0, p.Base.depth, 0),
                    orientation=(0, 0, 180)
                )
            ):
                bd.add(self.end_cap())
            bd.extrude(
                to_extrude=self.main_section(fillet=True),
                amount=BIG,
                both=True,
                mode=bd.Mode.INTERSECT
            )
            # bd.fillet(
            #     (
            #         base.part.edges()
            #         .filter_by(lambda e: e.center().Y < 0)
            #         .filter_by(bd.Axis.Y, reverse=True)
            #     ),
            #     radius=EPS#p.Frame.fillet_radius
            # )
        return base.part

    def _locate(self):
        pass

    def end_cap(self) -> bd.Part:
        p = self.parameters
        with bd.BuildPart() as end_cap:
            loft = bd.split(
                bd.loft(
                    self.loft_sections(),
                    ruled=True
                ),
                bisect_by=bd.Plane.YZ,
                keep=bd.Keep.BOTTOM
            )
            loft_mirrored = bd.mirror(loft, about=bd.Plane.YZ)
            bd.split(
                bisect_by=bd.Plane.XZ.move(bd.Pos(0, p.Frame.lip_depth, 0)),
                keep=bd.Keep.TOP
            )
        return end_cap.part

    def loft_planes(self) -> list[bd.Plane]:
        p = self.parameters
        main_section = self.main_section()
        return [
            bd.Plane.XY.move(bd.Location(
                position=(0, 0, -p.Base.angled_height),
                orientation=(0, 0, -90))
            ),
            bd.Plane(
                origin=(0, 0, p.Base.vertical_height),
                x_dir=(0, -1, 0),
                y_dir=(p.Base.width/2, 0, p.Base.height)
            ),
            bd.Plane(
                origin=(
                    main_section.vertices()
                    .filter_by(lambda v: v.center().X < 0 and v.center().Z > 0)
                    .center()
                ),
                x_dir=(0, -1, 0),
                z_dir=(-cosd(p.Frame.chord_angle), 0, sind(p.Frame.chord_angle))
            )
        ]

    def loft_sections(self) -> list[bd.Sketch]:
        p = self.parameters
        with bd.BuildSketch() as root_section:
            bd.add(layout.frame_section(self.parameters, fillet=False))
            bd.Rectangle(
                width=BIG,
                height=BIG,
                align=Align.Right,
                mode=bd.Mode.SUBTRACT
            )
        section_width = root_section.face().length
        section_height = root_section.face().width
        sections: list[bd.Sketch] = []
        planes = self.loft_planes()
        heights = [
            p.Base.width/2,
            bd.Vector(p.Base.width/2, p.Base.height).length,
            (
                planes[2].origin
                - bd.Vector(
                    -p.Base.width/2,
                    0,
                    -p.Base.angled_height
                )
            ).length
        ]
        for (plane, height) in zip(planes, heights):
            with bd.BuildSketch(plane) as section:
                bd.add(layout.frame_section(
                    self.parameters,
                    height=height,
                    fillet=True
                ))
                # bd.scale(
                #     objects=root_section.face(),
                #     by=scale
                # )
            sections.append(section.sketch)
        return sections


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
                bottom_lines = bd.Polyline(
                    (0, 0),
                    bottom_inner_point,
                    bottom_point,
                )
                top_line_const = bd.PolarLine(
                    start=top_point,
                    length=BIG,
                    angle=-p.tent_angle,
                    mode=bd.Mode.PRIVATE
                )
                outer_line_const = bd.IntersectingLine(
                    start=bottom_lines.end_point(),
                    direction=(
                        -sind(p.Frame.chord_angle),
                        cosd(p.Frame.chord_angle)
                    ),
                    other=top_line_const,
                    mode=bd.Mode.PRIVATE
                )
                top_line = bd.Line(top_point, outer_line_const.end_point())
                outer_arc = bd.RadiusArc(
                    start_point=top_line.end_point(),
                    end_point=bottom_lines.end_point(),
                    radius=-p.Frame.main_radius
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