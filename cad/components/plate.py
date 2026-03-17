import typing
from enum import StrEnum, auto

import build123d as bd

from common import *
from parameters import Columns

class PlateType(StrEnum):
    BOTTOM = auto()
    PCB = auto()
    SWITCH = auto()
    TOP = auto()

class Plate(Component):
    def __init__(
        self,
        columns: Columns,
        key_locations: LocationDict,
        outline: bd.Face,
        center_width: float = 0,
        color: bd.ColorLike = "CornflowerBlue",
        cutout: bd.VectorLike = (14, 14),
        label: str = None,
        offset: float = 4,
        plate_type: PlateType = PlateType.SWITCH,
        radius_outer: float = 2,
        radius_inner: float = 0.5,
        spacing: bd.VectorLike = (18, 17),
        thickness: float = 1.2,
        **kwargs
    ):
        self.columns = columns
        self.key_locations = key_locations
        self.outline = outline
        self.center_width = center_width
        self.cutout = cutout
        self.offset = offset
        self.radius_inner = radius_inner
        self.radius_outer = radius_outer
        self.spacing = spacing
        self.thickness = thickness
        self.plate_type = plate_type
        if label is None:
            self.label = f"{plate_type.title()} Plate"
        super().__init__(self.label, **kwargs)

    def build(self) -> bd.Part:
        with bd.BuildPart() as plate:
            with bd.BuildSketch() as sketch:
                # Create the outline.
                bd.add(self.outline)
                bd.fillet(
                    sketch.vertices().group_by(bd.Axis.X)[:-1],
                    radius=self.radius_outer
                )
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
                        bd.Rectangle(
                            *self.spacing,
                            mode=bd.Mode.SUBTRACT
                        )
            bd.extrude(amount=self.thickness)
            if self.center_width > 0:
                bd.extrude(
                    plate.faces().group_by(bd.Axis.X)[-1],
                    amount=self.center_width
                )
        return plate.part

if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    show(
        Plate(
            androphage.parameters.Columns,
            androphage.build_key_locations(),
            androphage.build_plate_outline(edge=5),
            center_width=5,
            plate_type=PlateType.TOP
        )
    )