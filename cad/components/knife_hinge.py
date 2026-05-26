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
        laminated: boolean = True,
        knuckle_orientations: tuple[int] = (1, 0, -1, 0),
        label: str = "Knife Hinge",
        mode: bd.Mode = bd.Mode.ADD,
        **kwargs
    ):
        self.parameters = parameters
        self.laminated = laminated
        self.knuckle_orientations = knuckle_orientations
        self.mode = mode
        try:
            color
        except NameError:
            color = seq_to_color(self.parameters.Hinge.color)
        super().__init__(label=label, color=color, mode=mode, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters
        component_list: list[bd.Part] = []
        hinge = bd.Part()
        for i in range(len(self.knuckle_orientations)):
            if self.knuckle_orientations[i] == 0:
                hinge += (
                    bd.Pos(Z=(i - 1.5)*p.Hinge.plate_thickness)
                    * self.plate()
                )
            else:
                hinge += (
                    bd.Pos(Z=(i - 1.5)*p.Hinge.plate_thickness)
                    * bd.Rot(X=90 - 90*self.knuckle_orientations[i])
                    * self.knuckle_plate()
                )
        hinge -= (
            bd.Locations([
                bd.Location(
                    position=(
                        0,
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
        hinge.position -= (0, self.parameters.Hinge.height/2, 0)
        return hinge

    def plate(self) -> bd.Part:
        p = self.parameters
        plate = bd.Box(
            length=p.Hinge.thickness,
            width=(
                p.Hinge.height
                - p.Hinge.diameter
                - (0 if self.laminated else 2*p.Hinge.fillet_radius)
            ),
            height=p.Hinge.plate_thickness,
            align=Align.Right
        )
        taper_pin_locs = bd.Locations([
            (-p.Hinge.thickness/2, i*p.Hinge.taper_pin_position, 0)
            for i in [-1, 1]
        ])
        if self.laminated:
            plate -= (
                taper_pin_locs
                * bd.Cylinder(
                    radius=p.Hinge.taper_pin_diameter/2,
                    height=p.Hinge.plate_thickness
                )
            )
            plate -= bd.Pos(X=-p.Hinge.thickness/2)*bd.Cylinder(
                radius=p.Hinge.screw.diameter/2,
                height=p.Hinge.plate_thickness
            )
        return plate

    def knuckle_plate(self) -> bd.Part:
        p = self.parameters
        plate = self.plate()
        knuckle_loc = bd.Pos(0, p.Hinge.height/2, 0)
        plate += (
            knuckle_loc
            * bd.Box(
                length=p.Hinge.thickness,
                width=(
                    p.Hinge.thickness
                    + (0 if self.laminated else p.Hinge.fillet_radius)
                ),
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
        fillet_edge = (
            plate.edges()
            .filter_by(bd.Axis.Z)
            .filter_by(lambda e: e.center().Y == (p.Hinge.height - p.Hinge.diameter)/2)
        )
        plate = bd.fillet(
            objects=fillet_edge,
            radius=p.Hinge.fillet_radius
        )
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
        # laminated=False
    )
    count = 4
    hinge_multi = bd.Part()
    orientations = (
        (1, 0, -1, 0),
        (0, 0, 1, -1),
        (0, 0, -1, 1),
        (-1, 0, 1, 0)
    )
    for i in range(count):
        hinge_multi += (
            bd.Pos(Z=i*(p.Hinge.width + p.Hinge.multi_spacing))
            * KnifeHinge(
                p,
                laminated=False,
                knuckle_orientations=orientations[i]
            )
        )
    hinge_multi += bd.Pos(-p.Hinge.thickness/2, -p.Hinge.height/2, 0) * bd.Box(
        length=p.Hinge.thickness,
        width=p.Hinge.multi_connector_width,
        height=p.Hinge.width*(count - 1) + count*p.Hinge.multi_spacing,
        align=Align.Bottom
    )
    hinge_multi = bd.fillet(
        objects=hinge_multi.edges().filter_by(bd.Axis.X).group_by(bd.Axis.Y)[2:4],
        radius=0.5-EPS
    )
    show(knife_hinge, hinge_multi)
    bd.export_step(
        to_export=knife_hinge,
        file_path="cad/production/knife_hinge.step"
    )
    bd.export_step(
        to_export=hinge_multi,
        file_path="cad/production/knife_hinge_multi.step"
    )
    exporter = bd.ExportDXF()
    exporter.add_shape(
        knife_hinge.plate().faces()
        .sort_by(bd.Axis.Z)[0]
    )
    exporter.write("cad/production/hinge_plate.dxf")
    exporter = bd.ExportDXF()
    exporter.add_shape(
        knife_hinge.knuckle_plate().faces()
        .sort_by(bd.Axis.Z)[0]
    )
    exporter.write("cad/production/hinge_knuckle_plate.dxf")