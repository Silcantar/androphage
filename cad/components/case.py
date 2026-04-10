import typing

import build123d as bd
from ocp_vscode import show

from androphage import Androphage
from center_block import CenterBlock
from frame import Frame
from plate import Plate, PlateType

p = Androphage(build=False).parameters

# with bd.BuildPart() as case:
case_left = CenterBlock(p).move(bd.Pos(
    0, 
    2*p.Frame.lip_depth, 
    -p.Plates.Top.thickness
))

case_left += Frame(p)

case_left += Plate(
    p, 
    plate_type=PlateType.TOP,
    draft_center=True
).move(bd.Pos(0, 0, p.Plates.Top.z_pos))

case_left = bd.Rot(Y=p.tent_angle) * case_left

case_right = bd.mirror(case_left, about=bd.Plane.YZ).move(bd.Pos(X=2))

# (case_left, case_right) = bd.pack((case_left, case_right), padding=2)

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