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
        super().__init__(label=label, color=None, mode=mode, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters
        ps = self.parameters.TrackballSensor
        components: list[bd.Part] = []
        lens_location = bd.Pos(0, ps.optical_center, ps.clearance)
        lens =(
            lens_location
            * bd.Box(*ps.lens_size, align=Align.Bottom)
        )
        lens.color = ("White", 0.3)
        lens.label = "Lens"
        components.append(lens)
        pcb_location = bd.Pos(0, 0, ps.clearance + ps.lens_size[2])
        pcb = (
            pcb_location
            * bd.Box(*ps.pcb_size, align=Align.Bottom)
        )
        pcb -= (
            pcb_location
            * bd.Pos(*p.TrackballSensor.screw_position)
            * bd.Hole(
                radius=p.TrackballSensor.screw.hole_diameter/2,
                depth=BIG
            )
        )
        pcb.color = seq_to_color(p.Plates.PCB.color)
        pcb.label = "PCB"
        components.append(pcb)
        chip = (
            bd.Pos(
                lens.faces().sort_by(bd.Axis.Z)[-1].center()
                + (0, 0, ps.pcb_size[2])
            )
            * bd.Box(*ps.chip_size, align=Align.Bottom)
        )
        chip.color = Color.black.value
        chip.label = "PMW3610"
        components.append(chip)
        bottom_component_location = bd.Pos(
            lens
            .edges()
            .group_by(bd.Axis.Y)[-1]
            .sort_by(bd.Axis.Z)[-1]
            .center()
            )
        bottom_component = (
            bottom_component_location
            * bd.Box(*ps.bottom_chip_size, align=Align.FrontTop)
            )
        bottom_component.color = Color.black.value
        bottom_component.label = "Bottom Components"
        components.append(bottom_component)
        if self.mode == bd.Mode.SUBTRACT:
            cutter = bd.Cylinder(
                radius=ps.hole_size/2,
                height=ps.clearance,
                align=Align.Bottom
            )
            cutter += (
                pcb_location
                * bd.Pos(Z=p.TrackballSensor.pcb_size[2])
                * bd.Pos(*p.TrackballSensor.screw_position)
                * bd.Cylinder(
                    radius=p.Insert.hole_diameter/2,
                    height=p.Insert.hole_depth + p.TrackballSensor.pcb_size[2],
                    align=Align.Top
                )
            )
            cutter += (
                lens_location
                * bd.Pos(Z=ps.lens_size[Z])
                * bd.Box(
                    length=ps.chip_size[X] + 3,
                    width=ps.chip_size[Y],
                    height=1,
                    align=Align.Top
                    )
                )
            cutter.color = ("Yellow", 0.3)
            cutter.label = "Cutter"
            components.append(cutter)
        return bd.Part(children=components)


if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    show(TrackballSensor(androphage.parameters, mode=bd.Mode.SUBTRACT))