import typing

import build123d as bd

from common import *

def screw_boss_vertical(
    hole_depth: float = 4,
    hole_diameter: float = 2.8,
    overhang_angle: float = 45,
    wall_thickness: float = 1.6,
) -> bd.Part:
    width = hole_diameter + 2*wall_thickness
    with bd.BuildPart() as boss:
        with bd.BuildSketch() as sketch:
            bd.Rectangle(
                width=width/2,
                height=width,
                align=Align.Left
            )
            bd.Circle(radius=width/2)
        bd.extrude(
            amount=(
                hole_depth
                + wall_thickness
                + width*tand(overhang_angle)
            ),
        )
        bd.draft(
            faces=boss.faces().sort_by(bd.Axis.Z)[-1],
            neutral_plane=bd.Plane(boss.faces().sort_by(bd.Axis.X)[-1]),
            angle=-overhang_angle
        )
    return boss.part

if __name__ == "__main__":
    # Test fasteners
    from bd_warehouse.fastener import (
        PanHeadScrew,
        CounterSunkScrew,
        HeatSetNut
        )
    from ocp_vscode import show

    panhead_screw = bd.Pos(X=-10) * PanHeadScrew("M2-0.4", 4)
    countersunk_screw = CounterSunkScrew(
        "M2-0.4",
        length=6,
        fastener_type="iso14581"
        )
    insert = bd.Pos(X=10) * HeatSetNut("M2-0.4-Standard")

    show(
        panhead_screw,
        countersunk_screw,
        insert,
        render_joints=True
        )
