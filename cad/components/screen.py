import typing

import build123d as bd

from common import *
from parameters import Parameters

class Screen(Component):
    """OLED/LCD/ePaper display like Nice!View or similar """
    def __init__(
        self,
        parameters: Parameters,
        label: str = "Screen",
        **kwargs
    ):
        self.parameters = parameters
        try:
            color
        except NameError:
            color = seq_to_color(self.parameters.Screen.color)
        super().__init__(label=label, color=None, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters
        children: list[bd.Part] = []
        pcb_location = bd.Pos(Z=-p.Screen.size[Z])
        pcb = (
            pcb_location
            * bd.Box(
                *p.Screen.pcb_size,
                align=Align.BackTop
                )
            )
        pcb = bd.fillet(
            objects=pcb.edges().filter_by(bd.Axis.Z),
            radius=p.Screen.fillet_radius
            )
        pcb.label = "PCB"
        pcb.color = seq_to_color(p.Screen.color)
        children.append(pcb)
        bezel_location = bd.Pos(Y=-p.Screen.position)
        bezel = (
            bezel_location
            * bd.Box(
                *p.Screen.size,
                align=Align.BackTop
                )
            )
        display_location = bd.Pos(Y=-p.Screen.position - p.Screen.bezel)
        display = (
            display_location
            * bd.Box(
                *p.Screen.display_area,
                p.Screen.size[Z],
                align=Align.BackTop
                )
            )
        bezel -= display
        bezel.label = "Bezel"
        bezel.color = seq_to_color(p.Screen.color)
        children.append(bezel)
        display.label = "Display Area"
        display.color = "Gray"
        children.append(display)
        chip_location = bd.Pos(
            0,
            -p.Screen.pcb_size[Y]/2,
            -p.Screen.size[Z] - p.Screen.pcb_size[Z]
            )
        chip = (
            chip_location
            * bd.Box(
                *p.Screen.chip_size,
                align=Align.Top
                )
            )
        chip.label = "Chips Placeholder"
        chip.color = seq_to_color(p.Screen.color)
        children.append(chip)
        return bd.Compound(children=children)


if __name__ == "__main__":
    from ocp_vscode import show
    import layout, parameters
    p = layout.set_derived_parameters(
        parameters.load_parameters("cad/androphage.yaml")
    )
    show(Screen(p))