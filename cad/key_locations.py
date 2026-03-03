import typing
from collections.abc import Sequence
from math import sin, cos

import build123d as bd

from androphage_common import *

def key_locations(defs: dict[str, any]) -> bd.LocationList:
    spacing = bd.Vector(defs['spacing'])
    cutout = bd.Vector(defs['cutout'])

    positions: list[bd.Location] = []
    origin = bd.Location([0, 0])
    columns = defs['columns']
    for column_key in columns:
        column = columns[column_key]
        if column['suppress']:
            next
        for i in range(0, column['keys']):
            splay = -column['splay']
            positions.append(
                origin * bd.Location(
                    position=[0, i*spacing.Y],
                    orientation=[0, 0, -column['splay']]
                )
            )
        origin *= bd.Location(
            position=[column['spread']*spacing.X, column['stagger']*spacing.Y],
            orientation=[0, 0, -column['splay']]
        )
    return bd.LocationList(positions)

testyaml = '''
  spacing: [18, 17]
  cutout: [14, 14]
  columns:
    thumb_inner:
      suppress: false
      keys: 1
      stagger: 0
      splay: 0
      spread: 1
    thumb_home:
      suppress: false
      keys: 2
      stagger: 0
      splay: 10
      spread: 1
    thumb_outer1:
      suppress: false
      keys: 1
      stagger: 0
      splay: 10
      spread: 1
    thumb_outer2:
      suppress: false
      keys: 1
      stagger: 0
      splay: 10
      spread: 1
    finger_inner:
      suppress: false
      keys: 3
      stagger: 1
      splay: 0
      spread: -1
    finger_index:
      suppress: false
      keys: 3
      stagger: 0
      splay: 0
      spread: 1
    finger_middle:
      suppress: false
      keys: 4
      stagger: -0.5
      splay: 0
      spread: 1
    finger_ring:
      suppress: false
      keys: 4
      stagger: -0.5
      splay: 5
      spread: 1
    finger_pinky:
      suppress: false
      keys: 3
      stagger: 0.5
      splay: 10
      spread: 1
    finger_outer:
      suppress: true
      keys: 2
      stagger: 0.5
      splay: 0
      spread: 1
'''

if __name__ == '__main__':
    import yaml
    from ocp_vscode import show
    kl = key_locations(yaml.safe_load(testyaml))
    print(kl.locations)
    with bd.BuildPart() as keys:
        bd.Box(1,1,1)
        with kl:
            bd.Box(1, 1, 1)
    show(keys)