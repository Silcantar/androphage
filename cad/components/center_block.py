import typing

import build123d as bd

from common import *
import btu

class CenterBlock(Component):
    """The center block of the Androphage case."""

    def __init__(
        self,
        outline: bd.Sketch,
        color: bd.ColorLike = "MediumPurple",
        label: str = "Center Block",
        btu_model: callable = btu.BTU_VCN310, # btu.BTU_Rexroth, #
        btu_angles: bd.VectorLike = (0, 30, 45),
        btu_diameter: float = 7.5, # 17, #
        btu_height: float = 6.1, # 11.2, #
        height_: float = 21,
        screw_diameter: float = 2,
        tent_angle: float = 7,
        trackball_clearance: float = 1,
        trackball_position_y: float = 70,
        trackball_radius: float = 17.5,
        wall_thickness: float = 2,
        **kwargs
    ):
        self.outline = outline
        self.btu_model = btu_model
        self.btu_angles = bd.Vector(btu_angles)
        self.btu_diameter = btu_diameter
        self.btu_height = btu_height
        self.height_ = height_
        self.screw_diameter = screw_diameter
        self.tent_angle = tent_angle
        self.trackball_clearance = trackball_clearance
        self.trackball_position_y = trackball_position_y
        self.trackball_radius = trackball_radius
        self.wall_thickness = wall_thickness
        super().__init__(label, color=color, **kwargs)

    def _build(self) -> bd.Part:
        with bd.BuildPart() as center_block:
            # Add Center Wall.
            bd.add(self.center_wall())
            # Add trackball case.
            with self.trackball_locations():
                bd.Sphere(
                    radius=(
                        self.trackball_radius
                        + self.trackball_clearance
                        + self.wall_thickness
                    ),
                    arc_size3=90 - self.tent_angle,
                    align=Align.LeftFront
                )
            with self.btu_locations():
                bd.add(self.btu_socket())
                self.btu_model(
                    subtract=True,
                    rotation=(180, 0, 0),
                    mode=bd.Mode.SUBTRACT
                )
            with self.trackball_locations():
                # Subtract trackball clearance.
                bd.Sphere(
                    radius=self.trackball_radius + self.trackball_clearance,
                    mode=bd.Mode.SUBTRACT
                )
        return center_block.part

    def btu_locations(self) -> bd.Locations:
        return bd.Locations([
            self.trackball_position()
            * bd.Rot(0, 0, z_angle)
            * bd.Rot(0, -90 - self.btu_angles.Y, 0)
            * bd.Pos(0, 0, self.trackball_radius)
            for z_angle in (-self.btu_angles.Z, self.btu_angles.Z)
        ])

    def btu_socket(self) -> bd.Part:
        with bd.BuildPart() as btu_socket:
            bd.Cylinder(
                radius=self.btu_diameter/2 + self.wall_thickness,
                height=(
                    self.btu_height
                    + self.wall_thickness
                ),
                align=Align.Bottom
            )
            bd.Cylinder(
                radius=self.screw_diameter/2,
                height=self.btu_height + self.wall_thickness,
                align=Align.Bottom,
                mode=bd.Mode.SUBTRACT
            )
        # btu_socket.part.position += (0, 0, self.trackball_clearance)
        return btu_socket.part

    def center_wall(self) -> bd.Part:
        with bd.BuildPart() as self.center_wall:
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
            outer_face = self.center_wall.faces().sort_by(bd.Axis.X)[0]
            # Subtract the volume between the reinforcing ribs.
            with bd.BuildSketch(outer_face) as rib_sketch:
                bd.project(outer_face)
                bd.offset(amount=-self.wall_thickness)
            bd.extrude(
                amount=self.wall_thickness,
                dir=(1, 0, 0),
                mode=bd.Mode.SUBTRACT
            )
        return self.center_wall.part

    def trackball_locations(self) -> bd.Locations:
        return bd.Locations(
            self.trackball_position()
            * bd.Rot(-90, 0, 90 + self.tent_angle)
        )

    def trackball_position(self) -> bd.Location:
        return bd.Location(
            self.center_wall
            .vertices().group_by(bd.Axis.X)[-1]
            .vertices().group_by(bd.Axis.Z)[-1]
            .vertices().sort_by(bd.Axis.Y)[0]
            .move(bd.Pos(0, self.trackball_position_y, 0))
        )

if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    show(CenterBlock(androphage.build_plate_outline(edge=5)))