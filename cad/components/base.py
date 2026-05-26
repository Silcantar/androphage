import typing

import build123d as bd

from common import *
import layout
from parameters import Parameters

class Base(Component):
    """"""

    def __init__(
        self,
        parameters: Parameters,
        label: str = "Base",
        **kwargs
    ):
        self.parameters = parameters
        try:
            color
        except NameError:
            color = seq_to_color(self.parameters.Base.color)
        super().__init__(label=label, color=color, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters
        # Build main body.
        foot_position_x = (p.Base.height - p.Hinge.height)/sind(p.tent_angle)
        top_sketch = bd.Plane.YZ * bd.Rectangle(
            width=p.Base.depth,
            height=p.Base.wall_thickness*cosd(p.tent_angle),
            align=Align.LeftBack
        )
        bottom_sketch = (
            bd.Plane.YZ
            * bd.Pos(Y=-p.Hinge.height)
            * bd.Rectangle(
                width=p.Base.depth,
                height=p.Base.wall_thickness*cosd(p.tent_angle),
                align=Align.LeftFront
            )
        )
        top = bd.extrude(
            to_extrude=top_sketch,
            dir=(-cosd(p.tent_angle), 0, -sind(p.tent_angle)),
            amount=BIG
        )
        bottom = bd.extrude(
            to_extrude=bottom_sketch,
            dir=(-cosd(p.tent_angle), 0, -sind(p.tent_angle)),
            amount=BIG
        )
        # Build sweep path.
        sweep_plane = bd.Plane.XY * bd.Rot(Y=-p.tent_angle)
        sweep_paths = [
            sweep_plane * bd.EllipticalCenterArc(
                center=(0, p.Trackball.position_y - p.Base.foot_length/2, 0),
                x_radius=p.Hinge.height,
                y_radius=p.Trackball.position_y - p.Base.foot_length/2,
                start_angle=180,
                arc_size=90
            ),
            sweep_plane * bd.Line(
                (-p.Hinge.height, p.Trackball.position_y - p.Base.foot_length/2),
                (-p.Hinge.height, p.Trackball.position_y + p.Base.foot_length/2)
            ),
            sweep_plane * bd.EllipticalCenterArc(
                center=(0, p.Trackball.position_y + p.Base.foot_length/2, 0),
                x_radius=p.Hinge.height,
                y_radius=(
                    p.Base.depth
                    - p.Trackball.position_y
                    - p.Base.foot_length/2
                ),
                start_angle=180,
                arc_size=-90
            )
        ]
        sweep_section1 = layout.frame_section(
            self.parameters,
            do_lips=False,
            height=p.Hinge.height
        )
        sweep_section2 = layout.frame_section(
            self.parameters,
            do_lips=False,
            height=p.Base.height - p.Hinge.height*sind(p.tent_angle),
            shear_x=(
                foot_position_x
                - p.height
            )/(
                p.Base.height
                - p.Hinge.height*sind(p.tent_angle)
            )
        )
        sweep_sections = [
            (
                bd.Pos(Z=-p.Hinge.height)
                * bd.Rot(-90, 90, 0)
                * sweep_section1
            ),
            (
                bd.Pos(sweep_paths[1] @ 0)
                * bd.Pos(
                    p.height - foot_position_x,
                    0,
                    p.Hinge.height*sind(p.tent_angle) - p.Base.height
                )
                * bd.Rot(-90, 180, 0)
                * sweep_section2
            ),
            (
                bd.Pos(sweep_paths[1] @ 1)
                * bd.Pos(
                    p.height - foot_position_x,
                    0,
                    p.Hinge.height*sind(p.tent_angle) - p.Base.height
                )
                * bd.Rot(-90, 180, 0)
                * sweep_section2
            ),
            (
                bd.Pos(0, p.Base.depth, -p.Hinge.height)
                * bd.Rot(-90, -90, 0)
                * sweep_section1
            )
        ]
        sweep = bd.sweep(
            sections=sweep_sections,
            path=sweep_paths,
            multisection=True
        )
        splitter = bd.Shell(
            sweep.faces()
            .filter_by(lambda f: f.normal_at().X > 0)
            .sort_by(bd.SortBy.AREA)[-3:]
        )
        bottom = bd.split(
            objects=bottom,
            bisect_by=splitter,
            keep=bd.Keep.TOP
        )
        top = bd.split(
            objects=top,
            bisect_by=splitter,
            keep=bd.Keep.TOP
        )
        # Add bosses to hold the hinges.
        hinge_locations = [
            bd.Pos(Y=(
                i*p.Plates.depth
                + (1 - 2*i)*(2*p.Frame.lip_depth + p.Hinge.width/2)
                + p.Hinge.offsets[i]
            ))
            for i in range(len(p.Hinge.offsets))
        ]
        base += hinge_locations * bd.Box(
            length=p.Hinge.thickness + p.Insert.hole_depth,
            width=p.Hinge.width + 2*p.Base.wall_thickness,
            height=BIG,
            align=Align.Right
        )
        # Add trackball case.
        trackball_location = bd.Pos(0, p.Trackball.position_y, -p.Hinge.height)
        base += trackball_location * bd.Sphere(
            radius=(
                p.Trackball.diameter/2
                + p.Trackball.clearance
                + p.Base.wall_thickness
            )
        )
        # Subtract hinge cutouts.
        base -= hinge_locations * bd.Box(
            length=p.Hinge.thickness,
            width=p.Hinge.width,
            height=BIG,
            align=Align.Right
        )
        # Subtract holes for hinge screw threaded inserts.
        hinge_screw_locations = [
            hinge_location
            * bd.Pos(
                -p.Hinge.thickness,
                0,
                -p.Hinge.height/2 + i*p.Hinge.screw_position
            )
            for i in [-1, 1]
            for hinge_location in hinge_locations
        ]
        base -= hinge_screw_locations * bd.Cylinder(
            radius=p.Insert.hole_diameter/2,
            height=p.Insert.hole_depth,
            align=Align.Top,
            rotation=(0, 90, 0)
        )
        # Subtract trackball cutout.
        base -= trackball_location * bd.Sphere(
            radius=p.Trackball.diameter/2 + p.Trackball.clearance
        )
        opening_sketch = (
            bd.Pos(
                foot_position_x/2,
                (p.Trackball.position_y - p.Trackball.diameter/2)/2,
                -p.Base.height
            )
            * bd.RectangleRounded(
                width=15,
                height=45,
                radius=7.5-EPS
            )
        )
        base -= bd.extrude(
            to_extrude=opening_sketch,
            amount=p.Base.height - p.Hinge.height + p.Base.wall_thickness
        )
        # Trim off everything extending outside the proper bounding volume.
        # base &=
        return base


if __name__ == "__main__":
    from ocp_vscode import show
    import layout, parameters
    p = layout.set_derived_parameters(
        parameters.load_parameters("cad/androphage.yaml")
    )
    show(Base(p))