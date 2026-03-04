import typing
import yaml

import build123d as bd
from ocp_vscode import show

from androphage_common import key_locations, Align

with open('/home/joshua/Repositories/androphage/cad/androphage.yaml') as yamlfile:
    yamldict = yaml.safe_load(yamlfile)
kl = key_locations(yamldict['columns'], yamldict['spacing'])
with bd.BuildPart() as keys:
    with kl:
        bd.Box(
            yamldict['spacing'][0],
            yamldict['spacing'][1],
            1,
            align=Align.LeftFront
        )
show(keys)