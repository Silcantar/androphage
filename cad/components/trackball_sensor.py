import typing

import build123d as bd

from common import *

class TrackballSensor(Component):
    """Pixart PMW3610 trackball sensor with PCB and lens."""

    def __init__(
        self,
        pcb_size: bd.VectorLike = (16, 25, 1.2),
        chip_size: bd.VectorLike = (10.9, 16.2, 1.65),
        lens_size: bd.VectorLike = (8.6, 16.96, 3.4),
        clearance: float = 2.4,
        hole_size: float = 5,
        angle: float = 60,
        holder_height: float = 15,
        holder_thickness: float = 5,
        subtract: bool = False,
        color: bd.ColorLike = None,
        label: str = "Trackball Sensor",
        **kwargs
    ):
        self.pcb_size = pcb_size
        self.chip_size = chip_size
        self.lens_size = lens_size
        self.clearance = clearance
        self.hole_size = hole_size
        self.angle = angle
        self.holder_height = holder_height
        self.holder_thickness = holder_thickness
        self.subtract = subtract
        super().__init__(label, color=color, **kwargs)

    def _build(self) -> tuple[bd.Part]:
        components: list[bd.Part] = []
        with bd.BuildPart() as lens:
            with bd.Locations((0, 0, self.clearance)):
                bd.Box(*self.lens_size, align=Align.Bottom)
        lens.part.color = ("White", 0.3)
        lens.part.label = "Lens"
        components.append(lens.part)
        with bd.BuildPart() as pcb:
            with bd.Locations(lens.part.faces().sort_by(bd.Axis.Z)[-1]):
                bd.Box(*self.pcb_size, align=Align.Bottom)
        pcb.part.color = "DarkGreen"
        pcb.part.label = "PCB"
        components.append(pcb.part)
        with bd.BuildPart() as chip:
            with bd.Locations(pcb.part.faces().sort_by(bd.Axis.Z)[-1]):
                bd.Box(*self.chip_size, align=Align.Bottom)
        chip.part.color = Color.black.value
        chip.part.label = "PMW3610"
        components.append(chip.part)
        if self.subtract:
            with bd.BuildPart() as cutter:
                with bd.Locations(lens.part.faces().sort_by(bd.Axis.Z)[0]):
                    bd.Cylinder(
                        radius=self.hole_size/2,
                        height=self.clearance,
                        align=Align.Bottom
                    )
            cutter.part.color = ("Yellow", 0.3)
            cutter.part.label = "Cutter"
            components.append(cutter.part)
        return bd.Compound(children=components)

    @property
    def pcb_size(self) -> bd.Vector:
        return self._pcb_size

    @pcb_size.setter
    def pcb_size(self, value):
        self._pcb_size = bd.Vector(value)

    @property
    def chip_size(self) -> bd.Vector:
        return self._chip_size

    @chip_size.setter
    def chip_size(self, value):
        self._chip_size = bd.Vector(value)

    @property
    def lens_size(self) -> bd.Vector:
        return self._lens_size

    @lens_size.setter
    def lens_size(self, value):
        self._lens_size = bd.Vector(value)

if __name__ == "__main__":
    from ocp_vscode import show
    show(TrackballSensor(subtract=True))