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
        fillet_front_corners: bool = False,
        label: str = None,
        **kwargs
    ):
        self.parameters = parameters
        self.plate_type = plate_type
        self.draft_center = draft_center
        self.fillet_front_corners = fillet_front_corners
        p = self.parameters
        match self.plate_type:
            case PlateType.BOTTOM:
                self.plate_params = p.Plates.Bottom
            case PlateType.PCB:
                self.plate_params = p.Plates.PCB
            case PlateType.SWITCH:
                self.plate_params = p.Plates.Switch
            case PlateType.TOP:
                self.plate_params = p.Plates.Top
        self.column_locations = layout.build_column_locations(p)
        self.outline = layout.build_plate_outline(
            p,
            edge=self.plate_params.edge,
            add_center=self.plate_params.add_center,
            center_width=self.plate_params.center_width,
            fillet_radius=self.plate_params.radius_outer,
            sensor_cutout=(self.plate_type in (PlateType.PCB, PlateType.SWITCH))
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
        with bd.BuildPart() as plate:
            with bd.BuildSketch() as sketch:
                # Create the outline.
                bd.add(self.outline)
                top_plate_outline = layout.build_plate_outline(
                    p,
                    edge=p.Plates.Top.edge,
                    add_center=True,
                    center_width=p.Plates.Top.center_width,
                    fillet_radius=p.Plates.Top.radius_outer,
                    sensor_cutout=False
                )
                boss_radius = (
                    p.Insert.hole_diameter/2
                    + p.Insert.wall_thickness
                )
                if self.plate_type in (PlateType.SWITCH, PlateType.PCB):
                    # Add cutouts for frame screw bosses.
                    cutout_radius = boss_radius + p.Plates.Switch.clearance
                    with layout.frame_screw_locations(top_plate_outline):
                        bd.RectangleRounded(
                            width=(
                                2*cutout_radius
                                + p.Screws.M2.offset
                                + 2*p.Plates.Top.edge
                                - 2*self.plate_params.edge
                            ),
                            height=2*cutout_radius,
                            radius=cutout_radius - EPS,
                            mode=bd.Mode.SUBTRACT
                        )
                # Create the switch-mounting cutouts in the switch plate.
                if self.plate_type == PlateType.SWITCH:
                    bd.add(
                        self.switch_plate_cutout(),
                        mode=bd.Mode.SUBTRACT
                    )
                # Create the cutout in the top plate.
                if self.plate_type == PlateType.TOP:
                    # Fillet the two vertices created by the previous step.
                    if (
                        self.fillet_front_corners
                        and self.plate_params.radius_outer > 0
                        and p.Plates.Top.thumb_cutout_fillet
                    ):
                        first_thumb_key = (
                            Finger.INDEX if self.columns[Finger.INDEX].cutout
                            else Finger.TUCK
                        )
                        top_plate_transition_vertices = (
                            sketch.vertices().sort_by_distance((
                                self.column_locations[first_thumb_key]
                                * bd.Pos(
                                -p.spacing.X/2,
                                -p.spacing.Y/2 - self.plate_params.edge
                                )
                            ).position)[0],
                            sketch.vertices().sort_by_distance((
                                self.column_locations[Finger.REACH]
                                * bd.Pos(
                                p.spacing.X/2,
                                -p.spacing.Y/2 - self.plate_params.edge
                                )
                            ).position)[0],
                        )
                        bd.fillet(
                            top_plate_transition_vertices,
                            radius=self.plate_params.radius_outer
                        )
            bd.extrude(amount=self.plate_params.thickness)
            if self.plate_type == PlateType.BOTTOM:
                offset = 12 #(
                #     boss_radius
                #     - p.Plates.Top.edge
                #     + self.plate_params.edge
                #     + p.Frame.lip_depth
                # )
                # Add screw holes.
                with layout.screw_locations(
                    outline=self.outline,
                    x_offset=(
                        p.Plates.Bottom.thickness*tand(p.tent_angle)
                        - p.Plates.Bottom.clearance
                    ),
                    y_offsets=[offset, 2*boss_radius, -offset]
                ):
                    with bd.Locations(bd.Location(
                        position=((
                            -p.Screws.M2.offset
                            + p.Plates.Top.edge
                            - self.plate_params.edge
                        ), 0, 0),
                        orientation=(180, 0, 0)
                    )):
                        bd.CounterSinkHole(
                            radius=p.Screws.M2.hole_diameter/2,
                            counter_sink_radius=p.Screws.M2.counter_sink_diameter/2,
                            counter_sink_angle=p.Screws.M2.head_angle
                        )
            if self.draft_center:
                bd.draft(
                    plate.faces().sort_by(bd.Axis.X)[-1],
                    neutral_plane=bd.Plane.XY,
                    angle=-p.tent_angle
                )
            if self.plate_type == PlateType.TOP:
                bd.add(
                    self.top_plate_cutout(),
                    mode=bd.Mode.SUBTRACT
                )
                origin = (
                    plate.vertices()
                    .group_by(bd.Axis.Z)[-1].vertices()
                    .group_by(bd.Axis.X)[-1].vertices()
                    .sort_by(bd.Axis.Y)[0].center()
                )

                # Select the inside edges created by the previous cut.
                fillet_edges = (
                    plate.edges(bd.Select.LAST)
                    .group_by(bd.Axis.Z)[-1]    # We only want edges on the top surface
                    .sort_by(bd.Axis.Y)[1:]     # We don't want the frontmost edge.
                    # The following filters out the front middle edge (a segment
                    # of a large circle) by selecting edges that are linear OR
                    # have a small radius.
                    .filter_by(
                        lambda e: (
                            e.geom_type == bd.GeomType.LINE
                            or (
                                e.geom_type == bd.GeomType.CIRCLE
                                and e.radius <= p.spacing.X
                            )
                        )
                    )
                )
                bd.fillet(
                    objects=fillet_edges,
                    radius=p.Frame.fillet_radius
                )
                # Subtract the trackball cutout.
                trackball_locations = bd.Locations(
                    origin
                    + (0, p.Trackball.position_y, 0)
                )
                with trackball_locations:
                    bd.Sphere(
                        radius=p.Trackball.diameter/2 + p.Trackball.clearance,
                        mode=bd.Mode.SUBTRACT
                    )
        # Subtract the hinge cutout.
        plate_part = plate.part
        if self.plate_type in [PlateType.TOP, PlateType.BOTTOM]:
            is_top = self.plate_type == PlateType.TOP
            hinge_locations = bd.Locations([
                bd.Pos(
                    plate_part.edges()
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
            plate_part -= (
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
        return plate_part

    def _locate(self):
        p = self.parameters
        self.orientation += (0, -p.tent_angle, 0)
        # Align the front center corner to the origin.
        self.position -= (
            self.vertices()
            .group_by(bd.Axis.X)[-1].vertices()
            .group_by(bd.Axis.Y)[0].vertices()
            .sort_by(bd.Axis.Z)[0].center()
        )
        if not self.plate_params.add_center:
            self.position += (
                (self.plate_params.center_width + p.center_width)
                * bd.Vector(
                    -cosd(p.tent_angle),
                    0,
                    -sind(p.tent_angle)
                ) + (0, -sind(self.parameters.tent_angle), 0)
            )


    def switch_plate_cutout(self) -> bd.Sketch:
        """Create a sketch for the cutouts in the switch plate."""
        p = self.parameters
        with bd.BuildSketch() as sketch:
            with bd.Locations(list(layout.build_key_locations(p).values())):
                bd.RectangleRounded(
                    *p.Switch.model.cutout,
                    radius=p.Switch.model.radius
                )
        return sketch.sketch

    def top_plate_cutout(self) -> bd.Part:
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
        return part.part

    def trackball_cutout(self) -> bd.Part:
        """Generate and position a 3d cutout for the trackball."""
        p = self.parameters
        with bd.BuildPart() as part:
            trackball_location = (
                self.vertices()
                .group_by(bd.Axis.Z)[-1].vertices()
                .group_by(bd.Axis.X)[-1].vertices()
                .sort_by(bd.Axis.Y)[0]
            ).moved(
                bd.Pos(
                    0,
                    p.Trackball.position_y
                )
            )
            with bd.Locations(trackball_location):
                bd.Sphere(
                    radius=p.Trackball.diameter/2 + p.Trackball.clearance
                )
        return part.part


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
    plates: list[bd.Part] = []
    for plate_type in PlateType:
        plate = Plate(
            p,
            plate_type=plate_type,
            draft_center=(plate_type == PlateType.TOP),
            locate=False
        ).move(bd.Pos(0, 0, zpos[plate_type]))
        plates.append(plate)
        exporter = bd.ExportDXF()
        exporter.add_shape(
            plate.faces()
            .sort_by(bd.Axis.Z)[0]
            .project_to_viewport((0, 0, 0))
        )
        exporter.write(f"cad/production/{plate_type}.dxf")
    show(plates)