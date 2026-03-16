import typing
from enum import StrEnum, auto

import build123d as bd

from common import *

class PlateType(StrEnum):
    BOTTOM = auto()
    PCB = auto()
    SWITCH = auto()
    TOP = auto()

class Plate(Component):
    def __init__(
        self,
        key_locations: LocationDict,
        outline: bd.Face,
        label: str = None,
        cutout: bd.VectorLike = (14, 14),
        offset: float = 4,
        radius_outer: float = 2,
        radius_inner: float = 0.5,
        spacing: bd.VectorLike = (18, 17),
        thickness: float = 1.2,
        plate_type: PlateType = PlateType.SWITCH,
        **kwargs
    ):
        self.key_locations = key_locations
        self.outline = outline
        self.cutout = cutout
        self.offset = offset
        self.radius_inner = radius_inner
        self.radius_outer = radius_outer
        self.spacing = spacing
        self.thickness = thickness
        self.plate_type = plate_type
        if label is None:
            self.label = f"{plate_type.title()} Plate"
        super().__init__(label, **kwargs)

    def build(self) -> bd.Part:
        with bd.BuildPart() as plate:
            with bd.BuildSketch() as sketch:
                # Create the outline.
                bd.offset(
                    self.outline,
                    amount=self.offset,
                    kind=bd.Kind.INTERSECTION
                )
                # bd.fillet(
                #     (
                #         sketch.vertices().group_by(bd.Axis.X)[-1]
                #         # + sketch.vertices().group_by(bd.Axis.Y)[0]
                #     ),
                #     radius=self.radius_outer
                # )
                # Create the switch-mounting cutouts in the switch plate.
                if self.plate_type == PlateType.SWITCH:
                    with self.key_locations.locations():
                        bd.RectangleRounded(
                            *self.cutout,
                            radius=self.radius_inner,
                            mode=bd.Mode.SUBTRACT
                        )
                # Create the cutout in the top plate.
                if self.plate_type == PlateType.TOP:
                    with self.key_locations.locations():
                        pass
            bd.extrude(amount=self.thickness)
        return plate.part

if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    show(
        Plate(
            androphage.key_locations,
            androphage.plate_outline,
            # offset=0
        )
    )