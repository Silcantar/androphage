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
            center_width=self.parameters.Plates.Top.center_width,
            fillet_radius=self.parameters.Plates.Top.radius_outer
        )
        try:
            color
        except NameError:
            color = seq_to_color(self.parameters.Frame.color)
        super().__init__(label, color=color, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters
        with bd.BuildPart() as frame:
            bd.sweep(
                sections=self.frame_section(),
                path=self.sweep_path(),
                transition=bd.Transition.ROUND
            )

            with self.screw_locations():
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
            # Move the part so that the center wall is vertical and the hinge
            # pivot is along the Y axis.
            frame.part.orientation += (0, -p.tent_angle, 0)
            frame.part.position -= (
                frame.part.vertices()
                .group_by(bd.Axis.Z)[-1].vertices()
                .group_by(bd.Axis.X)[-1].vertices()
                .sort_by(bd.Axis.Y)[1].center()
            )
            bd.Box(
                length=1000,
                width=1000,
                height=1000,
                align=Align.Left,
                mode=bd.Mode.SUBTRACT
            )
        return frame.part

    def frame_section(self) -> bd.Sketch:
        p = self.parameters
        with bd.BuildSketch(bd.Plane.YZ.move(self.start_loc())) as sketch:
            with bd.BuildLine() as line:
                pl = bd.Polyline(
                    (p.Frame.thickness - p.Frame.lip_depth, 0),
                    (0, 0),
                    (0, p.Plates.Bottom.thickness),
                    (-p.Frame.lip_depth, p.Plates.Bottom.thickness),
                    (-p.Frame.lip_depth, p.height - p.Plates.Top.thickness),
                    (0, p.height - p.Plates.Top.thickness),
                    (0, p.height),
                    (
                        (
                            p.Frame.thickness
                            - p.Frame.lip_depth
                            - p.height*tand(p.Frame.chord_angle)
                        ),
                        p.height
                    )
                )
                bd.RadiusArc(
                    start_point=pl.start_point(),
                    end_point=pl.end_point(),
                    radius=p.Frame.main_radius
                )
            bd.make_face()
            bd.fillet(
                sketch.vertices().sort_by(bd.Axis.X)[-2:],
                radius=p.Frame.fillet_radius
            )
        return sketch.sketch

    def notch_cutter(self) -> bd.Sketch:
        p = self.parameters
        with bd.BuildSketch() as cutter:
            bd.Rectangle(
                width=p.Frame.thickness,
                height=10,
                align=Align.Front
            )
            bd.Circle(
                radius=
            )
        return cutter.sketch

    def start_loc(self) -> bd.Location:
        return bd.Location(self.sweep_path().start_point())

    def screw_locations(self) -> bd.Locations:
        p = self.parameters
        locations: list[bd.Location] = []
        for param in range(p.Frame.screw_count):
            loc = self.sweep_path().location_at(
                (param + 0.5)/p.Frame.screw_count
            ) * bd.Rot(X=90)
            # The following conditionals correct the weirdnesses of the
            # orientations produced by location_at().
            if loc.orientation.X != 0:
                loc.orientation = (0, 0, 180 - loc.orientation.Z)
            if loc.orientation.Y != 0:
                loc.orientation = (0, 0, -loc.orientation.Z)
            loc.position += (bd.Rot(loc.orientation) * bd.Pos(
                -p.Insert.diameter/2,
                0,
                p.Plates.Bottom.thickness
            )).position
            locations.append(loc)
        return bd.Locations(locations)

    def sweep_path(self) -> bd.Wire:
        return bd.Wire(self.outline.edges().sort_by(bd.Axis.X)[:-1])

if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    frame = Frame(androphage.parameters)
    show(frame)