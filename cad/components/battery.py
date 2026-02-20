import typing

from ..androphage_common import Vector3

from openscad import show, hull, cylinder

class Battery:
    def __init__(self, size: Iterable):
        self.size = Vector3(size)
        self.body = hull(
            cylinder(
                d=self.size.z,
                h=self.size.x
            ).translate(i*self.size.y/2) for i in [-1, 1]
        )

if __name__ == '__main__':
    show(Battery([12, 30, 3]))