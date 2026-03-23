import typing

import build123d as bd

from common import *

class CenterBlock(Component):
    """The center block of the Androphage case."""

    def __init__(
        self,
        outline: bd.Sketch,
        color: bd.ColorLike = "MediumPurple",
        label: str = "Center Block",
        height_: float = 21, # Height
        tent_angle: float = 7,
        trackball_clearance: float = 1,
        trackball_position_y: float = 70,
        trackball_radius: float = 17.5,
        wall_thickness: float = 2,
        **kwargs
    ):
        self.outline = outline
        self.height_ = height_
        self.tent_angle = tent_angle
        self.trackball_clearance = trackball_clearance
        self.trackball_position_y = trackball_position_y
        self.trackball_radius = trackball_radius
        self.wall_thickness = wall_thickness
        super().__init__(label, color=color, **kwargs)

    def build(self) -> bd.Part:
        with bd.BuildPart() as center_block:
            bd.add(self.center_wall())
        return center_block.part

    def center_wall(self) -> bd.Part:
        with bd.BuildPart() as center_wall:
            with bd.BuildSketch() as sketch:
                outline = bd.add(self.outline, mode=bd.Mode.PRIVATE)
                # Extrude the center edge of the outline into a rectangle.
                edge = outline.edges().sort_by(bd.Axis.X)[-1]
                bd.add(bd.Face.extrude(edge, (-2*self.wall_thickness, 0)))
            bd.extrude(
                amount=self.height_,
                dir=(
                    sind(self.tent_angle),
                    0,
                    cosd(self.tent_angle)
                )
            )
            outer_face = center_wall.faces().sort_by(bd.Axis.X)[0]
            # Subtract the volume between the reinforcing ribs.
            with bd.BuildSketch(outer_face) as rib_sketch:
                bd.project(outer_face)
                bd.offset(amount=-self.wall_thickness)
            bd.extrude(
                amount=self.wall_thickness,
                dir=(1, 0, 0),
                mode=bd.Mode.SUBTRACT
            )
            # Add trackball case.
            trackball_loc = bd.Location(
                center_wall
                .vertices().group_by(bd.Axis.X)[-1]
                .vertices().group_by(bd.Axis.Z)[-1]
                .vertices().sort_by(bd.Axis.Y)[0]
                .move(bd.Pos(0, self.trackball_position_y, 0))
            )
            trackball_loc.orientation += (-90, 0, 90 + self.tent_angle)
            with bd.Locations(trackball_loc):
                bd.Sphere(
                    radius=(
                        self.trackball_radius
                        + self.trackball_clearance
                        + self.wall_thickness
                    ),
                    arc_size3=90 - self.tent_angle,
                    align=Align.LeftFront
                )
                # Subtract trackball clearance.
                bd.Sphere(
                    radius=self.trackball_radius + self.trackball_clearance,
                    mode=bd.Mode.SUBTRACT
                )
        return center_wall.part


if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    show(CenterBlock(androphage.build_plate_outline(edge=5)))