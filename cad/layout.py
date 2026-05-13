import typing
from collections.abc import Sequence

import build123d as bd

from common import *
from parameters import *

def set_derived_parameters(p: Parameters) -> Parameters:
    """Get the key spacing distance based on the spacing type specified in
    the parameters.
    """
    p.spacing = bd.Vector(p.Keycap.spacing)
    # Heights
    p.key_height = (
        p.Switch.model.height.lower
        + p.Switch.model.height.upper
        + p.Keycap.profile.height
    )
    key_height = (
        p.key_height
        + p.Plates.PCB.clearance
        + p.Plates.Bottom.thickness
    )
    trackball_height = (
        p.Trackball.diameter/2
        + p.Trackball.clearance
        + p.Plates.Bottom.thickness
        + p.Print.min_wall_thickness
    )
    print(f"key height: {key_height} --- trackball height: {trackball_height}")
    p.height = max(key_height, trackball_height)
    p.Hinge.height = p.height/cosd(p.tent_angle)
    # Plate Parameters
    p.Plates.Switch.thickness = p.Switch.model.plate_thickness
    p.Plates.Top.position_z = -p.Plates.Top.thickness / cosd(p.tent_angle)
    p.Plates.Switch.position_z = (
        - p.Keycap.profile.height
        - p.Switch.model.height.upper
        - p.Plates.Switch.thickness
    ) / cosd(p.tent_angle)
    p.Plates.PCB.position_z = p.Plates.Switch.position_z + (
        - p.Switch.model.height.lower
        - p.Plates.PCB.thickness
    ) / cosd(p.tent_angle)
    p.Plates.Bottom.position_z = -p.height / cosd(p.tent_angle)
    p.Plates.Top.center_width = (
        p.Plates.Top.position_z
        - p.Plates.Bottom.position_z
    ) * tand(p.tent_angle)
    p.Plates.Switch.center_width = (
        p.Plates.Switch.position_z
        - p.Plates.Bottom.position_z
    ) * tand(p.tent_angle)
    p.Plates.PCB.center_width = (
        p.Plates.PCB.position_z
        - p.Plates.Bottom.position_z
    ) * tand(p.tent_angle)
    p.Plates.Bottom.center_width = 0
    p.Plates.Top.edge = (
        p.Plates.Switch.edge
        + p.Plates.Switch.clearance
        + p.Frame.lip_depth
    )
    p.Plates.PCB.edge = p.Plates.Switch.edge
    p.Plates.Bottom.edge = p.Plates.Top.edge - p.Plates.Bottom.clearance
    # Miscellany
    p.Screws.M2.offset = p.Insert.hole_diameter/2 + p.Insert.wall_thickness
    bottom_plate_outline = build_plate_outline(
        p,
        edge=p.Plates.Bottom.edge,
        add_center=p.Plates.Bottom.add_center,
        center_width=p.Plates.Bottom.center_width,
        fillet_radius=p.Plates.Bottom.radius_outer,
        sensor_cutout=False
    )
    frame_bottom_width = (
        frame_section(parameters=p)
        .edges()
        .sort_by(bd.Axis.Z)[0]
        .length
    )
    p.Base.width = p.height*2
    p.Base.height = sind(p.tent_angle) * (
        bottom_plate_outline.length
        + frame_bottom_width
    )
    p.Base.depth = (
        bottom_plate_outline.edges().sort_by(bd.Axis.X)[-1].length
    )
    p.Base.offset = 0 # 2*p.Frame.lip_depth
    p.Base.angled_height = (
        p.Base.width*tand(p.tent_angle)/2
        - p.Base.foot_width*tand(p.tent_angle)
    )
    p.Base.vertical_height = p.Base.height - p.Base.angled_height
    # p.Hinge.diameter = p.Hinge.pin_diameter + 2*p.Hinge.leaf_thickness
    # p.Hinge.width = 2*(p.height - p.Plates.Bottom.thickness)/cosd(p.tent_angle)
    # p.Hinge.length = p.Hinge.knuckle_length * p.Hinge.knuckle_count
    return p

def build_column_locations(
    p: Parameters,
    start_point: bd.Vector = bd.Vector(0, 0)
) -> KeyLocationDict:
    """Calculate the locations of the origin of each column."""
    spc = p.spacing
    column_locations = KeyLocationDict()
    column_origin = bd.Location(start_point)
    for column_key in p.Columns:
        column = p.Columns[column_key]
        column_origin *= (
            bd.Location(
                position=(0.5*spc.X, -0.5*spc.Y)
            )
            * bd.Location(
                position=(-column.spread*spc.X, column.stagger*spc.Y),
                orientation=(0, 0, column.splay)
            )
            * bd.Location(
                position=(-0.5*spc.X, 0.5*spc.Y)
            )
        )
        column_origin.label = column_key
        if not column.skip:
            column_locations[column_key] = column_origin
    return column_locations

def build_key_locations(p: Parameters) -> KeyLocationDict:
    key_locations = KeyLocationDict()
    column_locations = build_column_locations(p)
    for column_key in column_locations:
        column = p.Columns[column_key]
        for i in range(column.keys):
            loc = (
                column_locations[column_key]
                * bd.Location(position=(
                    p.spacing.X*column.shift[0],
                    p.spacing.Y*(i + column.shift[1])
                ))
            )
            loc.label = f"{column_key}_{i}"
            if not column.skip:
                key_locations[loc.label] = KeyLocation(
                    loc,
                    cutout=column.cutout,
                    row=i
                )
    return key_locations

def build_plate_outline(
    p: Parameters,
    add_center: bool = True,
    edge: float = 0,
    center_width: float = 0,
    fillet_radius: float = 0,
    sensor_cutout: bool = False,
) -> bd.Face:
    """Define the geometry of the plate outline."""
    spc = p.spacing
    kl = build_key_locations(p)
    outside = spc.X/2 * (-1 if p.main_half == Half.LEFT else 1)
    center = 0 # Horizontal center
    inside = spc.X/2 * (1 if p.main_half == Half.LEFT else -1)
    front = -spc.Y/2
    middle = 0 # Vertical center
    back = spc.Y/2
    last_column = (
        Finger.PINKY
        if p.Columns[Finger.OUTER].skip
        else Finger.OUTER
    )
    last_key = p.Columns[last_column].keys - 1
    total_splay = sum([
        p.Columns[column].splay
        for column in p.Columns if not p.Columns[column].skip
    ])
    hinge_front_loc = (
        kl["reach_0"]
        * bd.Pos(inside, back)
        * bd.Rot(Z=-p.Columns[Finger.REACH].splay)
    )
    hinge_back_loc = (
        hinge_front_loc
        * bd.Pos(0, p.pivot_depth)
    )
    middle_back_loc = (
        kl["middle_3"]
        * bd.Pos(inside, back)
    )
    reach_front_loc = (
        kl["reach_0"]
        * bd.Pos(center, front)
    )
    reach_front_inside_loc = (
        kl["reach_0"]
        * bd.Pos(inside, front)
    )
    home_front_loc = (
        kl["home_0"]
        * bd.Pos(center, front)
    )
    home_back_loc = (
        kl["home_1"]
        * bd.Pos(outside, back + edge)
    )
    index_front_loc = (
        kl["index_0"]
        * bd.Pos(center, front)
    )
    ring_front_loc = (
        kl["ring_0"]
        * bd.Pos(outside, front)
    )
    pinky_front_loc = (
        kl[f"{last_column}_0"]
        * bd.Pos(outside, front)
    )
    pinky_back_loc = (
        kl[f"{last_column}_{last_key}"]
        * bd.Pos(outside, back)
    )
    with bd.BuildSketch() as sketch:
        with bd.BuildLine() as outline:
            back_center_arc = bd.TangentArc(
                hinge_back_loc.position,
                middle_back_loc.position,
                tangent=(
                    bd.Rot(hinge_back_loc.orientation)
                    * bd.Pos(-1,0)
                ).position
            )
            back_outside_arc = bd.TangentArc(
                back_center_arc.end_point(),
                pinky_back_loc.position,
                tangent=back_center_arc.tangent_at(1)
            )
            outside_line = bd.Line(
                back_outside_arc.end_point(),
                pinky_front_loc.position
            )
            reach_line = bd.Line(
                reach_front_inside_loc.position,
                reach_front_loc.position,
            )
            front_arc = bd.ThreePointArc(
                reach_line.end_point(),
                home_front_loc.position,
                index_front_loc.position
            )
            front_middle_arc = bd.TangentArc(
                front_arc.end_point(),
                ring_front_loc.position,
                tangent=front_arc.tangent_at(1)
            )
            front_outer_arc = bd.TangentArc(
                front_middle_arc.end_point(),
                pinky_front_loc.position,
                tangent=front_middle_arc.tangent_at(1)
            )
            back_center_line = bd.Line(
                hinge_back_loc.position,
                hinge_front_loc.position,
                mode=bd.Mode.PRIVATE
            )
            const_center_line = bd.PolarLine(
                start=back_center_line.end_point(),
                direction=back_center_line.tangent_at(1),
                length=100,
                mode=bd.Mode.PRIVATE
            )
            const_reach_line = bd.IntersectingLine(
                start=reach_line.start_point(),
                direction=-reach_line.tangent_at(),
                other=const_center_line,
                mode=bd.Mode.PRIVATE
            )
            front_center_arc = bd.CenterArc(
                center=const_reach_line.end_point(),
                radius=const_reach_line.length,
                start_angle=90,
                arc_size=45 - EPS
            )
            front_corner_line = bd.Line(
                front_center_arc.end_point(),
                reach_line.start_point(),
            )
            bd.offset(
                amount=edge,
                side=bd.Side.LEFT,
                closed=False,
                kind=bd.Kind.INTERSECTION
            )
            if fillet_radius > 0:
                bd.fillet(
                    [
                        outline.vertices().group_by(bd.Axis.X)[0],
                        outline.vertices().sort_by(bd.Axis.Y)[0]
                    ],
                    radius=fillet_radius
                )
            outline_wire = bd.Wire(outline.edges())
            bd.add(outline_wire.close())
        bd.make_face()
        full_center_width = center_width + p.center_width
        if add_center:
            center_edge = sketch.edges().sort_by(bd.Axis.X)[-1]
            center_edge.color = "cyan"
            bd.add(
                bd.Face.extrude(
                    center_edge,
                    direction=(full_center_width, 0)
                )
            )
        if sensor_cutout:
            home_angle = (
                p.Columns[Finger.HOME].splay
                + p.Columns[Finger.REACH].splay
            )
            with bd.BuildLine():
                sensor_front_line = bd.PolarLine(
                    start=home_back_loc.position,
                    angle=home_angle,
                    length=100
                )
                sensor_outside_line = bd.PolarLine(
                    start=home_back_loc.position,
                    direction=(0, 1),
                    length=100
                )
                sensor_back_line = bd.PolarLine(
                    start=sensor_outside_line.end_point(),
                    angle=home_angle,
                    length=100
                )
                sensor_center_line = bd.Line(
                    sensor_back_line.end_point(),
                    sensor_front_line.end_point()
                )
            bd.make_face(mode=bd.Mode.SUBTRACT)
    return sketch.face()

def frame_section(
    parameters: Parameters,
    plane: bd.Plane = bd.Plane.XY,
    height: float = None,
    fillet: bool = True
) -> bd.Sketch:
    p = parameters
    if height is None:
        height = p.height
        main_radius = p.Frame.main_radius
    else:
        main_radius = p.height*p.Frame.main_radius/p.height
    with bd.BuildSketch(plane) as sketch:
        with bd.BuildLine() as line:
            pl = bd.Polyline(
                (p.Frame.thickness - p.Frame.lip_depth, -height),
                (0, -height),
                (0, -height + p.Plates.Bottom.thickness),
                (-p.Frame.lip_depth, -height + p.Plates.Bottom.thickness),
                (
                    -p.Frame.lip_depth,
                    -p.Keycap.profile.height - p.Switch.model.height.upper
                ),
                (
                    -2*p.Frame.lip_depth,
                    -p.Keycap.profile.height - p.Switch.model.height.upper
                ),
                (-2*p.Frame.lip_depth, -p.Plates.Top.thickness),
                (0, -p.Plates.Top.thickness),
                (0, 0),
                (
                    (
                        p.Frame.thickness
                        - p.Frame.lip_depth
                        - height*tand(p.Frame.chord_angle)
                    ),
                    0
                )
            )
            bd.RadiusArc(
                start_point=pl.start_point(),
                end_point=pl.end_point(),
                radius=main_radius
            )
        bd.make_face()
        if fillet:
            bd.fillet(
                sketch.vertices().sort_by(bd.Axis.X)[-2:],
                radius=p.Frame.fillet_radius
            )
    return sketch.sketch

def frame_screw_locations(
    outline: bd.Face,
    min_length: float = 10
) -> bd.Locations:
    long_edges = outline.edges().filter_by(
        lambda e: e.length >= min_length
    ).edges().filter_by(lambda e: e.tangent_at() != (0, 1, 0))
    back_outside_edge = long_edges.sort_by(bd.Axis.Y)[-1]
    back_center_edge = long_edges.sort_by(bd.Axis.Y)[-2]
    outside_edge = long_edges.sort_by(bd.Axis.X)[0]
    front_outside_edge = long_edges.sort_by(bd.Axis.Y)[3]
    front_center_edge = long_edges.sort_by(bd.Axis.Y)[0]
    edges = [
        back_center_edge,
        back_outside_edge,
        outside_edge,
        front_outside_edge,
        front_center_edge
    ]
    return bd.Locations([
        edge.location_at(0.5, x_dir=(0, 0, 1)) * bd.Rot(90, 90, 0)
        for edge in edges
    ])

def center_screw_locations(
    outline: bd.Face,
    x_offset: float = 0,
    y_offsets: Sequence[float] = [0, 0, 0]
) -> bd.Locations:
    center_edge = outline.edges().sort_by(bd.Axis.X)[-1]
    return bd.Locations([
        center_edge.start_point() + (x_offset, y_offsets[0], 0),
        center_edge.center() + (x_offset, y_offsets[1], 0),
        center_edge.end_point() + (x_offset, y_offsets[2], 0)
    ])

def screw_locations(
    outline: bd.Face,
    min_length: float = 10,
    x_offset: float = 0,
    y_offsets: Sequence[float] = [0, 0, 0]
) -> bd.Locations:
    return bd.Locations(
        frame_screw_locations(outline, min_length).locations
        + center_screw_locations(outline, x_offset, y_offsets).locations
    )


if __name__ == "__main__":
    from ocp_vscode import show
    parameters = load_parameters("cad/androphage.yaml")
    show(
        # bd.Locations(list(build_key_locations(parameters).values()))
        # * bd.Rectangle(width=18, height=17)
        build_plate_outline(
            parameters,
            edge=2,
            fillet_radius=1
        )
    )
