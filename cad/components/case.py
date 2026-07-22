import typing

import build123d as bd
from ocp_vscode import show

# from androphage import Androphage
import layout, parameters
from common import sind, cosd, tand
from center_block import CenterBlock
from frame import Frame
from plate import Plate, PlateType

p = layout.set_derived_parameters(
    parameters.load_parameters("cad/androphage.yaml")
    )

case_left = Frame(p)

case_left += (
    bd.Pos(
        -p.Plates.Top.thickness * sind(p.tent_angle),
        p.Frame.lip_depth,
        -p.Plates.Top.thickness * cosd(p.tent_angle)
        )
    * bd.Rot(Y=p.tent_angle)
    * CenterBlock(p)
    )

case_left += (
    bd.Pos(
        -p.Plates.Top.thickness * tand(p.tent_angle),
        0,
        -p.Plates.Top.thickness
        )
    * Plate(
        p,
        plate_type=PlateType.TOP,
        draft_center=True
        )
    )

case_left = bd.Rot(X=180) * case_left
case_left.label = "Case Left"

case_right = bd.mirror(case_left, about=bd.Plane.YZ).move(bd.Pos(X=2))
case_right.label = "Case Right"

bd.export_stl(
    to_export=case_left,
    file_path="cad/production/case_left.stl"
)
bd.export_stl(
    to_export=case_right,
    file_path="cad/production/case_right.stl"
)
bd.export_stl(
    to_export=case_left + case_right,
    file_path="cad/production/case_combined.stl"
)
bd.export_step(
    to_export=case_left + case_right,
    file_path="cad/production/case_combined.step"
)
show(case_left, case_right)