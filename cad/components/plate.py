import typing
from enum import StrEnum, auto

import build123d as bd

from common import *
import layout
from parameters import Columns, Parameters
from components.knife_hinge import KnifeHinge

class PlateType(StrEnum):
    BOTTOM = auto()
    PCB = auto()
    SWITCH = auto()
    TOP = auto()

class Plate(Component):
    """Class used to generate all plate and plate-like components: top and
    bottom plates, switch plate, and PCB.
    """
    def __init__(
        self,
        parameters: Parameters,
        plate_type: PlateType = PlateType.SWITCH,
        draft_center: bool = False,
        half: Half = Half.LEFT,
        label: str = None,
        **kwargs
    ):
        self.parameters = parameters
        self.plate_type = plate_type
        self.draft_center = draft_center
        self.half = half
        p = self.parameters
        match self.plate_type:
            case PlateType.BOTTOM:
                self.plate_params = p.Plates.Bottom
                self.sensor_cutout = CutoutType.NONE
            case PlateType.PCB:
                self.plate_params = p.Plates.PCB
                self.sensor_cutout = CutoutType.SMALL
            case PlateType.SWITCH:
                self.plate_params = p.Plates.Switch
                self.sensor_cutout = CutoutType.BIG
            case PlateType.TOP:
                self.plate_params = p.Plates.Top
                self.sensor_cutout = CutoutType.NONE
        self.column_locations = layout.build_column_locations(self.parameters)
        self.outline = layout.build_plate_outline(
            self.parameters,
            edge=self.plate_params.edge,
            add_center=self.plate_params.add_center,
            center_width=self.plate_params.center_width,
            fillet_radius=self.plate_params.radius_outer,
            sensor_cutout=self.sensor_cutout
        )
        self.generic_plate_outline = layout.build_plate_outline(
            self.parameters,
            edge=p.Plates.Top.edge,
            add_center=True,
            center_width=p.Plates.Bottom.center_width,
            fillet_radius=p.Plates.Bottom.radius_outer,
            sensor_cutout=CutoutType.NONE
        )
        if label is None:
            self.label = f"{plate_type.title()} Plate"
        else:
            self.label = label
        try:
            color
        except NameError:
            color = seq_to_color(self.plate_params.color)
        super().__init__(label=self.label, color=color, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters
        plate = bd.extrude(
            to_extrude=self.outline,
            amount=self.plate_params.thickness
        )
        if self.draft_center:
            plate += bd.draft(
                faces=plate.faces().sort_by(bd.Axis.X)[-1],
                neutral_plane=bd.Plane.XY,
                angle=-p.tent_angle
            )
        match self.plate_type:
            case PlateType.BOTTOM:
                plate -= self._hinge_cutouts(plate)
                plate -= self._screw_holes(plate)
            case PlateType.PCB:
                plate -= self._screw_boss_cutouts()
            case PlateType.SWITCH:
                plate -= self._screw_boss_cutouts()
                plate -= self._switch_plate_cutout()
            case PlateType.TOP:
                plate -= self._hinge_cutouts(plate)
                plate -= self._trackball_cutout(plate)
                top_plate_cutout = self._top_plate_cutout()
                plate -= top_plate_cutout
                # Select the horizontal cutout edges based on their length.
                fillet_edges = (
                    plate.edges()
                    .group_by(bd.Axis.Z)[-1]
                    .filter_by(
                        lambda e:
                        # Select edges that are the same width as a key cutout...
                        abs(
                            e.length
                            - p.spacing.X
                            + 2*p.Plates.Top.radius_inner
                        ) < EPS
                        # ... or that are the same width as the screen cutout.
                        or abs(
                            e.length
                            - p.Screen.display_area[X]
                            + 2*p.Plates.Top.screen_radius
                        ) < EPS
                    )
                )
                plate = bd.fillet(
                    objects=fillet_edges,
                    radius=p.Frame.fillet_radius
                )
        self.front_center_location = (
            bd.Pos(X=(
                p.Plates.Bottom.center_width
                - self.plate_params.center_width
                ))
            * bd.Pos(
                -self.generic_plate_outline.edges()
                .sort_by(bd.Axis.X)[-1]
                .vertices()
                .sort_by(bd.Axis.Y)[0]
                .center()
                )
            )
        return self.front_center_location * plate

    def _joints(self):
        p = self.parameters
        if self.plate_type == PlateType.SWITCH:
            i = 1
            plate_location = (
                bd.Pos(self.front_center_location.mirror(bd.Plane.YZ).center()) if self.mirror
                else self.front_center_location
                )
            joint_locations = (
                [
                    location.mirror(bd.Plane.YZ)
                    for location in self.switch_locations.locations
                    ] if self.mirror
                else self.switch_locations.locations
                )
            rotation = (bd.Rot(Z=180) if self.mirror else bd.Rot(Z=0))
            for location in joint_locations:
                bd.RigidJoint(
                    label=f"switch_{i}",
                    to_part=self,
                    joint_location=(
                        plate_location
                        * bd.Pos(Z=p.Plates.Switch.thickness)
                        * location
                        * rotation
                        )
                    )
                i += 1

    def _hinge_cutouts(self, part: bd.Part) -> bd.Part:
        p = self.parameters
        is_top = self.plate_type == PlateType.TOP
        hinge_locations = bd.Locations([
            bd.Pos(
                part.edges()
                .group_by(bd.Axis.X)[-1]
                .sort_by(bd.Axis.Y)[i]
                .vertices()
                .sort_by(bd.Axis.Y)[i]
                .center()
                + bd.Vector(
                    0,
                    (1 + 2*i)*(
                        p.Hinge.width/2
                        + p.Frame.lip_depth
                        + (
                            p.Frame.lip_depth if is_top
                            else -p.Plates.Bottom.clearance
                        )
                    ),
                    0
                )
            )
            for i in [0, -1]
        ])
        return (
            hinge_locations
            * bd.Box(
                length=p.Hinge.thickness,
                width=p.Hinge.width + (0 if is_top else 2*p.Frame.lip_depth),
                height=BIG,
                rotation=(
                    0,
                    p.tent_angle if is_top else 0,
                    0
                ),
                align=Align.Right
            )
        )

    def _screw_boss_cutouts(self) -> bd.Part:
        p = self.parameters
        boss_radius = (
            p.Insert.hole_diameter/2
            + p.Insert.wall_thickness
        )
        cutout_radius = boss_radius + p.Plates.Switch.clearance
        boss_locations = layout.frame_screw_locations(
            self.generic_plate_outline,
            offset=(0, 0)
        )
        cutout_sketch = bd.RectangleRounded(
            width=2*(cutout_radius + p.Screws.M2.offset),
            height=2*cutout_radius,
            radius=cutout_radius - EPS,
            mode=bd.Mode.SUBTRACT
        )
        cutout = bd.extrude(
            to_extrude=cutout_sketch,
            amount=self.plate_params.thickness
        )
        return boss_locations * cutout

    def _screw_holes(self, plate: bd.Part) -> bd.Part:
        p = self.parameters
        screw_locations = layout.screw_locations(
            outline=self.generic_plate_outline,
            default_offset=(0, p.Screws.M2.offset),
            center_offsets=p.CenterBlock.screw_offsets
        )
        screw_hole = bd.Rot(X=180) * bd.CounterSinkHole(
            radius=p.Screws.M2.hole_diameter/2,
            depth=BIG,
            counter_sink_radius=p.Screws.M2.counter_sink_diameter/2,
            counter_sink_angle=p.Screws.M2.head_angle
        )
        return screw_locations * screw_hole

    def _switch_plate_cutout(self) -> bd.Part:
        """Create a sketch for the cutouts in the switch plate."""
        p = self.parameters
        self.switch_locations = bd.Locations(
            list(layout.build_key_locations(p).values())
        )
        switch_cutout_sketch = bd.RectangleRounded(
            *p.Switch.model.cutout,
            radius=p.Switch.model.radius
        )
        switch_cutout = bd.extrude(
            to_extrude=switch_cutout_sketch,
            amount=self.plate_params.thickness
        )
        return self.switch_locations * switch_cutout

    def _top_plate_cutout(self) -> bd.Part:
        """Generate a sketch for the cutouts in the top plate."""
        p = self.parameters
        spc = p.spacing
        with bd.BuildPart() as part:
            with bd.BuildSketch() as sketch:
                for column_key in self.column_locations:
                    column = p.Columns[column_key]
                    column_location = self.column_locations[column_key]
                    cutout = 2*self.plate_params.edge if column.cutout else 0
                    with bd.Locations(
                        column_location
                        * bd.Pos(
                            0,
                            ((column.keys - 1)*spc.Y - cutout)/2
                        ) * bd.Pos(
                            column.shift[0]*spc.X,
                            column.shift[1]*spc.Y
                        )
                    ):
                        bd.Rectangle(
                            spc.X,
                            column.keys*spc.Y + cutout
                        )
                    if column.connect > 0:
                        with bd.Locations(
                            column_location
                            * bd.Pos(spc.X/2, -spc.Y/2)
                            * bd.Rot(Z=90)
                        ):
                            bd.Circle(
                                radius=column.connect*spc.Y,
                                arc_size=-column.splay,
                                align=(bd.Align.MIN, bd.Align.MAX)
                            )
            bd.extrude(amount=self.plate_params.thickness)
            bd.fillet(
                objects=part.edges().filter_by(bd.Axis.Z),
                radius=self.plate_params.radius_inner
            )
        objs = [part.part]
        if self.half in p.Screen.half:
            display_location = (
                self.column_locations["inner"]
                * bd.Pos(2*p.spacing.X, 3.5*p.spacing.Y)
                )
            display_cutout = display_location * bd.Box(
                *p.Screen.display_area,
                self.plate_params.thickness,
                align=Align.BackBottom
                )
            display_cutout = bd.fillet(
                objects=display_cutout.edges().filter_by(bd.Axis.Z),
                radius=self.plate_params.screen_radius
                )
            objs.append(display_cutout)
            screen_location = (
                display_location
                * bd.Pos(
                    0,
                    p.Screen.bezel,
                    p.Screen.size[Z]
                    )
                )
            screen_cutout = (
                screen_location
                * bd.Box(
                    *(bd.Vector(p.Screen.size) + bd.Vector(0.2, 0.2, 0)),
                    align=Align.BackTop)
                )
            objs.append(screen_cutout)
        return bd.Part(objs)

    def _trackball_cutout(self, plate: bd.Part) -> bd.Part:
        """Generate and position a 3d cutout for the trackball."""
        p = self.parameters
        origin = (
            plate.vertices()
            .group_by(bd.Axis.Z)[-1].vertices()
            .group_by(bd.Axis.X)[-1].vertices()
            .sort_by(bd.Axis.Y)[0].center()
        )
        # Subtract the trackball cutout.
        trackball_locations = bd.Locations(
            origin
            + (0, p.Trackball.position_y, 0)
        )
        trackball_cutout = bd.Sphere(
            radius=p.Trackball.diameter/2 + p.Trackball.clearance
        )
        return trackball_locations * trackball_cutout


if __name__ == "__main__":
    from ocp_vscode import show
    import layout, parameters
    p = layout.set_derived_parameters(
        parameters.load_parameters("cad/androphage.yaml")
        )
    zpos = {
        PlateType.BOTTOM: 0,
        PlateType.PCB: 20,
        PlateType.SWITCH: 40,
        PlateType.TOP: 60
        }
    export_face = {
        PlateType.BOTTOM: -1,
        PlateType.PCB: 0,
        PlateType.SWITCH: 0,
        PlateType.TOP: 0
        }
    plates: list[bd.Part] = []
    for plate_type in PlateType:
        plate = bd.Pos(0, 0, zpos[plate_type]) * Plate(
            p,
            plate_type=plate_type,
            draft_center=(plate_type == PlateType.TOP),
            # mirror=True
        )
        plates.append(plate)
        exporter = bd.ExportDXF()
        exporter.add_shape(
            plate.faces()
            .sort_by(bd.Axis.Z)[export_face[plate_type]]
        )
        exporter.write(f"cad/production/{plate_type}.dxf")
    show(plates, render_joints=True)