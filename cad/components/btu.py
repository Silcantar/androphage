import typing
from collections.abc import Iterable
from enum import StrEnum, auto

import build123d as bd

from common import *
from parameters import Parameters

class BTU(Component):
    """Common interface for BTU models.

    Origin is the top of the ball.
    """
    def __init__(
        self,
        parameters: Parameters,
        subtract: bool = False,
        color: bd.ColorLike = "DarkGray",
        label: str = "BTU",
        **kwargs
    ):
        self.parameters = parameters
        self.subtract = subtract
        super().__init__(label, color=color, **kwargs)

    def _build(self):
        p = self.parameters
        with bd.BuildPart() as btu:
            # Ball
            bd.Sphere(radius=p.BTU.ball_diameter/2, align=Align.Top)
            with bd.Locations((0, 0, -p.BTU.ball_height)):
                # Flange
                if p.BTU.flange_height != 0:
                    bd.Cylinder(
                        radius=p.BTU.flange_diameter/2,
                        height=p.BTU.flange_height,
                        align=Align.Top
                    )
                # Main Housing
                bd.Cylinder(
                    radius=p.BTU.housing_diameter/2,
                    height=p.BTU.housing_height + p.BTU.flange_height,
                    align=Align.Top
                )
                # Clearance cutters
                if self.subtract:
                    # Clearance above
                    bd.Cylinder(
                        radius=p.BTU.flange_diameter/2,
                        height=p.BTU.clearance,
                        align=Align.Bottom
                    )
                    # Adjustment screw hole
                    if p.BTU.adjust_screw:
                        bd.Cylinder(
                            radius=p.Screw.minor_diameter/2,
                            height=p.BTU.clearance,
                            align=Align.Top
                        )
        return btu.part


if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    show(BTU(androphage.parameters, subtract=False))