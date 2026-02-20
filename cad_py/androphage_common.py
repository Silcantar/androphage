import typing

class Vector2(typing.NamedTuple):
    x: float
    y: float

class Vector3(typing.NamedTuple):
    x: float
    y: float
    z: float = 0

#    r = self.x
#    g = self.y
#    b = self.z

class Vector4(typing.NamedTuple):
    x: float
    y: float
    z: float = 0
    w: float = 1

#    r = self.x
#    g = self.y
#    b = self.z
#    a = self.w
