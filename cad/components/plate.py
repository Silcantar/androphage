import typing
from enum import StrEnum, auto

import build123d as bd

from common import *
from parameters import Columns

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
        columns: Columns,
        column_locations: KeyLocationDict,
        outline: bd.Face,
        center_width: float = 0,
        color: bd.ColorLike = "CornflowerBlue",
        cutout: bd.VectorLike = (14, 14),
        label: str = None,
        edge: float = 5,
        plate_type: PlateType = PlateType.SWITCH,
        radius_outer: float = 2,
        radius_inner: float = 0.5,
        spacing: bd.VectorLike = (18, 17),
        thickness: float = 1.2,
        trackball_cutout_radius: float = 17.5,
        trackball_position_y: float = 70,
        **kwargs
    ):
        self.columns = columns
        self.column_locations = column_locations
        self.outline = outline
        self.center_width = center_width
        self.cutout = cutout
        self.edge = edge
        self.plate_type = plate_type
        self.radius_inner = radius_inner
        self.radius_outer = radius_outer
        self.spacing = bd.Vector(spacing)
        self.thickness = thickness
        self.trackball_cutout_radius = trackball_cutout_radius
        self.trackball_position_y = trackball_position_y
        if label is None:
            self.label = f"{plate_type.title()} Plate"
        super().__init__(self.label, **kwargs)

    def build(self) -> bd.Part:
        with bd.BuildPart() as plate:
            with bd.BuildSketch() as sketch:
                # Create the outline.
                bd.add(self.outline)
                # Fillet all but the right-most group of vertices.
                bd.fillet(
                    sketch.vertices().group_by(bd.Axis.X)[:-1],
                    radius=self.radius_outer
                )
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
                    first_thumb_key = (
                        Finger.INDEX if self.columns[Finger.INDEX].cutout
                        else Finger.TUCK
                    )
                    top_plate_transition_vertices = (
                        sketch.vertices().sort_by_distance((
                            self.column_locations[first_thumb_key]
                            * bd.Pos(
                            -self.spacing.X/2,
                            -self.spacing.Y/2 - self.edge
                            )
                        ).position)[0],
                        sketch.vertices().sort_by_distance((
                            self.column_locations[Finger.REACH]
                            * bd.Pos(
                            self.spacing.X/2,
                            -self.spacing.Y/2 - self.edge
                            )
                        ).position)[0],
                    )
                    bd.fillet(
                        top_plate_transition_vertices,
                        radius=self.radius_inner
                    )
            bd.extrude(amount=self.thickness)
            # Extend the center of the plate by center_width.
            if self.center_width > 0:
                bd.extrude(
                    plate.faces().group_by(bd.Axis.X)[-1],
                    amount=self.center_width
                )
            # Subtract the trackball cutout.
            if self.plate_type == PlateType.TOP:
                bd.add(self.trackball_cutout(), mode=bd.Mode.SUBTRACT)
        return plate.part

    def switch_plate_cutout(self) -> bd.Sketch:
        """Create a sketch for the cutouts in the switch plate."""
        with bd.BuildSketch() as sketch:
            with bd.Locations([
                # This list comprehension generates all of the key locations
                # from the column locations.
                (
                    self.column_locations[column_key]
                    * bd.Pos(
                        self.columns[column_key].shift[0] * self.spacing.X,
                        (i + self.columns[column_key].shift[1]) * self.spacing.Y
                    )
                )
                for column_key in self.column_locations
                for i in range(self.columns[column_key].keys)
            ]):
                bd.RectangleRounded(
                    *self.cutout,
                    radius=self.radius_inner,
                )
        return sketch.sketch

    def top_plate_cutout(self) -> bd.Sketch:
        """Generate a sketch for the cutouts in the top plate."""
        spc = self.spacing
        with bd.BuildSketch() as sketch:
            for column_key in self.column_locations:
                column = self.columns[column_key]
                column_location = self.column_locations[column_key]
                cutout = 2*self.edge if column.cutout else 0
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
                        bd.Circle(
                            radius=column.connect*spc.Y,
                            arc_size=column.splay,
                            align=(bd.Align.MIN, bd.Align.MIN)
                        )
            bd.fillet(sketch.vertices(), radius=self.radius_inner)
        return sketch.sketch

    def trackball_cutout(self) -> bd.Part:
        """Generate and position a 3d cutout for the trackball."""
        with bd.BuildPart() as part:
            trackball_location = (
                self.outline
                .vertices()
                .sort_by(bd.Axis.X)[-1]
            ).moved(
                bd.Pos(
                    self.center_width,
                    self.trackball_position_y
                )
            )
            with bd.Locations(trackball_location):
                bd.Cylinder(
                    radius=self.trackball_cutout_radius,
                    height=self.thickness,
                    align=Align.Bottom
                )
        return part.part


if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    show(
        Plate(
            androphage.parameters.Columns,
            androphage.build_column_locations(),
            androphage.build_plate_outline(edge=5),
            center_width=5,
            plate_type=PlateType.SWITCH,
        ),
        Plate(
            androphage.parameters.Columns,
            androphage.build_column_locations(),
            androphage.build_plate_outline(edge=7),
            center_width=10,
            edge=7,
            plate_type=PlateType.TOP,
            radius_inner=1
        ).move(bd.Pos(0, 0, 20))
    )