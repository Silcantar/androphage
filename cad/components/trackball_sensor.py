import typing

import build123d as bd

from common import *
from parameters import Parameters

class TrackballSensor(Component):
    """Pixart PMW3610 trackball sensor with PCB and lens."""

    def __init__(
        self,
        parameters: Parameters,
        label: str = "Trackball Sensor",
        mode: bd.Mode = bd.Mode.ADD,
        **kwargs
    ):
        self.parameters = parameters
        self.mode = mode
        super().__init__(label, mode=mode, **kwargs)

    def _build(self) -> bd.Compound:
        p = self.parameters
        ps = self.parameters.TrackballSensor
        components: list[bd.Part] = []
        with bd.BuildPart() as lens:
            with bd.Locations((0, ps.optical_center, ps.clearance)):
                bd.Box(*ps.lens_size, align=Align.Bottom)
        lens.part.color = ("White", 0.3)
        lens.part.label = "Lens"
        components.append(lens.part)
        with bd.BuildPart() as pcb:
            with bd.Locations((0, 0, ps.clearance + ps.lens_size[2])):
                bd.Box(*ps.pcb_size, align=Align.Bottom)
        pcb.part.color = "DarkGreen"
        pcb.part.label = "PCB"
        components.append(pcb.part)
        with bd.BuildPart() as chip:
            with bd.Locations(
                lens.part.faces().sort_by(bd.Axis.Z)[-1].center()
                + (0, 0, ps.pcb_size[2])
            ):
                bd.Box(*ps.chip_size, align=Align.Bottom)
        chip.part.color = Color.black.value
        chip.part.label = "PMW3610"
        components.append(chip.part)
        if self.mode == bd.Mode.SUBTRACT:
            with bd.BuildPart() as cutter:
                bd.Cylinder(
                    radius=ps.hole_size/2,
                    height=ps.clearance,
                    align=Align.Bottom
                )
            cutter.part.color = ("Yellow", 0.3)
            cutter.part.label = "Cutter"
            components.append(cutter.part)
        return bd.Part(children=components)


if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    show(TrackballSensor(androphage.parameters, mode=bd.Mode.SUBTRACT))