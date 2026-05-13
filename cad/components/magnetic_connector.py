import typing

import build123d as bd

from common import *
from parameters import Parameters

class MagneticConnector(Component):
    """12-pin magnetic pogo pin connector with VIK connector PCB."""

    def __init__(
        self,
        parameters: Parameters,
        label: str = "Magnetic Connector",
        mode: bd.Mode = bd.Mode.ADD,
        **kwargs
    ):
        self.parameters = parameters
        self.mode = mode
        try:
            self.color = color
        except NameError:
            self.color = seq_to_color(self.parameters.MagneticConnector.color)
        super().__init__(label=label, color=None, mode=mode, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters.MagneticConnector
        size = bd.Vector(p.size)
        lip = bd.Vector(p.lip)
        pcb_size = bd.Vector(p.pcb_size)
        components: list[bd.Part] = []
        with bd.BuildPart() as mag_con:
            with bd.BuildSketch(bd.Plane.YZ) as main_sketch:
                bd.RectangleRounded(
                    width=size.Y,
                    height=size.Z,
                    radius=size.Z/2 - EPS
                )
            bd.extrude(amount=size.X, dir=(-1, 0, 0))
            lip_loc = bd.Location(
                position=(
                    mag_con.faces().sort_by(bd.Axis.X)[-1].center()
                    - (p.lip_offset, 0, 0)
                ),
                orientation=(0, 90, 0)
            )
            with bd.BuildSketch(lip_loc) as lip_sketch:
                bd.RectangleRounded(
                    width=lip.Z,
                    height=lip.Y,
                    radius=lip.Z/2 - EPS
                )
            lip_thickness = (
                lip.X if self.mode != bd.Mode.SUBTRACT
                else size.Y - p.lip_offset
            )
            bd.extrude(amount=lip_thickness, dir=(-1, 0, 0))
        mag_con.part.color = self.color
        mag_con.part.label = "Connector"
        components.append(mag_con.part)
        pcb_plane = bd.Plane(mag_con.part.faces().sort_by(bd.Axis.X)[0])
        with bd.BuildPart() as pcb:
            with bd.BuildSketch(pcb_plane):
                bd.RectangleRounded(
                    width=pcb_size.Y,
                    height=pcb_size.Z,
                    radius=self.parameters.Plates.PCB.radius_outer
                )
                with bd.Locations([(i*p.screw_offset, 0, 0) for i in [1, -1]]):
                    bd.Circle(
                        radius=self.parameters.MagneticConnector.screw.hole_diameter/2,
                        mode=bd.Mode.SUBTRACT
                    )
            bd.extrude(amount=pcb_size.X)
        pcb.part.color = seq_to_color(self.parameters.Plates.PCB.color)
        pcb.part.label = "PCB"
        components.append(pcb.part)
        return bd.Part(children=components)


if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    show(MagneticConnector(androphage.parameters))