import typing

import build123d as bd

from common import *
import layout
from parameters import Parameters
from components.btu import BTU
from components.fasteners import screw_boss_vertical
from components.hinge import Hinge
from components.magnetic_connector import MagneticConnector
from components.trackball_sensor import TrackballSensor

class CenterBlock(Component):
    """The center block of the Androphage case."""

    def __init__(
        self,
        parameters: Parameters,
        label: str = "Center Block",
        **kwargs
    ):
        self.parameters = parameters
        self.outline = layout.build_plate_outline(
            self.parameters,
            edge=self.parameters.Plates.Top.edge,
            fillet_radius=self.parameters.Plates.Top.radius_outer
        )
        self.height_ = (
            self.parameters.height
            - self.parameters.Plates.Top.thickness
            - self.parameters.Plates.Bottom.thickness
        )
        try:
            color
        except NameError:
            color = seq_to_color(self.parameters.CenterBlock.color)
        super().__init__(label=label, color=color, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters
        with bd.BuildPart() as center_block:
            # ---- Additions ----
            # Add center wall.
            self.center_wall = bd.add(self.center_wall())
            # Add trackball case.
            with self.trackball_locations():
                bd.Sphere(
                    radius=(
                        p.Trackball.diameter/2
                        + p.Trackball.clearance
                        + p.CenterBlock.wall_thickness
                    ),
                    arc_size3=90 - p.tent_angle,
                    align=Align.LeftFront,
                    rotation=(-90, 0, 90)
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
            with bd.Locations(p.MagneticConnector.position):
                MagneticConnector(self.parameters, mode=bd.Mode.SUBTRACT)
                with bd.Locations([
                    (
                        -p.MagneticConnector.size[0], 
                        i*p.MagneticConnector.screw_offset, 
                        0
                    ) 
                    for i in (1, -1)
                ]):
                    bd.Cylinder(
                        radius=(
                            p.Insert.hole_diameter/2 
                            + p.Insert.wall_thickness
                        ),
                        height=p.MagneticConnector.size[0],
                        align=Align.Bottom,
                        rotation=(0, 90, 0)
                    )
                    bd.Cylinder(
                        radius=p.Screw.hole_diameter/2,
                        height=BIG,
                        # radius=p.Insert.hole_diameter/2,
                        # height=p.Insert.hole_depth,
                        align=Align.Bottom,
                        rotation=(0, 90, 0),
                        mode=bd.Mode.SUBTRACT
                    )
            # Subtract cutout for hinge.
            with bd.Locations((0, p.Hinge.position_y, 0)):
                bd.Box(
                    length=p.Hinge.leaf_thickness,
                    width=p.Hinge.length,
                    height=BIG,
                    align=Align.RightFront,
                    mode=bd.Mode.SUBTRACT
                )
                # Hinge(
                #     parameters=self.parameters,
                #     mode=bd.Mode.SUBTRACT
                # )
            # Clip off anything extending outside the proper height of the part.
            bd.Box(
                length=BIG,
                width=BIG,
                height=self.height_,
                align=Align.Top,
                rotation=(0, -p.tent_angle, 0),
                mode=bd.Mode.INTERSECT
            )
        return center_block.part

    def btu_locations(self) -> bd.Locations:
        p = self.parameters
        btu_angles = bd.Vector(p.CenterBlock.btu_angles)
        return bd.Locations([
            self.trackball_position()
            * bd.Rot(
                0, 
                180 + btu_angles.Y,# + p.tent_angle, 
                i*btu_angles.Z, 
                ordering=bd.Extrinsic.XYZ
            )
            * bd.Pos(0, 0, p.Trackball.diameter/2)
            for i in (1, -1)
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
        with bd.BuildPart() as center_wall:
            with bd.BuildSketch() as sketch:
                outline = bd.add(self.outline, mode=bd.Mode.PRIVATE)
                # Extrude the center edge of the outline into a rectangle.
                edge = outline.edges().sort_by(bd.Axis.X)[-1]
                bd.Rectangle(
                    width=-2*p.CenterBlock.wall_thickness,
                    height=edge.length - 2*p.Frame.lip_depth,
                    align=Align.RightFront
                )
            extrude_amount = (
                p.height
                - p.Plates.Top.thickness
                - p.Plates.Bottom.thickness
            ) / cosd(p.tent_angle)
            bd.extrude(
                amount=extrude_amount,
                dir=(
                    -sind(p.tent_angle),
                    0,
                    -cosd(p.tent_angle)
                )
            )
            outer_face = center_wall.faces().sort_by(bd.Axis.X)[0]
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
                faces=center_wall.faces(bd.Select.LAST).sort_by(bd.Axis.Z)[0],
                neutral_plane=bd.Plane(center_wall.faces().sort_by(bd.Axis.X)[0]),
                angle=p.Print.overhang_angle
            )
            # Radius of the screw boss.
            # Select the bottom outside edge of the center wall.
            edge = (
                center_wall.edges()
                .group_by(bd.Axis.Z)[0].edges()
                .sort_by(bd.Axis.X)[-1]
            )
            # Put locations in the center and inset from each end of the edge.
            screw_locations = bd.Locations([
                edge.start_point() + (-p.Screw.offset, p.Screw.offset, 0),
                edge.center() + (-p.Screw.offset, 2*p.Screw.offset, 0),
                edge.end_point() + (-p.Screw.offset, -p.Screw.offset, 0)
            ])
            # Add bosses for heat-sink inserts.
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
            # Subtract cutouts for frame lips.
            lip_locations = bd.Locations(
                center_wall.vertices()
                .group_by(bd.Axis.Z)[-1].vertices()
                .group_by(bd.Axis.X)[-1].vertices()
            )
            with lip_locations:
                bd.Box(
                    length=BIG,
                    width=2*p.Frame.lip_depth,
                    height=(
                        -p.Plates.Top.thickness
                        - p.Plates.Switch.thickness
                        - p.Plates.Switch.position_z
                    ) * cosd(p.tent_angle),
                    align=Align.Top,
                    mode=bd.Mode.SUBTRACT
                )
            # Move the part so that the center wall is vertical and the hinge
            # pivot is along the Y axis.
            center_wall.part.orientation += (0, -p.tent_angle, 0)
        return center_wall.part

    # def connector_screw_locations(self) -> bd.Locations:
    #     p = self.parameters
    #     screw_offset = p.MagneticConnector.screw_offset
    #     return bd.Locations([
    #         bd.Location(
    #             position=(
    #                 bd.Vector(p.MagneticConnector.position) 
    #                 + (0, i*screw_offset, 0)
    #             ),
    #             orientation=(0, -90, 0)
    #         )
    #         for i in (1, -1)
    #     ])

    # def lip_locations(self) -> bd.Locations:
    #     return 

    def screw_locations(self) -> bd.Locations:
        p = self.parameters

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
            # * bd.Rot(-90, 0, 90 + p.tent_angle)
        )

    def trackball_position(self) -> bd.Location:
        p = self.parameters
        return bd.Location(
            # self.origin_point()
            bd.Pos(
                0,
                p.Trackball.position_y - p.Frame.lip_depth,
                p.Plates.Top.thickness/cosd(p.tent_angle)
            )
        )


if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    show(CenterBlock(androphage.parameters))