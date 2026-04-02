import typing

import build123d as bd

from common import *
from parameters import Parameters

class Battery(Component):
    """Standard lithium-polymer battery. Default size is 403450."""
    def __init__(
        self,
        parameters: Parameters,
        label: str = "Battery",
        color: bd.ColorLike = "Silver",
        **kwargs
    ):
        self.parameters = parameters
        # self.size = size
        super().__init__(label, color=color, **kwargs)

    def _build(self) -> bd.Part:
        size = bd.Vector(self.parameters.Battery.size)
        with bd.BuildPart() as battery:
            with bd.BuildSketch() as sketch:
                bd.RectangleRounded(
                    size.X,
                    size.Y,
                    size.Y/2 - EPS
                )
            bd.extrude(amount=size.Z)
        return battery.part


if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    show(Battery(androphage.parameters))