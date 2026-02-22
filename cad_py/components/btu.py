import typing

from androphage_common import Vector3

from openscad import show, cylinder, sphere

class BTU:
    def __init__(
        self,
        angles: typing.Iterable = [45, 0, 45],
        d: float = 4,
        D: float = 9,
        D1: float = 7.5,
        H: float = 1,
        L: float = 4,
        L1: float = 1.1
    ):
        self.angles = Vector3(*angles)
        self.d = d
        self.D = D
        self.D1 = D1
        self.H = H
        self.L = L
        self.L1 = L1


if __name__ == '__main__':
    fa = 1
    fs = 0.1
    BTU().show()