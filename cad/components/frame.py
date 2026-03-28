import typing

import build123d as bd

from common import *
from fasteners import screw_boss_vertical

class Frame(Component):
    """"""

    def __init__(
        self,
        outline: bd.Sketch,
        chord_angle: float = 4,
        fillet_radius: float = 1,
        height_: float = 20,
        insert_hole_depth: float = 4,
        insert_hole_diameter: float = 2.8,
        insert_wall_thickness: float = 1.6,
        lip_depth: float = 1,
        main_radius: float = 50,
        notch_depth: float = 6,
        overhang_angle: float = 45,
        plate_thickness: float = 1.2,
        screw_count: int = 5,
        thickness: float = 5,
        label: str = "Frame",
        **kwargs
    ):
        self.outline = outline
        self.chord_angle = chord_angle
        self.fillet_radius = fillet_radius
        self.height_ = height_
        self.insert_hole_depth = insert_hole_depth
        self.insert_hole_diameter = insert_hole_diameter
        self.insert_wall_thickness = insert_wall_thickness
        self.lip_depth = lip_depth
        self.main_radius = main_radius
        self.notch_depth = notch_depth
        self.overhang_angle = overhang_angle
        self.plate_thickness = plate_thickness
        self.screw_count = screw_count
        self.thickness = thickness
        super().__init__(label, **kwargs)

    def sweep_path(self) -> bd.Wire:
        return bd.Wire(self.outline.edges().sort_by(bd.Axis.X)[:-1])

    def start_loc(self) -> bd.Location:
        return bd.Location(self.sweep_path().start_point())

    def _build(self) -> bd.Part:
        with bd.BuildPart() as frame:
            bd.sweep(
                sections=self.frame_section(),
                path=self.sweep_path(),
                transition=bd.Transition.ROUND
            )
            with self.screw_locations():
                bd.add(screw_boss_vertical(
                    hole_depth=self.insert_hole_depth,
                    hole_diameter=self.insert_hole_diameter,
                    overhang_angle=self.overhang_angle,
                    wall_thickness=self.insert_wall_thickness
                ))
                bd.Cylinder(
                    radius=self.insert_hole_diameter/2,
                    height=self.insert_hole_depth,
                    align=Align.Bottom,
                    mode=bd.Mode.SUBTRACT
                )
        return frame.part

    def frame_section(self) -> bd.Sketch:
        with bd.BuildSketch(bd.Plane.YZ.move(self.start_loc())) as sketch:
            with bd.BuildLine() as line:
                pl = bd.Polyline(
                    (self.thickness - self.lip_depth, 0),
                    (0, 0),
                    (0, self.plate_thickness),
                    (-self.lip_depth, self.plate_thickness),
                    (-self.lip_depth, self.height_ - self.plate_thickness),
                    (0, self.height_ - self.plate_thickness),
                    (0, self.height_),
                    (
                        (
                            self.thickness
                            - self.lip_depth
                            - self.height_*tand(self.chord_angle)
                        ),
                        self.height_
                    )
                )
                bd.RadiusArc(
                    start_point=pl.start_point(),
                    end_point=pl.end_point(),
                    radius=self.main_radius
                )
            bd.make_face()
            bd.fillet(
                sketch.vertices().sort_by(bd.Axis.X)[-2:],
                radius=self.fillet_radius
            )
        return sketch.sketch

    def screw_locations(self) -> bd.Locations:
        return bd.Locations([
            self.sweep_path().location_at(
                (param + 0.5)/self.screw_count,
                frame_method=bd.FrameMethod.CORRECTED
            )
            * bd.Rot(X=90)
            * bd.Pos(-self.insert_hole_diameter/2, 0, self.plate_thickness)
            for param in range(self.screw_count)
        ])

if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    frame = Frame(androphage.build_plate_outline(edge=5))
    show(frame)