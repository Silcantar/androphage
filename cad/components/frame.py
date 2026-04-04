import typing

import build123d as bd

from common import *
from parameters import Parameters
from components.fasteners import screw_boss_vertical

class Frame(Component):
    """"""

    def __init__(
        self,
        outline: bd.Sketch,
        parameters: Parameters,
        height_: float = 20,
        label: str = "Frame",
        **kwargs
    ):
        self.outline = outline
        self.parameters = parameters
        self.height_ = height_
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
                    overhang_angle=p.overhang_angle,
                    wall_thickness=p.Insert.wall_thickness
                ))
                bd.Cylinder(
                    radius=p.Insert.hole_diameter/2,
                    height=p.Insert.hole_depth,
                    align=Align.Bottom,
                    mode=bd.Mode.SUBTRACT
                )
            # Move the part so that the center wall is vertical and the hinge pivot
            # is along the Y axis.
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
                    (-p.Frame.lip_depth, self.height_ - p.Plates.Top.thickness),
                    (0, self.height_ - p.Plates.Top.thickness),
                    (0, self.height_),
                    (
                        (
                            p.Frame.thickness
                            - p.Frame.lip_depth
                            - self.height_*tand(p.Frame.chord_angle)
                        ),
                        self.height_
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

    def start_loc(self) -> bd.Location:
        return bd.Location(self.sweep_path().start_point())

    def screw_locations(self) -> bd.Locations:
        p = self.parameters
        return bd.Locations([
            self.sweep_path().location_at(
                (param + 0.5)/p.Frame.screw_count,
                frame_method=bd.FrameMethod.CORRECTED
            )
            * bd.Rot(X=90, Y=-90)
            * bd.Pos(-p.Insert.hole_diameter/2, 0, p.Plates.Bottom.thickness)
            for param in range(p.Frame.screw_count)
        ])

    def sweep_path(self) -> bd.Wire:
        return bd.Wire(self.outline.edges().sort_by(bd.Axis.X)[:-1])

if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    center_width = 20*tand(7)
    frame = Frame(
        androphage.build_plate_outline(
            edge=5,
            center_width=center_width
        ),
        androphage.parameters
    )
    show(frame)