import typing
from collections.abc import Sequence
from math import sin, cos

import build123d as bd

from androphage_common import *

def key_positions(defs: dict[str, any]) -> dict[str, list[bd.Vector]]:
    spacing = defs['spacing']
    cutout = defs['cutout']

    return place_columns(defs['columns'])

def place_columns(columns: dict[str, any]) -> dict[str, list[bd.Vector]]:
    column = columns.popitem()

    if len(columns) == 0:
        return key_positions
    else:
        return key_positions.append(place_columns(columns))



testyaml = '''
  spacing: [18, 17]
  cutout: [14, 14]
  columns:
    thumb_inner:
      suppress: false
      keys: 1
      stagger: 0
      splay: 0
      spread: 0
    thumb_home:
      suppress: false
      keys: 2
      stagger: 0
      splay: 10
      spread: 0
    thumb_outer1:
      suppress: false
      keys: 1
      stagger: 0
      splay: 10
      spread: 0
    thumb_outer2:
      suppress: false
      keys: 1
      stagger: 0
      splay: 10
      spread: 0
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
    print(key_positions(yaml.safe_load(testyaml)))