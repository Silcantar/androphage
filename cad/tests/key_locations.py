import typing
import yaml

import build123d as bd
from ocp_vscode import show

from androphage_common import *

try:
    with open('/home/joshua/Repositories/androphage/cad/androphage.yaml') as yamlfile:
        yamldict = yaml.safe_load(yamlfile)
except FileNotFoundError:
    with open('D:/OneDrive/Repositories/androphage/cad/androphage.yaml') as yamlfile:
        yamldict = yaml.safe_load(yamlfile)
spacing = bd.Vector(yamldict['spacing'])
kl = key_locations(yamldict['columns'], spacing)
trackball_position = 55
with bd.BuildPart(bd.Plane.XY) as keys:
    with bd.Locations((
        trackball_position*cosd(45),
        spacing.Y + trackball_position*sind(45)
    )):
        bd.Cylinder(radius=17, height=4)
    with kl.locations():
        bd.Box(
            spacing.X,
            spacing.Y,
            1,
            align=Align.LeftFrontBottom
        )
keys.label = 'Keys'
with bd.BuildPart(bd.Plane.XY) as plate:
    bd.extrude(
        # bd.offset(
            plate_outline(kl, spacing, 80),
        #     amount=4,
        #     side=bd.Side.LEFT,
        #     closed=False
        # ),
        -1
    )
plate.color = 'Plum'
plate.label = 'Plate outline'
show(keys, plate)