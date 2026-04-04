import typing

import build123d as bd

from common import *
from parameters import Parameters
from components.btu import BTU
from components.fasteners import screw_boss_vertical
from components.magnetic_connector import MagneticConnector
from components.trackball_sensor import TrackballSensor

class CenterBlock(Component):
    """The center block of the Androphage case."""

    def __init__(
        self,
        outline: bd.Sketch,
        parameters: Parameters,
        label: str = "Center Block",
        height_: float = 20,
        **kwargs
    ):
        self.outline = outline
        self.parameters = parameters
        self.height_ = height_
        try:
            color
        except NameError:
            color = seq_to_color(self.parameters.CenterBlock.color)
        super().__init__(label, color=color, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters
        with bd.BuildPart() as center_block:
            # ---- Additions ----
            # Add center wall.
            bd.add(self.center_wall())
            # Add trackball case.
            with self.trackball_locations():
                bd.Sphere(
                    radius=(
                        p.Trackball.diameter/2
                        + p.Trackball.clearance
                        + p.CenterBlock.wall_thickness
                    ),
                    arc_size3=90 - p.tent_angle,
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
                bd.add(screw_boss_vertical(
                    hole_depth=p.Insert.hole_depth,
                    hole_diameter=p.Insert.hole_diameter,
                    overhang_angle=p.overhang_angle,
                    wall_thickness=p.Insert.wall_thickness
                ))
            with self.connector_screw_locations():
                Tube(
                    radius_outer=p.Insert.hole_diameter/2 + p.Insert.wall_thickness,
                    radius_inner=p.Insert.hole_diameter/2,
                    height_=p.Insert.hole_depth,
                    align=Align.Top
                )
            # ---- Subtractions ----
            # Subtract trackball sensor from holder.
            with self.sensor_locations():
                TrackballSensor(
                    parameters=self.parameters,
                    mode=bd.Mode.SUBTRACT
                )
            # Subtract BTU from socket.
            with self.btu_locations():
                BTU(
                    parameters=self.parameters,
                    subtract=True,
                    rotation=(180, 0, 0),
                    mode=bd.Mode.SUBTRACT
                )
            # Subtract trackball clearance.
            with self.trackball_locations():
                bd.Sphere(
                    radius=p.Trackball.diameter/2 + p.Trackball.clearance,
                    mode=bd.Mode.SUBTRACT
                )
            # Subtract cutout for magnetic connector.
            with self.connector_locations():
                MagneticConnector(self.parameters, mode=bd.Mode.SUBTRACT)
            # Subtract holes for heat-sink inserts.
            with self.screw_locations():
                bd.Cylinder(
                    radius=p.Insert.hole_diameter/2,
                    height=p.Insert.hole_depth,
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
        center_block.part.orientation += (0, -p.tent_angle, 0)
        center_block.part.position -= (
            center_block.part.vertices()
            .group_by(bd.Axis.Z)[-1].vertices()
            .group_by(bd.Axis.Y)[0].vertices()
            .sort_by(bd.Axis.X)[-1].center()
            + (0, 0, p.Plates.Top.thickness * cosd(p.tent_angle))
        )
        return center_block.part

    def btu_locations(self) -> bd.Locations:
        p = self.parameters
        btu_angles = bd.Vector(p.CenterBlock.btu_angles)
        return bd.Locations([
            self.trackball_position()
            * bd.Rot(0, 0, z_angle)
            * bd.Rot(0, -90 - btu_angles.Y, 0)
            * bd.Pos(0, 0, p.Trackball.diameter/2)
            for z_angle in (-btu_angles.Z, btu_angles.Z)
        ])

    def btu_socket(self) -> bd.Part:
        p = self.parameters
        with bd.BuildPart() as btu_socket:
            bd.Cylinder(
                radius=(
                    p.BTU.housing_diameter/2 +
                    p.CenterBlock.wall_thickness
                ),
                height=(
                    p.BTU.ball_height
                    + p.BTU.flange_height
                    + p.BTU.housing_height
                    + p.CenterBlock.wall_thickness
                ),
                align=Align.Bottom
            )
        return btu_socket.part

    def center_wall(self) -> bd.Part:
        p = self.parameters
        with bd.BuildPart() as self.center_wall:
            with bd.BuildSketch() as sketch:
                outline = bd.add(self.outline, mode=bd.Mode.PRIVATE)
                # Extrude the center edge of the outline into a rectangle.
                edge = outline.edges().sort_by(bd.Axis.X)[-1]
                bd.add(bd.Face.extrude(
                    edge,
                    (-2*p.CenterBlock.wall_thickness, 0)
                ))
            extrude_amount = self.height_ / cosd(p.tent_angle)
            bd.extrude(
                amount=extrude_amount,
                dir=(
                    sind(p.tent_angle),
                    0,
                    cosd(p.tent_angle)
                )
            )
            outer_face = self.center_wall.faces().sort_by(bd.Axis.X)[0]
            # Subtract the volume between the reinforcing ribs.
            with bd.BuildSketch(outer_face) as rib_sketch:
                bd.project(outer_face)
                bd.offset(amount=-p.CenterBlock.wall_thickness)
            bd.extrude(
                amount=p.CenterBlock.wall_thickness,
                dir=(1, 0, 0),
                mode=bd.Mode.SUBTRACT
            )
            # Draft the overhanging face (when printed upside-down) to eliminate
            # the need for supports.
            bd.draft(
                faces=self.center_wall.faces(bd.Select.LAST).sort_by(bd.Axis.Z)[0],
                neutral_plane=bd.Plane(self.center_wall.faces().sort_by(bd.Axis.X)[0]),
                angle=p.overhang_angle
            )
        return self.center_wall.part

    def connector_locations(self) -> bd.Locations:
        p = self.parameters
        return bd.Locations(
            bd.Location(
                self.center_wall.edges()
                .group_by(bd.Axis.Y)[0].edges()
                .sort_by(bd.Axis.X)[-1].center()
            )
            * bd.Rot(0, p.tent_angle, 0)
            * bd.Pos(0, p.MagneticConnector.position_y, 0)
        )

    def connector_screw_locations(self) -> bd.Locations:
        p = self.parameters
        screw_offset = p.MagneticConnector.screw_offset
        return bd.Locations([
            self.connector_locations().locations[0]
            * bd.Rot(Y=90)
            * bd.Pos(0, y_pos, -p.CenterBlock.wall_thickness)
            for y_pos in (-screw_offset, screw_offset)
        ])

    def origin_point(self) -> bd.Location:
        return bd.Location(
            self.center_wall.faces()
            .sort_by(bd.Axis.Y)[0].vertices()
            .group_by(bd.Axis.X)[-1].vertices()
            .sort_by(bd.Axis.Z)[-1].center()
        )

    def screw_locations(self) -> bd.Locations:
        p = self.parameters
        # Radius of the screw boss.
        offset = p.Insert.hole_diameter/2 + p.Insert.wall_thickness
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
        p = self.parameters
        with bd.BuildPart() as holder:
            bd.Box(
                length=(
                    p.TrackballSensor.pcb_size[0]
                    + 2*p.CenterBlock.wall_thickness
                ),
                width=p.TrackballSensor.holder_thickness,
                height=p.TrackballSensor.holder_height,
                align=Align.Top
            )
            bd.Box(
                length=p.TrackballSensor.holder_thickness,
                width=(
                    p.TrackballSensor.pcb_size[1]
                    + 2*p.CenterBlock.wall_thickness
                ),
                height=p.TrackballSensor.holder_height,
                align=Align.Top
            )
        holder.part.move(bd.Pos(
            0,
            0,
            (
                p.TrackballSensor.clearance
                + p.TrackballSensor.lens_size[2]
                + p.TrackballSensor.pcb_size[2]
            )
        ))
        return holder.part

    def sensor_locations(self) -> bd.Locations:
        p = self.parameters
        return bd.Locations(
            self.trackball_position()
            * bd.Rot(0, 180 + p.TrackballSensor.angle, 0)
            * bd.Pos(0, 0, p.Trackball.diameter/2)
        )

    def trackball_locations(self) -> bd.Locations:
        p = self.parameters
        return bd.Locations(
            self.trackball_position()
            * bd.Rot(-90, 0, 90 + p.tent_angle)
        )

    def trackball_position(self) -> bd.Location:
        p = self.parameters
        return bd.Location(
            self.origin_point()
            * bd.Pos(0, p.Trackball.position_y, 0)
        )


if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    show(
        CenterBlock(
            androphage.build_plate_outline(edge=5),
            androphage.parameters
        )
    )