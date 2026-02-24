import cadquery as cq
from ocp_vscode import show

part = cq.Workplane('XY').box(10,20,30)

show(part)