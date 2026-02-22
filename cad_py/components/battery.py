import typing
from typing import Iterable

from androphage_common import Vector3, Vector4

from openscad import show, hull, cylinder

class Battery:
    def __init__(
        self,
        size: Iterable = [30, 12, 3],
        color: Iterable | str = 'silver'
    ):
        self.size = Vector3(*size)
        if isinstance(color, str):
            self.color = color
        else:
            self.color = Vector4(color)

    def show(self):
        hull([
            cylinder(
                d=self.size.z,
                h=self.size.x,
                center=True
            ).front(i*self.size.y/2) for i in [-1, 1]
        ]).color(self.color).show()

if __name__ == '__main__':
    fa = 1
    fs = 0.1
    Battery().show()