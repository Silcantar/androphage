import typing

import build123d as bd

from common import *
from parameters import Parameters

def build_column_locations(p: Parameters) -> KeyLocationDict:
    """Calculate the locations of the origin of each column."""
    spc = p.spacing
    column_locations = KeyLocationDict()
    origin = bd.Location((0, 0))
    for column_key in p.Columns:
        column = p.Columns[column_key]
        origin *= bd.Location(
            position=(-0.5*spc.X, -0.5*spc.Y)
        ) * bd.Location(
            position=(column.spread*spc.X, column.stagger*spc.Y),
            orientation=(0, 0, -column.splay)
        ) * bd.Location(
            position=(0.5*spc.X, 0.5*spc.Y)
        )
        origin.label = column_key
        if not column.skip:
            column_locations[column_key] = origin
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
        for column in p.Columns
    ])
    hinge_front_loc = (
        kl["reach_0"]
        * bd.Pos(inside, back)
        * bd.Rot(Z=total_splay)
        * bd.Pos(0, -edge)
    )
    hinge_back_loc = (
        hinge_front_loc
        * bd.Pos(0, p.Hinge.length + 2*edge)
    )
    middle_back_loc = (
        kl["middle_3"]
        * bd.Pos(inside, back + edge)
    )
    reach_front_loc = (
        kl["reach_0"]
        * bd.Pos(center, front - edge)
    )
    reach_front_inside_loc = (
        kl["reach_0"]
        * bd.Pos(inside + edge, front - edge)
    )
    home_front_loc = (
        kl["home_0"]
        * bd.Pos(center, front - edge)
    )
    index_front_loc = (
        kl["index_0"]
        * bd.Pos(center, front - edge)
    )
    ring_front_loc = (
        kl["ring_0"]
        * bd.Pos(outside, front - edge)
    )
    pinky_front_loc = (
        kl[f"{last_column}_0"]
        * bd.Pos(outside - edge, front - edge)
    )
    pinky_back_loc = (
        kl[f"{last_column}_{last_key}"]
        * bd.Pos(outside - edge, back + edge)
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
                reach_front_loc.position
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
                arc_size=45
            )
            center_line = bd.Line(
                hinge_back_loc.position,
                front_center_arc.start_point()
            )
            del back_center_line
            del const_center_line
            del const_reach_line
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
        # Fillet all but the right-most group of vertices.
        if fillet_radius > 0:
            fillet_index = -2 if add_center else -1
            bd.fillet(
                sketch.vertices().group_by(bd.Axis.X)[:fillet_index],
                radius=fillet_radius
            )
    return sketch.face()

if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    show(Androphage())
