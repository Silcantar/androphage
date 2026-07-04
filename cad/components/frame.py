import typing

import build123d as bd

from common import *
import layout
from parameters import Parameters
from components.fasteners import screw_boss_vertical

class Frame(Component):
    """"""

    def __init__(
        self,
        parameters: Parameters,
        usb_cutout: bool = False,
        label: str = "Frame",
        **kwargs
    ):
        self.parameters = parameters
        self.usb_cutout = usb_cutout
        outline = layout.build_plate_outline(
            self.parameters,
            edge=self.parameters.Plates.Top.edge,
            center_width=(
                self.parameters.height
                * tand(self.parameters.tent_angle)
            ),
            fillet_radius=self.parameters.Plates.Top.radius_outer
        )
        front_center_location = bd.Pos(
            -outline.edges()
            .sort_by(bd.Axis.X)[-1]
            .vertices()
            .sort_by(bd.Axis.Y)[0]
            .center()
            )
        self.outline = front_center_location * outline
        try:
            color
        except NameError:
            color = seq_to_color(self.parameters.Frame.color)
        super().__init__(label=label, color=color, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters
        frame = bd.sweep(
            sections=(
                self._sweep_start_plane()
                * layout.frame_section(self.parameters)
            ),
            path=self._sweep_path(),
            transition=bd.Transition.ROUND
        )
        frame -= self._notch_cutter()
        fillet_edge = (
            frame.faces()
            .filter_by(lambda f: approx_equal(f.center().Z, -p.Frame.notch_depth))
            .edges()
            .sort_by(bd.SortBy.LENGTH)[-2]
        )
        frame = bd.fillet(
            objects=fillet_edge,
            radius=p.Frame.fillet_radius
        )
        screw_locations = (
            bd.Pos(Z=-p.height + p.Plates.Bottom.thickness)
            * layout.frame_screw_locations(
                outline=self.outline,
                offset=(0, p.Screws.M2.offset)
            )
        )
        frame += screw_locations * screw_boss_vertical(
            hole_depth=p.Insert.hole_depth,
            hole_diameter=p.Insert.hole_diameter,
            overhang_angle=p.Print.overhang_angle,
            wall_thickness=p.Insert.wall_thickness
        )
        frame -= screw_locations * bd.Cylinder(
            radius=p.Insert.hole_diameter/2,
            height=p.Insert.hole_depth,
            align=Align.Bottom
        )
        # Cut excess from ends.
        end_cutter_location = bd.Location(
            frame.vertices()
            .group_by(bd.Axis.Z)[-1].vertices()
            .group_by(bd.Axis.X)[-1].vertices()
            .sort_by(bd.Axis.Y)[1]
        )
        frame -= end_cutter_location * bd.Box(
            length=BIG,
            width=BIG,
            height=BIG,
            align=Align.Left,
            rotation=(0, p.tent_angle, 0)
        )
        if self.usb_cutout:
            from bd_keyboard.src.connector.usb_c import USB_C_Port
            usb_face = bd.Face(bd.Wire(
                self.outline.edges().sort_by(bd.Axis.X)[:-3]
            ).close())
            usb_c_port = bd.extrude(
                to_extrude=bd.RectangleRounded(
                    width=p.USBPort.cut_size[X],
                    height=p.USBPort.cut_size[Z],
                    radius=p.USBPort.cut_radius
                    ),
                    amount=p.USBPort.cut_size[Y],
                    both=True
                )
            frame -= (
                layout.usb_c_port_location(
                    self.parameters,
                    outline=usb_face,
                    mirror=False
                )
                * bd.Pos(
                    0,
                    p.Plates.PCB.edge - p.Plates.Top.edge,
                    p.Plates.PCB.position_z + p.Plates.PCB.thickness + p.USBPort.size[Z]/2
                )
                * bd.Rot(X=90)
                # * USB_C_Port(mode=bd.Mode.SUBTRACT)
                * usb_c_port
            )
        return frame

    def _notch_cutter(self) -> bd.Part:
        p = self.parameters
        arc_radius = p.Frame.notch_depth - p.Plates.Top.thickness
        straight_length = p.spacing.X/2 #- arc_radius
        wire = bd.Wire([
            self.outline.edges()[6].trim_to_length(
                start=0,
                length=straight_length
            ),
            self.outline.edges()[7],
            self.outline.edges()[8].trim_to_length(
                start=1,
                length=-straight_length
            )
        ])
        sketch = bd.trace(wire, line_width=4*p.Frame.thickness)
        notch_cutter = bd.extrude(
            to_extrude=sketch,
            amount=-p.Frame.notch_depth
        )
        notch_cutter = bd.fillet(
            objects=(
                notch_cutter.edges()
                .filter_by(bd.GeomType.LINE)
                .group_by(bd.SortBy.LENGTH)[-1]
                .group_by(bd.Axis.Z)[0]
            ),
            radius=p.Frame.notch_depth - p.Plates.Top.thickness
        )
        return notch_cutter

    def _sweep_start_plane(self) -> bd.Location:
        return bd.Location(
            position=self._sweep_path().start_point(),
            orientation=(90, 90, 0)
        )

    def _sweep_path(self) -> bd.Wire:
        return bd.Wire(self.outline.edges().sort_by(bd.Axis.X)[:-1])


if __name__ == "__main__":
    from ocp_vscode import show
    import layout, parameters
    p = layout.set_derived_parameters(
        parameters.load_parameters("cad/androphage.yaml")
    )
    frame = Frame(p, usb_cutout=True)
    show(frame)