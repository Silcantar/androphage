import typing
from os import PathLike

import build123d as bd

from common import *
from parameters import *
from components.battery import Battery
from components.plate import Plate, PlateType

# Passed to __main__
test_layout = True

class Androphage(bd.BasePartObject):
    """Build a model of an Androphage keyboard based on a parameter file."""

    def __init__(
        self,
        build: bool = True,
        parameter_path: PathLike = "cad/androphage.yaml",
        test_layout: bool = False,
        main_half: Half = Half.LEFT,
        **kwargs
    ):
        self.main_half = main_half
        self.parameters = self.import_parameters(parameter_path)
        self.spacing = self.get_spacing()
        self.key_locations = self.build_key_locations()
        self.plate_outline = self.build_plate_outline()
        if build:
            part = self.build(test_layout)
            super().__init__(part=part, **kwargs)

    def import_parameters(self, parameter_path: PathLike) -> Parameters:
        """Load parameters from a YAML file."""
        return Parameters.from_yaml_file(parameter_path)

    def build(self, test_layout) -> bd.Part:
        components: list[bd.Part] = []
        if test_layout:
            components.append(self.test_layout())
        # components.append(Battery(size=self.parameters.Battery.size))
        return bd.Compound(label="Androphage", children=components)

    def get_spacing(self) -> bd.Vector:
        """Get the key spacing distance based on the spacing type specified in
        the parameters.
        """
        match self.parameters.Keycap.spacingType:
            case SpacingType.CHOC:
                return bd.Vector(18, 17)
            case SpacingType.MX:
                return bd.Vector(19, 19)
            case SpacingType.MX_INCH:
                return bd.Vector(19.05, 19.05)
            case SpacingType.CUSTOM:
                return bd.Vector(self.parameters.Keycap.customSpacing)
            case _:
                print("Info: spacing not provided, defaulting to Choc spacing.")
                return bd.Vector(18, 17)

    def build_key_locations(self) -> LocationDict:
        """Calculate the locations of the keys."""
        spc = self.spacing
        locations = LocationDict()
        origin = bd.Location((0, 0))
        for column_key in self.parameters.Columns:
            column = self.parameters.Columns[column_key]
            origin *= bd.Location(
                position=(-0.5*spc.X, -0.5*spc.Y)
            ) * bd.Location(
                position=(column.spread*spc.X, column.stagger*spc.Y),
                orientation=(0, 0, -column.splay)
            ) * bd.Location(
                position=(0.5*spc.X, 0.5*spc.Y)
            )
            for i in range(0, column.keys):
                loc = (
                    origin * bd.Location(position=(
                        spc.X*column.shift[0],
                        spc.Y*(i + column.shift[1])
                    ))
                )
                loc.label = f"{column_key}_{i}"
                if not column.skip:
                    locations[loc.label] = loc
        return locations

    def build_plate_outline(
        self,
        edge: float = 0,
        # center_width: float = 0
    ) -> bd.Face:
        """Define the geometry of the plate outline."""
        spc = self.spacing
        kl = self.key_locations
        outside = spc.X/2 * (-1 if self.main_half == Half.LEFT else 1)
        center = 0 # Horizontal center
        inside = spc.X/2 * (1 if self.main_half == Half.LEFT else -1)
        front = -spc.Y/2
        middle = 0 # Vertical center
        back = spc.Y/2
        last_column = (
            Finger.PINKY
            if self.parameters.Columns[Finger.OUTER].skip
            else Finger.OUTER
        )
        last_key = self.parameters.Columns[last_column].keys - 1
        total_splay = sum([
            self.parameters.Columns[column].splay
            for column in self.parameters.Columns
        ])
        hinge_front_loc = (
            kl["reach_0"]
            * bd.Pos(inside, back)
            * bd.Rot(Z=total_splay)
            * bd.Pos(0, -edge)
        )
        hinge_back_loc = (
            hinge_front_loc
            * bd.Pos(0, self.parameters.Hinge.length + 2*edge)
        )
        middle_back_loc = (
            kl["middle_3"]
            * bd.Pos(inside, back + edge)
        )
        reach_front_loc = (
            kl["reach_0"]
            * bd.Pos(center, front - edge)
        )
        reach_front_inside_loc = (
            kl["reach_0"]
            * bd.Pos(inside + edge, front - edge)
        )
        home_front_loc = (
            kl["home_0"]
            * bd.Pos(center, front - edge)
        )
        index_front_loc = (
            kl["index_0"]
            * bd.Pos(center, front - edge)
        )
        ring_front_loc = (
            kl["ring_0"]
            * bd.Pos(outside, front - edge)
        )
        pinky_front_loc = (
            kl[f"{last_column}_0"]
            * bd.Pos(outside - edge, front - edge)
        )
        pinky_back_loc = (
            kl[f"{last_column}_{last_key}"]
            * bd.Pos(outside - edge, back + edge)
        )
        with bd.BuildSketch() as sketch:
            with bd.BuildLine() as outline:
                back_center_arc = bd.TangentArc(
                    hinge_back_loc.position,
                    middle_back_loc.position,
                    tangent=(
                        bd.Rot(hinge_back_loc.orientation)
                        * bd.Pos(-1,0)
                    ).position
                )
                back_outside_arc = bd.TangentArc(
                    back_center_arc.end_point(),
                    pinky_back_loc.position,
                    tangent=back_center_arc.tangent_at(1)
                )
                outside_line = bd.Line(
                    back_outside_arc.end_point(),
                    pinky_front_loc.position
                )
                reach_line = bd.Line(
                    reach_front_inside_loc.position,
                    reach_front_loc.position
                )
                front_arc = bd.ThreePointArc(
                    reach_line.end_point(),
                    home_front_loc.position,
                    index_front_loc.position
                )
                front_middle_arc = bd.TangentArc(
                    front_arc.end_point(),
                    ring_front_loc.position,
                    tangent=front_arc.tangent_at(1)
                )
                front_outer_arc = bd.TangentArc(
                    front_middle_arc.end_point(),
                    pinky_front_loc.position,
                    tangent=front_middle_arc.tangent_at(1)
                )
                back_center_line = bd.Line(
                    hinge_back_loc.position,
                    hinge_front_loc.position,
                )
                const_center_line = bd.PolarLine(
                    start=back_center_line.end_point(),
                    direction=back_center_line.tangent_at(1),
                    length=100,
                    mode=bd.Mode.PRIVATE
                )
                const_reach_line = bd.IntersectingLine(
                    start=reach_line.start_point(),
                    direction=-reach_line.tangent_at(),
                    other=const_center_line,
                    mode=bd.Mode.PRIVATE
                )
                front_center_arc = bd.CenterArc(
                    center=const_reach_line.end_point(),
                    radius=const_reach_line.length,
                    start_angle=90,
                    arc_size=45
                )
                front_center_line = bd.Line(
                    back_center_line.end_point(),
                    front_center_arc.start_point()
                )
            bd.make_face()
        return sketch.face()

    def test_layout(self) -> bd.Part:
        with bd.BuildPart() as keys:
            with self.key_locations.locations():
                bd.Box(
                    self.spacing.X,
                    self.spacing.Y,
                    1,
                    align=Align.Bottom
                )
        with bd.BuildPart() as plate:
            outline = bd.extrude(
                self.build_plate_outline(
                    edge=4,
                    # center_width=5
                ),
                amount=-1
            )
        keys.part.label = "keys"
        plate.part.label = "plate"
        plate.part.color = "Plum"
        return bd.Compound(
            label="Layout test",
            children=[keys.part, plate.part]
        )


if __name__ == "__main__":
    from ocp_vscode import show
    show(Androphage(test_layout=test_layout))