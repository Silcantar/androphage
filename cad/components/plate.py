import typing

import build123d as bd

from androphage_common import *

class Plate(Component):
    def __init__(
        self,
        align: AlignLike = bd.Align.NONE,
        color: bd.ColorLike | str = 'silver',
        mode: bd.Mode = bd.Mode.ADD,
        rotation: bd.RotationLike = [0, 0, 0],
    ):
        super().__init__(align, color, mode, rotation)

    def build(self):
        pass