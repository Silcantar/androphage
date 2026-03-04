import typing
from collections.abc import Iterable

import build123d as bd

from androphage_common import *

class Battery(Component):
    '''
        Standard lithium-polymer battery. Default size is 403450.
    '''
    def __init__(
        self,
        align: bd.Align | tuple[bd.Align, bd.Align, bd.Align] = bd.Align.NONE,
        color: Iterable | str = 'gainsboro',
        mode: bd.Mode = bd.Mode.ADD,
        rotation: Iterable = [0, 0, 0],
        size: Iterable = [34, 4.0, 50]
    ):
        self.size = size
        super().__init__(align, color, mode, rotation)

    def build(self) -> bd.Part:
        with bd.BuildPart() as battery:
            with bd.BuildSketch() as sketch:
                bd.RectangleRounded(
                    self.size.X,
                    self.size.Y,
                    self.size.Y/2 - EPS
                )
            bd.extrude(amount=self.size.Z)
        return battery.part

    @property
    def size(self):
        return self._size

    @size.setter
    def size(self, value: Iterable):
        self._size = bd.Vector(value)

if __name__ == '__main__':
    from ocp_vscode import show
    show(Battery())