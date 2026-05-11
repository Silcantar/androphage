import typing

import build123d as bd
from bd_warehouse.fastener import SocketHeadCapScrew

from common import *
from parameters import Parameters

class KnifeHinge(Component):
    """Custom double-ended knife hinge using https://www.mcmaster.com/95446A110/
    as the pin.
    """

    def __init__(
        self,
        parameters: Parameters,
        label: str = "Knife Hinge",
        **kwargs
    ):
        self.parameters = parameters
        self.parameters.Hinge.diameter = 0.25*INCH
        self.parameters.Hinge.pin_diameter = 0.0890*INCH # Pilot hole for 4-40 screw
        self.parameters.Hinge.thickness = 0.25*INCH
        self.parameters.Hinge.knuckle_length = 0.125*INCH
        self.hinge_screw = self.parameters.Screws.M2
        self.parameters.Hinge.height = self.parameters.height/cosd(self.parameters.tent_angle)
        try:
            color
        except NameError:
            color = seq_to_color(self.parameters.Hinge.color)
        super().__init__(label=label, color=color, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters
        component_list = [
            self.leaf(),
            bd.Pos(0, p.Hinge.height/2, 0)*self.screw()
        ]
        return bd.Part(children=component_list)

    def leaf(self) -> bd.Part:
        p = self.parameters
        with bd.BuildPart() as hinge:
            leaf = bd.Box(
                length=p.Hinge.diameter/2,
                width=p.Hinge.height,
                height=p.Hinge.knuckle_length,
                align=Align.RightTop
            )
            bd.Box(
                length=p.Hinge.diameter/2,
                width=p.Hinge.height - p.Hinge.diameter,
                height=p.Hinge.thickness,
                align=Align.Right
            )
            with bd.Locations(
                leaf.vertices()
                .group_by(bd.Axis.X)[-1]
                .group_by(bd.Axis.Z)[0]
            ):
                bd.Cylinder(
                    radius = p.Hinge.diameter/2,
                    height=p.Hinge.knuckle_length,
                    align=Align.Bottom
                )
                bd.Cylinder(
                    radius=p.Hinge.pin_diameter/2,
                    height=p.Hinge.knuckle_length,
                    align=Align.Bottom,
                    mode=bd.Mode.SUBTRACT
                )
            with bd.Locations([bd.Location(
                position=(
                    leaf.edges()
                    .group_by(bd.Axis.X)[-1]
                    .sort_by(bd.Axis.Z)[-1]
                    .center()
                    + (0, i*self.hinge_screw.counter_sink_diameter, 0)
                ),
                orientation=(0, 90, 0)
            ) for i in [-1, 1]]):
                bd.CounterSinkHole(
                    radius=self.hinge_screw.diameter/2,
                    counter_sink_radius=self.hinge_screw.counter_sink_diameter/2,
                    counter_sink_angle=self.hinge_screw.head_angle
                )
        return hinge.part

    def screw(self, simple: bool = True) -> bd.Part:
        head = bd.Cylinder(
            radius=0.125*INCH,
            height=0.125*INCH,
            align=Align.Bottom
        )
        screw = head + SocketHeadCapScrew(
            size="#4-40",
            length=9/32*INCH,
            fastener_type="asme_b18.3",
            simple=simple
        )
        screw += bd.Cylinder(
            radius=0.0625*INCH,
            height=0.125*INCH,
            align=Align.Top
        )
        screw.label = "Screw"
        return screw

if __name__ == "__main__":
    from androphage import Androphage
    from ocp_vscode import show
    androphage = Androphage(build=False)
    knife_hinge = KnifeHinge(androphage.parameters)
    show(knife_hinge)
    bd.export_step(
        to_export=knife_hinge,
        file_path="cad/production/knife_hinge.step"
    )