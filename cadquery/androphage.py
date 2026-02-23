import cadquery as cq
#from cadquery.vis import show
from ocp_vscode import *

part = cq.Workplane('XY').box(10,20,30)

show(part)