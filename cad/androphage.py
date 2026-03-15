import typing
from os import PathLike

import build123d as bd

from common import *
from parameters import *

# Passed to __main__ 
test_layout = True

class Androphage(bd.BasePartObject):
    """Build a model of an Androphage keyboard based on a parameter file."""
    def __init__(
        self,
        parameter_path: PathLike = 'cad/androphage.yaml',
        test_layout: bool = False,
        **kwargs
    ):
        self.parameters = self.import_parameters(parameter_path)
        self.spacing = self.get_spacing()
        self.key_locations = self.get_key_locations()
        self.plate_outline = self.get_plate_outline()
        part = self.build(test_layout)
        super().__init__(part=part, **kwargs)

    def import_parameters(self, parameter_path: PathLike) -> Parameters:
        """Load parameters from a YAML file."""
        return Parameters.from_yaml_file(parameter_path)

    def build(self, test_layout) -> bd.Part:
        compound = bd.Compound(
            self.test_layout() if test_layout else None
        )
        return compound

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
                print('Info: spacing not provided, defaulting to Choc spacing.')
                return bd.Vector(18, 17)

    def get_key_locations(self) -> LocationDict:
        """Calculate the locations of the keys."""
        spc = self.spacing
        locations = LocationDict()
        origin = bd.Location((0, 0))
        for column_key in self.parameters.Columns:
            column = self.parameters.Columns[column_key]
            origin *= bd.Location(
                position=[column.spread*spc.X, column.stagger*spc.Y],
                orientation=[0, 0, -column.splay]
            )
            for i in range(0, column.keys):
                loc = (
                    origin * bd.Location(position=[
                        spc.X*column.shift[0],
                        spc.Y*(i + column.shift[1])
                    ])
                )
                loc.label = f'{column_key}_{i}'
                if not column.skip:
                    locations[loc.label] = loc
        return locations

    def get_plate_outline(self) -> bd.Face:
        """Define the geometry of the plate outline."""
        spc = self.spacing
        kl = self.key_locations
        bottom = 0
        top = spc.Y
        left = 0
        right = spc.X
        center = spc.X/2
        middle = spc.Y/2
        last_column = (
            Finger.PINKY
            if self.parameters.Columns[Finger.OUTER].skip
            else Finger.OUTER
        )
        last_key = self.parameters.Columns[last_column].keys - 1
        hinge_back_loc = (
            kl['reach_0']
            * bd.Pos(left, top)
            * bd.Rot(Z=-45)
            * bd.Pos(0, self.parameters.Hinge.length)
        )
        middle_back_loc = (
            kl['middle_3']
            * bd.Pos(left, top)
        )
        reach_front_loc = (
            kl['reach_0']
            * bd.Pos(center, bottom)
        )
        reach_front_left_loc = (
            kl['reach_0']
            * bd.Pos(left, bottom)
        )
        home_front_loc = (
            kl['home_0']
            * bd.Pos(center, bottom)
        )
        index_front_loc = (
            kl['index_0']
            * bd.Pos(center, bottom)
        )
        ring_front_loc = (
            kl['ring_0']
            * bd.Pos(right, bottom)
        )
        pinky_front_loc = (
            kl[f'{last_column}_0']
            * bd.Pos(right, bottom)
        )
        pinky_back_loc = (
            kl[f'{last_column}_{last_key}']
            * bd.Pos(right, top)
        )
        with bd.BuildSketch() as sketch:
            with bd.BuildLine() as outline:
                reach_line = bd.Line(
                    reach_front_left_loc.position,
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
                outside_line = bd.Line(
                    front_outer_arc.end_point(),
                    pinky_back_loc.position
                )
                back_center_arc = bd.TangentArc(
                    hinge_back_loc.position,
                    middle_back_loc.position,
                    tangent=(
                        bd.Rot(hinge_back_loc.orientation)
                        * bd.Pos(1,0)
                    ).position
                )
                back_outside_arc = bd.TangentArc(
                    back_center_arc.end_point(),
                    outside_line.end_point(),
                    tangent=back_center_arc.tangent_at(1)
                )
                center_line = bd.Line(
                    hinge_back_loc.position,
                    (kl['reach_0'] * bd.Pos(left, top)).position,
                )
                center_line2 = bd.PolarLine(
                    start=center_line.end_point(),
                    direction=center_line.tangent_at(),
                    length=100
                )
                const_line = bd.IntersectingLine(
                    start=reach_line.start_point(),
                    direction=-reach_line.tangent_at(),
                    other=center_line2,
                    mode=bd.Mode.PRIVATE
                )
                front_center_arc = bd.CenterArc(
                    center=const_line.end_point(),
                    radius=const_line.length,
                    start_angle=0,
                    arc_size=45
                )
            bd.make_face()
        return sketch.face()

    def test_layout(self) -> bd.Part:
        with bd.BuildPart() as buildpart:
            outline = bd.extrude(self.plate_outline, amount=-1)
            with self.key_locations.locations():
                bd.Box(
                    self.spacing.X,
                    self.spacing.Y,
                    1,
                    align=Align.LeftFrontBottom,
                    # mode=bd.Mode.SUBTRACT
                )
        return buildpart.part


if __name__ == '__main__':
    from ocp_vscode import show
    show(Androphage(test_layout=test_layout))