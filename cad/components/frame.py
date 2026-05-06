import typing

import build123d as bd

from common import *
import layout
from parameters import Parameters
from components.fasteners import screw_boss_vertical

class Frame(Component):
    """"""

    def __init__(
        self,
        parameters: Parameters,
        label: str = "Frame",
        **kwargs
    ):
        self.parameters = parameters
        self.outline = layout.build_plate_outline(
            self.parameters,
            edge=self.parameters.Plates.Top.edge,
            center_width=(
                self.parameters.height
                * tand(self.parameters.tent_angle)
            ),
            fillet_radius=self.parameters.Plates.Top.radius_outer
        )
        try:
            color
        except NameError:
            color = seq_to_color(self.parameters.Frame.color)
        super().__init__(label=label, color=color, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters
        with bd.BuildPart() as frame:
            bd.sweep(
                sections=layout.frame_section(
                    self.parameters,
                    self.start_loc()
                ),
                path=self.sweep_path(),
                transition=bd.Transition.ROUND
            )
            cutter = bd.sweep(
                sections=self.notch_cutter(),
                path=self.notch_path(),
            )
            bd.thicken(
                to_thicken=cutter,
                amount=-p.Frame.notch_depth,
                mode=bd.Mode.SUBTRACT
            )
            fillet_edge = frame.edges(bd.Select.NEW).sort_by(bd.SortBy.LENGTH)[-2]
            bd.fillet(
                objects=fillet_edge,
                radius=p.Frame.fillet_radius
            )
            screw_locations = bd.Locations([
                location * bd.Pos(
                    -p.Screws.M2.offset,
                    0,
                    p.Plates.Bottom.thickness - p.height
                )
                for location in layout.frame_screw_locations(self.sweep_path())
            ])
            with screw_locations:
                bd.add(screw_boss_vertical(
                    hole_depth=p.Insert.hole_depth,
                    hole_diameter=p.Insert.hole_diameter,
                    overhang_angle=p.Print.overhang_angle,
                    wall_thickness=p.Insert.wall_thickness
                ))
                bd.Cylinder(
                    radius=p.Insert.hole_diameter/2,
                    height=p.Insert.hole_depth,
                    align=Align.Bottom,
                    mode=bd.Mode.SUBTRACT
                )
            # Cut excess from ends.
            with bd.Locations(
                frame.vertices()
                .group_by(bd.Axis.Z)[-1].vertices()
                .group_by(bd.Axis.X)[-1].vertices()
                .sort_by(bd.Axis.Y)[1]
            ):
                bd.Box(
                    length=BIG,
                    width=BIG,
                    height=BIG,
                    align=Align.Left,
                    rotation=(0, p.tent_angle, 0),
                    mode=bd.Mode.SUBTRACT
                )
        return frame.part

    def _locate(self):
        p = self.parameters
        # Move the part so that the center wall is vertical and the hinge
        # pivot is along the Y axis.
        self.orientation += (0, -p.tent_angle, 0)
        self.position -= (
            self.faces()
            .group_by(bd.Axis.X)[-1].faces()
            .sort_by(bd.Axis.Y)[0].vertices()
            .group_by(bd.Axis.Z)[-1].vertices()
            .sort_by(bd.Axis.Y)[-1].center()
        )

    def notch_cutter(self) -> bd.Curve:
        p = self.parameters
        path = self.notch_path()
        loc = bd.Location(
            position=path.edges()[0].start_point(),
            orientation=(
                path.edges()
                .sort_by(bd.SortBy.LENGTH)[-1]
                .location_at(0).orientation
            )
        )
        with bd.BuildLine(loc) as cutter:
            bd.Line([(i*p.Frame.thickness, 0, 0) for i in (-2, 2)])
        return cutter.line

    def notch_path(self) -> bd.Wire:
        p = self.parameters
        arc_radius = p.Frame.notch_depth - p.Plates.Top.thickness
        straight_length = p.spacing.X/2 - arc_radius
        edges: list[bd.Edge] = []
        edges.append(
            self.outline.edges()[6].trim_to_length(
                start=0,
                length=straight_length
            )
        )
        edges.append(self.outline.edges()[7])
        edges.append(
            self.outline.edges()[8].trim_to_length(
                start=1,
                length=-straight_length
            )
        )
        arc1_plane = bd.Plane(
            origin=edges[0].end_point(),
            x_dir=edges[0].tangent_at(1),
            y_dir=(0, 0, 1)
        )
        with bd.BuildLine(arc1_plane) as arc1:
            arc = bd.CenterArc(
                center=edges[0].end_point() + (0, arc_radius, 0),
                radius=arc_radius,
                start_angle=-90,
                arc_size=90
            )
            bd.Line(
                arc.end_point(),
                arc.end_point() + (0, p.Plates.Top.thickness, 0)
            )
        for edge in arc1.edges(): edges.append(edge)
        arc2_plane = bd.Plane(
            origin=edges[2].end_point(),
            x_dir=edges[2].tangent_at(1),
            y_dir=(0, 0, 1)
        )
        with bd.BuildLine(arc2_plane) as arc2:
            arc = bd.CenterArc(
                center=edges[2].end_point() + (0, arc_radius, 0),
                radius=arc_radius,
                start_angle=-90,
                arc_size=90
            )
            bd.Line(
                arc.end_point(),
                arc.end_point() + (0, p.Plates.Top.thickness, 0)
            )
        for edge in arc2.edges(): edges.append(edge)
        return bd.Wire(edges).move(bd.Pos(0, 0, -p.Frame.notch_depth))

    def start_loc(self) -> bd.Location:
        return bd.Location(self.sweep_path().start_point())

    def sweep_path(self) -> bd.Wire:
        return bd.Wire(self.outline.edges().sort_by(bd.Axis.X)[:-1])

if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    frame = Frame(androphage.parameters, locate=False)
    show(frame)