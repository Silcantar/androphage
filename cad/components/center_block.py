import typing

import build123d as bd

from common import *
import layout
from parameters import Parameters
from components.btu import BTU
from components.fasteners import screw_boss_vertical
from components.magnetic_connector import MagneticConnector
from components.trackball_sensor import TrackballSensor

class CenterBlock(Component):
    """The center block of the Androphage case."""

    def __init__(
        self,
        parameters: Parameters,
        label: str = "Center Block",
        half: Half = Half.LEFT,
        **kwargs
    ):
        self.parameters = parameters
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
        # ---- Additions ----
        # Add center wall.
        center_block = self._center_wall()
        # Add hinge bosses.
        hinge_locations = self._hinge_locations(center_block)
        center_block += hinge_locations * self._hinge_boss()
        # Add trackball case.
        center_block += self._trackball_location() * self._trackball_case()
        # Add trackball sensor holder.
        # Eliminate some of the overhang of the sensor holder when it is
        # printed upside-down.
        sensor_holder = self._sensor_location() * self._sensor_holder()
        # sensor_holder += bd.extrude(
        #     to_extrude=sensor_holder.faces().sort_by(bd.Axis.Z)[-1],
        #     dir=(0, 0, 1),
        #     amount=10
        # )
        center_block += sensor_holder
        center_block += self._btu_locations() * self._btu_socket()
        # Clip off anything extending outside the proper height of the part.
        center_block &= bd.Box(
            length=BIG,
            width=p.Plates.depth - 2*p.Frame.lip_depth,
            height=self.height_,
            align=Align.FrontTop,
            rotation=(0, -p.tent_angle, 0)
        )
        # Add bosses for heat-sink inserts.
        bottom_center_edge = (
            center_block.edges()
            .group_by(bd.Axis.X)[-1]
            .sort_by(bd.Axis.Z)[0]
        )
        screw_locations = (
            bd.Pos(bottom_center_edge.center())
            * bd.Rot(0, -p.tent_angle, 180)
            * bd.Pos(-bottom_center_edge.center())
            * layout.center_screw_locations(
                edge=bottom_center_edge,
                default_offset=(0, p.Screws.M2.offset),
                offsets=p.CenterBlock.screw_offsets
            )
        )
        center_block += (
            screw_locations
            * screw_boss_vertical(
                hole_depth=p.Insert.hole_depth,
                hole_diameter=p.Insert.hole_diameter,
                overhang_angle=p.Print.overhang_angle,
                wall_thickness=p.Insert.wall_thickness
            )
        )
        # ---- Subtractions ----
        center_block -= (
            bd.Rot(Y=-p.tent_angle)
            * bd.Locations(self._end_locations(center_block))
            * bd.Box(
                length=BIG,
                width=2*p.Frame.lip_depth,
                height=(
                    -p.Plates.Top.thickness
                    - p.Plates.Switch.thickness
                    - p.Plates.Switch.position_z
                ) * cosd(p.tent_angle),
                align=Align.Top
            )
        )
        # Subtract cutouts for hinges.
        center_block -= hinge_locations * self._hinge_cutout()
        # Subtract holes for hinge screw inserts.
        for hinge_loc in hinge_locations:
            for i in [-1, 1]:
                center_block -= (
                    hinge_loc
                    * bd.Pos(Z=i*p.Hinge.screw_position)
                    * bd.Rot(Y=90)
                    * bd.Hole(
                        radius=p.Insert.hole_diameter/2,
                        depth=BIG
                    )
                )
        # Subtract trackball sensor from holder.
        center_block -= self._sensor_location() * TrackballSensor(
            parameters=self.parameters,
            mode=bd.Mode.SUBTRACT
        )
        center_block -= self._btu_locations() * BTU(
            parameters=self.parameters,
            subtract=True,
            rotation=(180, 0, 0),
            mode=bd.Mode.SUBTRACT
        )
        # Subtract trackball clearance.
        center_block -= self._trackball_location() * bd.Sphere(
            radius=p.Trackball.diameter/2 + p.Trackball.clearance
        )
        # Subtract cutout for magnetic connector.
        magnetic_connector_location = bd.Pos(p.MagneticConnector.position)
        center_block -= magnetic_connector_location * MagneticConnector(
            self.parameters
        )
        magnetic_connector_screw_locations = (
            magnetic_connector_location
            * bd.Locations([
                (0, i*p.MagneticConnector.screw_offset, 0)
                for i in (1, -1)
            ])
        )
        center_block += (
            magnetic_connector_screw_locations
            * self._magnetic_connector_screw_boss()
        )
        center_block -= (
            screw_locations
            * bd.Cylinder(
                radius=p.Insert.hole_diameter/2,
                height=p.Insert.hole_depth,
                align=Align.Bottom
            )
        )
        screen_location = (
            self._trackball_location()
            * bd.Pos(Z=p.Plates.Top.position_z)
            * bd.Rot(Y=-p.tent_angle)
            * bd.Pos(
                (
                    -p.Trackball.diameter/2
                    - p.Trackball.clearance
                    - p.CenterBlock.wall_thickness
                    ),
                0,
                (-p.Screen.pcb_size[Z] - p.Screen.chip_size[Z])
                )
            )
        center_block -= (
            screen_location
            * bd.Box(
                length=BIG,
                width=BIG,
                height=BIG,
                align=Align.RightBottom
                )
            )
        return center_block

    def _btu_locations(self) -> bd.Locations:
        p = self.parameters
        btu_angles = bd.Vector(p.CenterBlock.btu_angles)
        return bd.Locations([
            self._trackball_location()
            * bd.Rot(
                0,
                180 + btu_angles.Y,
                i*btu_angles.Z,
                ordering=bd.Extrinsic.XYZ
            )
            * bd.Pos(0, 0, p.Trackball.diameter/2)
            for i in (1, -1)
        ])

    def _btu_socket(self) -> bd.Part:
        p = self.parameters
        return bd.Cylinder(
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

    def _center_wall(self) -> bd.Part:
        p = self.parameters
        width = 2*p.CenterBlock.wall_thickness
        height = self.height_
        sketch = bd.Plane.XZ * bd.make_face(
            bd.Polyline(
                (-width, -width*tand(p.tent_angle)),
                (0, 0),
                (0, -self.height_/cosd(p.tent_angle)),
                (
                    -width,
                    -self.height_/cosd(p.tent_angle) - width*tand(p.tent_angle)
                ),
                close=True
            )
        )
        center_wall = bd.extrude(
            to_extrude=sketch,
            amount=-p.Plates.depth + 2*p.Frame.lip_depth
        )
        center_wall = bd.offset(
            objects=center_wall,
            amount=-p.CenterBlock.wall_thickness,
            openings=center_wall.faces().sort_by(bd.Axis.X)[0]
        )
        # Draft the overhanging face (when printed upside-down) to eliminate
        # the need for supports.
        center_wall += bd.draft(
            faces=(
                center_wall.faces()
                .filter_by(lambda f: f.normal_at().Z > 0)
                .sort_by(bd.Axis.Z)[0]
            ),
            neutral_plane=bd.Plane(center_wall.faces().sort_by(bd.Axis.X)[0]),
            angle=p.Print.overhang_angle + p.tent_angle
        )
        return center_wall

    def _end_locations(self, center_block: bd.Part) -> list[bd.Location]:
        return [
            bd.Location(
                center_block.vertices()
                .group_by(bd.Axis.Z)[-1]
                .sort_by(bd.Axis.Y)[-i]
            )
            for i in range(2)
        ]

    def _hinge_boss(self) -> bd.Part:
        p = self.parameters
        return bd.Box(
            length=p.Hinge.thickness + p.Insert.hole_depth,
            width=p.Hinge.width + 2*p.CenterBlock.wall_thickness,
            height=BIG,
            align=Align.Right
        )

    def _hinge_cutout(self) -> bd.Part:
        p = self.parameters
        return bd.Box(
            length=2*p.Hinge.thickness,
            width=p.Hinge.width,
            height=BIG
        )

    def _hinge_locations(self, center_block: bd.Part) -> list[bd.Location]:
        p = self.parameters
        return [
            self._end_locations(center_block)[i]
            * bd.Pos(
                0,
                (
                    (1 - 2*i)*(p.Hinge.width/2 + p.Frame.lip_depth)
                    + p.Hinge.offsets[i]
                ),
                -p.Hinge.height/2 + p.Plates.Top.thickness/cosd(p.tent_angle)
            )
            for i in range(len(p.Hinge.offsets))
        ]

    def _magnetic_connector_screw_boss(self) -> bd.Part:
        p = self.parameters
        boss = bd.Cylinder(
            radius=(
                p.Insert.hole_diameter/2
                + p.Insert.wall_thickness
            ),
            height=p.MagneticConnector.size[0],
            align=Align.Top,
            rotation=(0, 90, 0)
        )
        boss -= bd.Pos(-p.MagneticConnector.size[0], 0, 0) * bd.Cylinder(
            radius=p.Insert.hole_diameter/2,
            height=2*p.Insert.hole_depth,
            rotation=(0, 90, 0)
        )
        return boss

    def _sensor_holder(self) -> bd.Part:
        p = self.parameters
        holder_location = bd.Pos(
            0,
            0,
            (
                p.TrackballSensor.clearance
                + p.TrackballSensor.lens_size[Z]
                + p.TrackballSensor.pcb_size[Z]
                )
            )
        holder = bd.Box(
            length=(
                p.TrackballSensor.pcb_size[X]/2
                + 1*p.CenterBlock.wall_thickness
                ),
            width=p.TrackballSensor.holder_thickness,
            height=p.TrackballSensor.holder_height,
            align=Align.RightTop
            )
        holder += bd.Box(
            length=p.TrackballSensor.holder_thickness,
            width=(
                p.TrackballSensor.pcb_size[Y]
                + 2*p.CenterBlock.wall_thickness
                ),
            height=p.TrackballSensor.holder_height,
            align=Align.Top
            )
        return holder_location * holder

    def _sensor_location(self) -> bd.Location:
        p = self.parameters
        return (
            self._trackball_location()
            * bd.Rot(0, 180 + p.TrackballSensor.angle, 0)
            * bd.Pos(0, 0, p.Trackball.diameter/2)
        )

    def _trackball_case(self) -> bd.Part:
        p = self.parameters
        return bd.Sphere(
            radius=(
                p.Trackball.diameter/2
                + p.Trackball.clearance
                + p.CenterBlock.wall_thickness
            ),
            arc_size3=90 - p.tent_angle,
            align=Align.LeftFront,
            rotation=(-90, 0, 90)
        )

    def _trackball_location(self) -> bd.Location:
        p = self.parameters
        return bd.Pos(
            0,
            p.Trackball.position_y - p.Frame.lip_depth,
            p.Plates.Top.thickness/cosd(p.tent_angle)
        )


if __name__ == "__main__":
    from ocp_vscode import show
    import layout, parameters
    p = layout.set_derived_parameters(
        parameters.load_parameters("cad/androphage.yaml")
    )
    show(bd.Rot(Y=180+p.tent_angle)*CenterBlock(p))