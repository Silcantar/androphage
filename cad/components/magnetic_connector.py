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
        connector_sketch = bd.Plane.YZ * bd.RectangleRounded(
            width=size.Y,
            height=size.Z,
            radius=size.Z/2 - EPS
            )
        connector = bd.extrude(
            to_extrude=connector_sketch,
            amount=size.X,
            dir=(-1, 0, 0)
            )
        lip_loc = bd.Location(
            position=(
                connector.faces().sort_by(bd.Axis.X)[-1].center()
                - (p.lip_offset, 0, 0)
            ),
            orientation=(0, 90, 0)
            )
        lip_sketch = lip_loc * bd.RectangleRounded(
            width=lip.Z,
            height=lip.Y,
            radius=lip.Z/2 - EPS
            )
        lip_thickness = (
            lip.X if self.mode != bd.Mode.SUBTRACT
            else size.Y - p.lip_offset
            )
        connector += bd.extrude(
            to_extrude=lip_sketch,
            amount=lip_thickness,
            dir=(-1, 0, 0)
            )
        connector.color = self.color
        connector.label = "Connector"
        components.append(connector)
        pcb_plane = bd.Plane(connector.faces().sort_by(bd.Axis.X)[0])
        pcb_sketch = pcb_plane * bd.RectangleRounded(
            width=pcb_size.Y,
            height=pcb_size.Z,
            radius=self.parameters.Plates.PCB.radius_outer
            )
        self.hole_locations = [
            pcb_plane
            * bd.Pos(X=i*p.screw_offset)
            for i in [1, -1]
            ]
        pcb_sketch -= self.hole_locations * bd.Circle(
            radius=self.parameters.MagneticConnector.screw.hole_diameter/2,
            )
        pcb = bd.extrude(
            to_extrude=pcb_sketch,
            amount=pcb_size.X
            )
        pcb.color = seq_to_color(self.parameters.Plates.PCB.color)
        pcb.label = "PCB"
        components.append(pcb)
        return bd.Part(children=components)

    def _joints(self):
        bd.RigidJoint(
            label="connector",
            to_part=self,
            joint_location=bd.Pos(0, 0, 0)
            )
        for (i, location) in enumerate(self.hole_locations):
            bd.RigidJoint(
                label=f"panhead_{i}",
                to_part=self,
                joint_location=(
                    bd.Pos(X=-self.parameters.TrackballSensor.pcb_size[Z])
                    * location
                    )
                )


if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    show(MagneticConnector(androphage.parameters), render_joints=True)