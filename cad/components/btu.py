import typing
from collections.abc import Iterable
from enum import StrEnum, auto

import build123d as bd

from common import *

class BTUModel(StrEnum):
    Rexroth = auto()
    VCN310 = auto()
    VCN319 = auto()

class BTU(Component):
    """Common interface for BTU models.

    Origin is the top of the ball.
    """
    def __init__(
        self,
        ball_diameter: float,
        ball_height: float,
        flange_diameter: float,
        flange_height: float,
        housing_diameter: float,
        housing_height: float,
        clearance: float = 10,
        screw_diameter: float = 1.6, # Minor diameter of an M2 screw.
        color: bd.ColorLike = "DarkGray",
        label: str = "BTU",
        subtract: bool = False,
        **kwargs
    ):
        self.ball_diameter = ball_diameter
        self.ball_height = ball_height
        self.flange_diameter = flange_diameter
        self.flange_height = flange_height
        self.housing_diameter = housing_diameter
        self.housing_height = housing_height
        self.clearance = clearance
        self.screw_diameter = screw_diameter
        self.subtract = subtract
        super().__init__(label, color=color, **kwargs)

    def _build(self):
        with bd.BuildPart() as btu:
            # Ball
            bd.Sphere(radius=self.ball_diameter/2, align=Align.Top)
            with bd.Locations((0, 0, -self.ball_height)):
                # Flange
                if self.flange_height != 0:
                    bd.Cylinder(
                        radius=self.flange_diameter/2,
                        height=self.flange_height,
                        align=Align.Top
                    )
                # Main Housing
                bd.Cylinder(
                    radius=self.housing_diameter/2,
                    height=self.housing_height + self.flange_height,
                    align=Align.Top
                )
                # Clearance cutters
                if self.subtract:
                    # Clearance above
                    bd.Cylinder(
                        radius=self.flange_diameter/2,
                        height=self.clearance,
                        align=Align.Bottom
                    )
                    # Adjustment screw hole
                    bd.Cylinder(
                        radius=self.screw_diameter/2,
                        height=self.clearance,
                        align=Align.Top
                    )
        return btu.part

    @classmethod
    def by_model_name(cls, model: BTUModel | str, **kwargs):
        if isinstance(model, str):
            model = model.lower()
        match model:
            case BTUModel.Rexroth:
                return cls.Rexroth(**kwargs)
            case BTUModel.VCN310:
                return cls.VCN310(**kwargs)
            case BTUModel.VCN319:
                return cls.VCN319(**kwargs)
            case _:
                raise ValueError("Invalid BTU model!")

    @classmethod
    def Rexroth(
        cls,
        ball_diameter: float = 7.938, # d
        ball_height: float = 1.6, # h - b
        collar_height: float = 1.3, # b - a
        flange_diameter: float = 17, # D1
        flange_height: float = 1.9, # a
        housing_diameter: float = 12.6, # D
        housing_height: float = 6.4, # H - h
        **kwargs
    ):
        """Bosch Rexroth KU-B8-OFK Ball Transfer Unit.

        https://store.boschrexroth.com/en/us/p/ball-transfer-unit-r053010810
        """
        btu = cls(
            ball_diameter,
            ball_height + collar_height,
            flange_diameter,
            flange_height,
            housing_diameter,
            housing_height,
            **kwargs
        )
        btu.collar_height = collar_height
        return btu

    @classmethod
    def VCN310(
        cls,
        ball_diameter: float = 4, #d
        ball_height: float = 1.1, # L1
        flange_diameter: float = 9, # D
        flange_height: float = 1, # H
        housing_diameter: float = 7.5, # D1
        housing_height: float = 4, # L
        **kwargs
    ):
        """Veichu VCN310 BTU.

        https://www.aliexpress.us/item/3256802880089745.html
        """
        return cls(
            ball_diameter,
            ball_height,
            flange_diameter,
            flange_height,
            housing_diameter,
            housing_height,
            **kwargs
        )

    @classmethod
    def VCN319(
        cls,
        ball_diameter: float = 4.76, # d
        ball_height: float = 1.2, # L1
        housing_height: float = 14.8, # L - L1
        housing_diameter: float = 7, # D
        drive_depth: float = 6, # t
        drive_width: float = 5, # S
        **kwargs
    ):
        """Veichu VCN319 BTU.

        https://www.aliexpress.us/item/3256802885551436.html
        """
        btu = cls(
            ball_diameter,
            ball_height,
            housing_diameter, # flange_diameter
            0, # flange_height
            housing_diameter,
            housing_height,
            **kwargs
        )
        btu.drive_depth = drive_depth
        btu.drive_width = drive_width
        return btu


if __name__ == "__main__":
    from ocp_vscode import show
    mode = bd.Mode.ADD
    show(
        BTU.Rexroth(mode=mode).move(bd.Pos(-20, 0, 0)),
        BTU.VCN310(mode=mode),
        BTU.VCN319(mode=mode).move(bd.Pos(20, 0, 0))
    )