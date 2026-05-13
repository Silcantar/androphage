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
        mirror: bool = False,
        label: str = "Knife Hinge",
        mode: bd.Mode = bd.Mode.ADD,
        **kwargs
    ):
        self.parameters = parameters
        self.mirror = mirror
        self.mode = mode
        try:
            color
        except NameError:
            color = seq_to_color(self.parameters.Hinge.color)
        super().__init__(label=label, color=color, mode=mode, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters
        if self.mode == bd.Mode.SUBTRACT:
            component_list = [
                (
                    bd.Pos(Z=(i//2 - 1.5)*p.Hinge.plate_thickness)
                    * bd.Rot(X=180*i)
                    * self.knuckle_plate()
                )
                for i in range(8)
            ]
        else:
            component_list = [
                (
                    bd.Pos(Z=(i - 1.5)*p.Hinge.plate_thickness)
                    * bd.Rot(X=180*(i//2 + (1 if self.mirror else 0)))
                    * (
                        self.knuckle_plate() if i % 2 == 0
                        else self.plate()
                    )
                )
                for i in range(4)
            ]
        hinge = bd.Part(children=component_list)
        if self.mode != bd.Mode.SUBTRACT:
            hinge -= (
                bd.Locations([
                    bd.Location(
                        position=(
                            p.Hinge.thickness/2,
                            i*p.Hinge.screw_position,
                            0
                        ),
                        orientation=(0, 90, 0)
                    ) for i in [-1, 1]
                ])
                * bd.CounterSinkHole(
                    radius=p.Hinge.screw.diameter/2,
                    depth=BIG,
                    counter_sink_radius=p.Hinge.screw.counter_sink_diameter/2,
                    counter_sink_angle=p.Hinge.screw.head_angle
                )
            )
        return hinge

    def plate(self) -> bd.Part:
        p = self.parameters
        plate = bd.Box(
            length=p.Hinge.thickness,
            width=p.Hinge.height - p.Hinge.diameter,
            height=p.Hinge.plate_thickness
        )
        taper_pin_locs = bd.Locations([
            (0, i*p.Hinge.taper_pin_position, 0)
            for i in [-1, 1]
        ])
        if self.mode != bd.Mode.SUBTRACT:
            plate -= (
                taper_pin_locs
                * bd.Cylinder(
                    radius=p.Hinge.taper_pin_diameter/2,
                    height=p.Hinge.plate_thickness
                )
            )
            plate -= bd.Cylinder(
                radius=p.Hinge.screw.diameter/2,
                height=p.Hinge.plate_thickness
            )
        return plate

    def knuckle_plate(self) -> bd.Part:
        p = self.parameters
        plate = self.plate()
        knuckle_loc = bd.Pos(p.Hinge.thickness/2, p.Hinge.height/2, 0)
        plate += (
            knuckle_loc
            * bd.Box(
                length=p.Hinge.thickness,
                width=p.Hinge.thickness,
                height=p.Hinge.plate_thickness,
                align=Align.RightBack
            )
        )
        plate += (
            knuckle_loc
            * bd.Cylinder(
                radius=p.Hinge.diameter/2,
                height=p.Hinge.plate_thickness
            )
        )
        if self.mode != bd.Mode.SUBTRACT:
            plate -= (
                knuckle_loc
                * bd.Cylinder(
                    radius=p.Hinge.pin_diameter/2,
                    height=p.Hinge.plate_thickness
                )
            )
        return plate


if __name__ == "__main__":
    from ocp_vscode import show
    import layout, parameters
    p = layout.set_derived_parameters(
        parameters.load_parameters("cad/androphage.yaml")
    )
    knife_hinge = KnifeHinge(
        p,
        # mirror = True,
        # mode=bd.Mode.SUBTRACT
    )
    show(knife_hinge)
    # bd.export_step(
    #     to_export=knife_hinge,
    #     file_path="cad/production/knife_hinge.step"
    # )