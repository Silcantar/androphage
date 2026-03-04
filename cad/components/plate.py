import typing

import build123d as bd

from androphage_common import *

class Plate(Component):
    def __init__(
        self,
        align: bd.Align | tuple[bd.Align, bd.Align, bd.Align] = bd.Align.NONE,
        color: Iterable | str = 'silver',
        mode: bd.Mode = bd.Mode.ADD,
        rotation: Iterable = [0, 0, 0],
    ):
        super().__init__(align, color, mode, rotation)

    def build(self):
        pass