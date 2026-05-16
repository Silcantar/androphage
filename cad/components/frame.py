import typing

import build123d as bd

from common import *
import layout
from parameters import Parameters
from components.fasteners import screw_boss_vertical
import bd_keyboard.src.connectors.usb_c as usb_c #import USB_C_Port

class Frame(Component):
    """"""

    def __init__(
        self,
        parameters: Parameters,
        label: str = "Frame",
        **kwargs
    ):
        self.parameters = parameters
        self.outline = layout.build_plate_outline(
            self.parameters,
            edge=self.parameters.Plates.Top.edge,
            center_width=(
                self.parameters.height
                * tand(self.parameters.tent_angle)
            ),
            fillet_radius=self.parameters.Plates.Top.radius_outer
        )
        try:
            color
        except NameError:
            color = seq_to_color(self.parameters.Frame.color)
        super().__init__(label=label, color=color, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters
        frame = bd.sweep(
            sections=layout.frame_section(
                self.parameters,
                self._sweep_start_plane()
            ),
            path=self._sweep_path(),
            transition=bd.Transition.ROUND
        )
        frame -= self._notch_cutter()
        fillet_edge = (
            frame.faces()
            .filter_by(lambda f: f.center().Z == -p.Frame.notch_depth)
            .edges()
            .sort_by(bd.SortBy.LENGTH)[-2]
        )
        # fillet_edge = frame.edges(bd.Select.NEW).sort_by(bd.SortBy.LENGTH)[-2]
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
        usb_c_location = bd.Pos(Z=-p.height + p.Plates.Bottom.thickness) * layout.usb_c_port_location(self.parameters, outline=self.outline)
        frame -= (
            bd.Pos(Z=-p.height + p.Plates.Bottom.thickness)
            * layout.usb_c_port_location(self.parameters, outline=self.outline)
            * usb_c.USB_C_Port(mode=bd.Mode.SUBTRACT)
        )
        return frame

    def _locate(self):
        p = self.parameters
        # Move the part so that the center wall is vertical and the hinge
        # pivot is along the Y axis.
        self.orientation += (0, -p.tent_angle, 0)
        self.position -= (
            self.faces()
            .group_by(bd.Axis.X)[-1].faces()
            .sort_by(bd.Axis.Y)[0].vertices()
            .group_by(bd.Axis.Z)[-1].vertices()
            .sort_by(bd.Axis.Y)[-1].center()
        )

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
    from androphage import Androphage
    androphage = Androphage(build=False)
    frame = Frame(androphage.parameters, locate=False)
    show(frame)