import typing
from enum import StrEnum, auto

import build123d as bd

from common import *
import layout
from parameters import Columns, Parameters

class PlateType(StrEnum):
    BOTTOM = auto()
    PCB = auto()
    SWITCH = auto()
    TOP = auto()

class Plate(Component):
    """Class used to generate all plate and plate-like components: top and
    bottom plates, switch plate, and PCB.
    """
    def __init__(
        self,
        parameters: Parameters,
        plate_type: PlateType = PlateType.SWITCH,
        label: str = None,
        **kwargs
    ):
        self.parameters = parameters
        self.plate_type = plate_type
        p = self.parameters
        match self.plate_type:
            case PlateType.BOTTOM:
                self.plate_params = p.Plates.Bottom
            case PlateType.PCB:
                self.plate_params = p.Plates.PCB
            case PlateType.SWITCH:
                self.plate_params = p.Plates.Switch
            case PlateType.TOP:
                self.plate_params = p.Plates.Top
        self.column_locations = layout.build_column_locations(p)
        self.outline = layout.build_plate_outline(
            p,
            edge=self.plate_params.edge,
            center_width=self.plate_params.center_width,
            fillet_radius=self.plate_params.radius_outer
        )
        if label is None:
            self.label = f"{plate_type.title()} Plate"
        else:
            self.label = label
        try:
            color
        except NameError:
            color = seq_to_color(self.plate_params.color)
        super().__init__(self.label, color=color, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters
        with bd.BuildPart() as plate:
            with bd.BuildSketch() as sketch:
                # Create the outline.
                bd.add(self.outline)
                # Create the switch-mounting cutouts in the switch plate.
                if self.plate_type == PlateType.SWITCH:
                    bd.add(
                        self.switch_plate_cutout(),
                        mode=bd.Mode.SUBTRACT
                    )
                # Create the cutout in the top plate.
                if self.plate_type == PlateType.TOP:
                    bd.add(
                        self.top_plate_cutout(),
                        mode=bd.Mode.SUBTRACT
                    )
                    # Fillet the two vertices created by the previous step.
                    if (
                        self.plate_params.radius_outer > 0
                        and p.Plates.Top.thumb_cutout_fillet
                    ):
                        first_thumb_key = (
                            Finger.INDEX if self.columns[Finger.INDEX].cutout
                            else Finger.TUCK
                        )
                        top_plate_transition_vertices = (
                            sketch.vertices().sort_by_distance((
                                self.column_locations[first_thumb_key]
                                * bd.Pos(
                                -p.spacing.X/2,
                                -p.spacing.Y/2 - self.plate_params.edge
                                )
                            ).position)[0],
                            sketch.vertices().sort_by_distance((
                                self.column_locations[Finger.REACH]
                                * bd.Pos(
                                p.spacing.X/2,
                                -p.spacing.Y/2 - self.plate_params.edge
                                )
                            ).position)[0],
                        )
                        bd.fillet(
                            top_plate_transition_vertices,
                            radius=self.plate_params.radius_outer
                        )
            bd.extrude(amount=self.plate_params.thickness)
            # Subtract the trackball cutout.
            if self.plate_type == PlateType.TOP:
                bd.add(
                    self.trackball_cutout(),
                    mode=bd.Mode.SUBTRACT
                )
        plate.part.orientation -= (0, p.tent_angle, 0)
        # Align the front center corner to the origin.
        plate.part.position -= (
            plate.part.vertices()
            .group_by(bd.Axis.X)[-1].vertices()
            .group_by(bd.Axis.Y)[0].vertices()
            .sort_by(bd.Axis.Z)[0].center()
        )
        return plate.part

    def switch_plate_cutout(self) -> bd.Sketch:
        """Create a sketch for the cutouts in the switch plate."""
        p = self.parameters
        with bd.BuildSketch() as sketch:
            with bd.Locations(list(layout.build_key_locations(p).values())):
                bd.RectangleRounded(
                    *p.Switch.model.cutout,
                    radius=p.Switch.model.radius
                )
        return sketch.sketch

    def top_plate_cutout(self) -> bd.Sketch:
        """Generate a sketch for the cutouts in the top plate."""
        p = self.parameters
        spc = p.spacing
        with bd.BuildSketch() as sketch:
            for column_key in self.column_locations:
                column = p.Columns[column_key]
                column_location = self.column_locations[column_key]
                cutout = 2*self.plate_params.edge if column.cutout else 0
                with bd.Locations(
                    column_location
                    * bd.Pos(
                        0,
                        ((column.keys - 1)*spc.Y - cutout)/2,
                        0
                    ) * bd.Pos(
                        column.shift[0]*spc.X,
                        column.shift[1]*spc.Y
                    )
                ):
                    bd.Rectangle(
                        spc.X,
                        column.keys*spc.Y + cutout
                    )
                if column.connect > 0:
                    with bd.Locations(
                        column_location
                        * bd.Pos(-spc/2)
                        * bd.Rot(Z=90)
                    ):
                        Circle(
                            radius=column.connect*spc.Y,
                            arc_size=column.splay,
                            align=(bd.Align.MIN, bd.Align.MIN)
                        )
            bd.fillet(sketch.vertices(), radius=self.plate_params.radius_inner)
        return sketch.sketch

    def trackball_cutout(self) -> bd.Part:
        """Generate and position a 3d cutout for the trackball."""
        p = self.parameters
        with bd.BuildPart() as part:
            trackball_location = (
                self.outline
                .vertices()
                .group_by(bd.Axis.X)[-1]
                .sort_by(bd.Axis.Y)[0]
            ).moved(
                bd.Pos(
                    0,
                    p.Trackball.position_y
                )
            )
            with bd.Locations(trackball_location):
                bd.Cylinder(
                    radius=p.Trackball.diameter/2 + p.Trackball.clearance,
                    height=self.plate_params.thickness,
                    align=Align.Bottom
                )
        return part.part


if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    zpos = {
        PlateType.BOTTOM: 0,
        PlateType.PCB: 20,
        PlateType.SWITCH: 40,
        PlateType.TOP: 60
    }
    edge = {
        PlateType.BOTTOM: 6,
        PlateType.PCB: 5,
        PlateType.SWITCH: 5,
        PlateType.TOP: 6
    }
    show([
        Plate(
            androphage.parameters,
            plate_type=plate_type,
        ).move(bd.Pos(0, 0, zpos[plate_type]))
        for plate_type in PlateType
    ])