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
        foot_position_x = -(p.Base.height - p.Hinge.height)/tand(p.tent_angle)
        outer_sketch = bd.Plane.XZ * bd.Polygon(
            (0, 0),
            (0, -p.Hinge.height),
            (foot_position_x, -p.Base.height),
            (foot_position_x - p.Base.foot_width, -p.Base.height),
            (
                foot_position_x - p.Base.foot_width,
                -p.Base.height + p.Base.wall_thickness
            ),
            (-p.height, -p.Hinge.height*sind(p.tent_angle))
        )
        outer_sketch = bd.fillet(
            objects=outer_sketch.vertices().sort_by(bd.Axis.Z)[-2],
            radius=10
        )
        sketch = outer_sketch - bd.offset(
            objects=outer_sketch,
            amount=-p.Base.wall_thickness
        )
        base = bd.extrude(
            to_extrude=sketch,
            amount=p.Plates.depth
        )
        # Add bosses to hold the hinges.
        hinge_locations = [
            bd.Pos(Y=(
                i*p.Plates.depth
                + (1 - 2*i)*(2*p.Frame.lip_depth + p.Hinge.width/2)
            ))
            for i in range(2)
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
        end_locations = [
            bd.Location(
                position=(0, i*p.Base.depth, -p.Hinge.height),
                orientation=(
                    180*i,
                    (1 - 2*i)*(90 - p.tent_angle),
                    -90
                )
            )
            for i in range(2)
        ]
        end_sketch = bd.Sketch(
            end_locations
            * layout.frame_section(self.parameters)
        )
        base += bd.extrude(
            to_extrude=end_sketch,
            amount=BIG,
            both=True
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
        base &= bd.extrude(
            to_extrude=outer_sketch,
            amount=BIG,
            both=True
        )
        base = bd.fillet(
            objects=base.edges().group_by(bd.Axis.X)[0].sort_by(bd.Axis.Z)[0],
            radius=p.Frame.fillet_radius
        )
        fillet_edges = [
            base.faces().sort_by(bd.Axis.X)[2].edges().sort_by(bd.Axis.Y)[i]
            for i in [0, -1]
        ]
        # print(base.max_fillet(edge_list=fillet_edges, max_iterations=100))
        base = bd.fillet(
            objects=fillet_edges,
            radius=0.9
        )
        return base


if __name__ == "__main__":
    from ocp_vscode import show
    import layout, parameters
    p = layout.set_derived_parameters(
        parameters.load_parameters("cad/androphage.yaml")
    )
    show(Base(p))