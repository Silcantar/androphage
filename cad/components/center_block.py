import typing

import build123d as bd

from common import *
import btu
from magnetic_connector import MagneticConnector
from trackball_sensor import TrackballSensor

class CenterBlock(Component):
    """The center block of the Androphage case."""

    def __init__(
        self,
        outline: bd.Sketch,
        color: bd.ColorLike = "MediumPurple",
        label: str = "Center Block",
        btu_model: callable = btu.BTU_VCN310,
        btu_angles: bd.VectorLike = (0, 30, 47),
        btu_diameter: float = 7.5,
        btu_height: float = 6.1,
        connector_position_y: float = 25,
        connector_screw_offset: float = 18,
        height_: float = 20,
        insert_hole_depth: float = 4,
        insert_hole_diameter: float = 2.8,
        insert_wall_thickness: float = 1.6,
        overhang_angle: float = 45,
        sensor_angle: float = 60,
        sensor_height: float = 7,
        sensor_holder_height: float = 15,
        sensor_holder_thickness: float = 5,
        sensor_pcb_size: bd.VectorLike = (16, 25, 1.2),
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
        self.connector_position_y = connector_position_y
        self.connector_screw_offset = connector_screw_offset
        self.height_ = height_
        self.insert_hole_depth = insert_hole_depth
        self.insert_hole_diameter = insert_hole_diameter
        self.insert_wall_thickness = insert_wall_thickness
        self.overhang_angle = overhang_angle
        self.sensor_angle = sensor_angle
        self.sensor_height = sensor_height
        self.sensor_holder_height = sensor_holder_height
        self.sensor_holder_thickness = sensor_holder_thickness
        self.sensor_pcb_size = bd.Vector(sensor_pcb_size)
        self.tent_angle = tent_angle
        self.trackball_clearance = trackball_clearance
        self.trackball_position_y = trackball_position_y
        self.trackball_radius = trackball_radius
        self.wall_thickness = wall_thickness
        super().__init__(label, color=color, **kwargs)

    def _build(self) -> bd.Part:
        with bd.BuildPart() as center_block:
            # ---- Additions ----
            # Add center wall.
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
            # Add trackball sensor holder.
            with self.sensor_locations():
                sensor_holder = bd.add(self.sensor_holder())
            # Eliminate some of the overhang of the sensor holder when it is
            # printed upside-down.
            bd.extrude(
                to_extrude=sensor_holder.faces().sort_by(bd.Axis.Z)[-1],
                dir=(0, 0, 1),
                amount=10
            )
            # Add BTU sockets.
            with self.btu_locations():
                bd.add(self.btu_socket())
            with self.screw_locations():
                bd.add(self.screw_boss())
            with self.connector_screw_locations():
                Tube(
                    radius_outer=self.insert_hole_diameter/2 + self.insert_wall_thickness,
                    radius_inner=self.insert_hole_diameter/2,
                    height_=self.insert_hole_depth,
                    align=Align.Top
                )
            # ---- Subtractions ----
            # Subtract trackball sensor from holder.
            with self.sensor_locations():
                TrackballSensor(
                    subtract=True,
                    mode=bd.Mode.SUBTRACT
                )
            # Subtract BTU from socket.
            with self.btu_locations():
                self.btu_model(
                    subtract=True,
                    rotation=(180, 0, 0),
                    mode=bd.Mode.SUBTRACT
                )
            # Subtract trackball clearance.
            with self.trackball_locations():
                bd.Sphere(
                    radius=self.trackball_radius + self.trackball_clearance,
                    mode=bd.Mode.SUBTRACT
                )
            # Subtract cutout for magnetic connector.
            with self.connector_locations():
                MagneticConnector(mode=bd.Mode.SUBTRACT)
            # Subtract holes for heat-sink inserts.
            with self.screw_locations():
                bd.Cylinder(
                    radius=self.insert_hole_diameter/2,
                    height=self.insert_hole_depth,
                    align=Align.Bottom,
                    mode=bd.Mode.SUBTRACT
                )
            # Clip off anything extending outside the proper height of the part.
            bd.Box(
                length=1000,
                width=1000,
                height=self.height_,
                align=Align.LeftBottom,
                mode=bd.Mode.INTERSECT
            )
        # Move the part so that the center wall is vertical and the hinge pivot
        # is along the Y axis.
        center_block.part.orientation += (0, -self.tent_angle, 0)
        center_block.part.position -= (
            center_block.part.vertices()
            .group_by(bd.Axis.Z)[-1].vertices()
            .group_by(bd.Axis.Y)[0].vertices()
            .sort_by(bd.Axis.X)[-1].center()
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
        return btu_socket.part

    def center_wall(self) -> bd.Part:
        with bd.BuildPart() as self.center_wall:
            with bd.BuildSketch() as sketch:
                outline = bd.add(self.outline, mode=bd.Mode.PRIVATE)
                # Extrude the center edge of the outline into a rectangle.
                edge = outline.edges().sort_by(bd.Axis.X)[-1]
                bd.add(bd.Face.extrude(edge, (-2*self.wall_thickness, 0)))
            extrude_amount = self.height_ / cosd(self.tent_angle)
            bd.extrude(
                amount=extrude_amount,
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
            # Draft the overhanging face (when printed upside-down) to eliminate
            # the need for supports.
            bd.draft(
                faces=self.center_wall.faces(bd.Select.LAST).sort_by(bd.Axis.Z)[0],
                neutral_plane=bd.Plane(self.center_wall.faces().sort_by(bd.Axis.X)[0]),
                angle=self.overhang_angle
            )
        return self.center_wall.part

    def connector_locations(self) -> bd.Locations:
        return bd.Locations(
            bd.Location(
                self.center_wall.edges()
                .group_by(bd.Axis.Y)[0].edges()
                .sort_by(bd.Axis.X)[-1].center()
            )
            * bd.Rot(0, self.tent_angle, 0)
            * bd.Pos(0, self.connector_position_y, 0)
        )

    def connector_screw_locations(self) -> bd.Locations:
        return bd.Locations([
            self.connector_locations().locations[0]
            * bd.Rot(Y=90)
            * bd.Pos(0, y_pos, -self.wall_thickness)
            for y_pos in (-self.connector_screw_offset, self.connector_screw_offset)
        ])

    def origin_point(self) -> bd.Location:
        return bd.Location(
            self.center_wall.faces()
            .sort_by(bd.Axis.Y)[0].vertices()
            .group_by(bd.Axis.X)[-1].vertices()
            .sort_by(bd.Axis.Z)[-1].center()
        )

    def screw_boss(self) -> bd.Part:
        with bd.BuildPart() as boss:
            width = self.insert_hole_diameter + 2*self.insert_wall_thickness
            with bd.BuildSketch() as sketch:
                bd.Rectangle(
                    width=width/2,
                    height=width,
                    align=Align.Left
                )
                bd.Circle(radius=width/2)
            bd.extrude(
                amount=(
                    self.insert_hole_depth
                    + self.insert_wall_thickness
                    + width*tand(self.overhang_angle)
                ),
            )
            bd.draft(
                faces=boss.faces().sort_by(bd.Axis.Z)[-1],
                neutral_plane=bd.Plane(boss.faces().sort_by(bd.Axis.X)[-1]),
                angle=-self.overhang_angle
            )
        return boss.part

    def screw_locations(self) -> bd.Locations:
        # Radius of the screw boss.
        offset = self.insert_hole_diameter/2 + self.insert_wall_thickness
        # Select the bottom outside edge of the center wall.
        edge = (
            self.center_wall.edges()
            .group_by(bd.Axis.Z)[0].edges()
            .sort_by(bd.Axis.X)[-1]
        )
        # Put locations in the center and inset from each end of the edge.
        return bd.Locations([
            edge.start_point() + (-offset, -offset, 0),
            edge.center() + (-offset, 0, 0),
            edge.end_point() + (-offset, offset, 0)
        ])

    def sensor_holder(self) -> bd.Part:
        with bd.BuildPart() as holder:
            bd.Box(
                length=self.sensor_pcb_size.X + 2*self.wall_thickness,
                width=self.sensor_holder_thickness,
                height=self.sensor_holder_height,
                align=Align.Top
            )
            bd.Box(
                length=self.sensor_holder_thickness,
                width=self.sensor_pcb_size.Y + 2*self.wall_thickness,
                height=self.sensor_holder_height,
                align=Align.Top
            )
        holder.part.move(bd.Pos(0, 0, self.sensor_height))
        return holder.part

    def sensor_locations(self) -> bd.Locations:
        return bd.Locations(
            self.trackball_position()
            * bd.Rot(0, 180 + self.sensor_angle, 0)
            * bd.Pos(0, 0, self.trackball_radius)
        )

    def trackball_locations(self) -> bd.Locations:
        return bd.Locations(
            self.trackball_position()
            * bd.Rot(-90, 0, 90 + self.tent_angle)
        )

    def trackball_position(self) -> bd.Location:
        return bd.Location(
            self.origin_point()
            * bd.Pos(0, self.trackball_position_y, 0)
        )


if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    show(CenterBlock(androphage.build_plate_outline(edge=5)))