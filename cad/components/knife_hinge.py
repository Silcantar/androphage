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
        self.parameters.Hinge.diameter = 6
        self.parameters.Hinge.pin_diameter = 3
        self.parameters.Hinge.thickness = 3
        self.parameters.Hinge.plate_thickness = 1/16*INCH
        self.parameters.Hinge.taper_pin_diameter = 0.0611*INCH
        self.parameters.Hinge.taper_pin_position = 6
        self.parameters.Hinge.screw_position = 3.5
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
            bd.Pos(Z=-1.5*p.Hinge.plate_thickness) * self.knuckle_plate(),
            bd.Pos(Z=-0.5*p.Hinge.plate_thickness) * self.plate(),
            bd.Pos(Z=0.5*p.Hinge.plate_thickness) * bd.Rot(X=180) * self.knuckle_plate(),
            bd.Pos(Z=1.5*p.Hinge.plate_thickness) * self.plate()
        ]
        hinge = bd.Part(children=component_list)
        hinge -= (
            bd.Locations([
                bd.Location(
                    position=(p.Hinge.thickness/2, i*p.Hinge.screw_position, 0),
                    orientation=(0, 90, 0)
                )
                for i in [-1, 1]
            ])
            * bd.CounterSinkHole(
                radius=self.hinge_screw.diameter/2,
                depth=BIG,
                counter_sink_radius=self.hinge_screw.counter_sink_diameter/2,
                counter_sink_angle=self.hinge_screw.head_angle
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
        plate -= (
            taper_pin_locs
            * bd.Cylinder(
                radius=p.Hinge.taper_pin_diameter/2,
                height=p.Hinge.plate_thickness
            )
        )
        plate -= bd.Cylinder(
            radius=self.hinge_screw.diameter/2,
            height=p.Hinge.plate_thickness
        )
        return plate

    def knuckle_plate(self) -> bd.Part:
        p = self.parameters
        plate = self.plate()
        pin_loc = bd.Pos(p.Hinge.thickness/2, p.Hinge.height/2, 0)
        plate += (
            pin_loc
            * bd.Box(
                length=p.Hinge.thickness,
                width=p.Hinge.thickness,
                height=p.Hinge.plate_thickness,
                align=Align.RightBack
            )
        )
        plate += (
            pin_loc
            * bd.Cylinder(
                radius=p.Hinge.diameter/2,
                height=p.Hinge.plate_thickness
            )
        )
        plate -= (
            pin_loc
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
    knife_hinge = KnifeHinge(p)
    show(knife_hinge)
    # bd.export_step(
    #     to_export=knife_hinge,
    #     file_path="cad/production/knife_hinge.step"
    # )