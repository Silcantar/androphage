import typing
from collections.abc import Iterable

import build123d as bd

#from cadquery.vis import show
from ocp_vscode import show

eps = 0.001

class Battery(bd.BasePartObject):
    def __init__(
        self,
        # color: Iterable | str = 'silver',
        size: Iterable = [12, 3, 30],
    ):
        # self.color(color)
        self.size = size
        with bd.BuildPart() as battery:
            with bd.BuildSketch() as sketch:
                bd.RectangleRounded(size[0], size[1], size[1]/2 - eps)
            bd.extrude(amount=size[2])
        super().__init__(
            part=battery.part,
            # rotation=rotation,
            # align=align,
            # mode=mode
        )

    # @property
    # def color(self):
    #     return self._color

    # @color.setter
    # def color(self, value: Iterable | str):
    #     if isinstance(value, str):
    #         self._color = bd.Color(name=value)
    #     else:
    #         self._color = bd.Color(
    #             red=value[0],
    #             green=value[1],
    #             blue=value[2],
    #             alpha=value[3]
    #         )

    @property
    def size(self):
        return self._size

    @size.setter
    def size(self, value: Iterable):
        self._size = bd.Vector(value)

if __name__ == '__main__':
    show(Battery())