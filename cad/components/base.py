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
            self.color = color
        except NameError:
            self.color = seq_to_color(self.parameters.Base.color)
        super().__init__(label=label, color=None, **kwargs)

    def _build(self) -> bd.Part:
        p = self.parameters
        # Build main body.
        # Outer wall
        section = (
            bd.Rot(90, 90, 180)
            * layout.frame_section(
                self.parameters,
                do_lips=False,
                fillet=False
            )
        )
        path = self._sweep_paths()
        base = bd.sweep(
            sections=section,
            path=bd.Wire(path)
            )
        # Top wall
        top_sketch = bd.make_hull(base.faces().sort_by(bd.Axis.Z)[-1].edges())
        base += bd.extrude(
            to_extrude=top_sketch,
            amount=-p.Base.wall_thickness,
            taper=20
        )
        base = bd.Pos(Z=-p.Hinge.height) * bd.Rot(Y=-p.tent_angle) * base
        # Inner wall
        base += bd.Box(
            length=p.Base.wall_thickness,
            width=p.Base.depth,
            height=BIG,
            align=Align.RightFrontTop
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
        # Trim off everything extending outside the proper bounding volume.
        trim_sketch = bd.Polygon(
            (0, 0, 0),
            (0, 0, -p.Hinge.height),
            (-p.Base.width, 0, -p.Base.height),
            (-p.Base.width - 10, 0, -p.Base.height),
            BIG*bd.Vector(
                -cosd(p.tent_angle),
                0,
                -sind(p.tent_angle)
            ),
        )
        base &= bd.extrude(
            to_extrude=trim_sketch,
            amount=BIG,
            both=True
        )
        # Fillet outside edges.
        base = bd.fillet(
            objects=(
                base.faces()
                .sort_by(bd.Axis.Z)[0]
                .edges()
                .sort_by(bd.SortBy.LENGTH)[-1]
            ),
            radius=p.Frame.fillet_radius
        )
        fillet_edges = (
            base.faces()
            .sort_by(bd.Axis.X)[0]
            .edges()
            .filter_by(bd.Axis.Y)
        )
        base = bd.fillet(
            objects=fillet_edges,
            radius=p.Frame.fillet_radius - 0.01
        )
        # Subtract cutout for decorative eye.
        eye_location = bd.Location(
            position=(
                bd.Vector(
                    -p.Base.width,
                    p.Trackball.position_y,
                    -p.Base.height
                )
                + bd.Vector(p.Eye.position)
            ),
            orientation=(0, -90 - p.tent_angle, 0)
        )
        base -= eye_location * bd.Cylinder(
            radius=p.Eye.size[0]/2,
            height=BIG,
            align=Align.Bottom
        )
        base.label = "Base"
        base.color = self.color
        # Add eye.
        (iris, pupil) = (eye_location * part for part in self._eye())
        return bd.Part(children=[base, iris, pupil])

    def _eye(self) -> tuple[bd.Part]:
        p = self.parameters
        iris_size = bd.Vector(p.Eye.size)
        iris_arc = bd.Plane.YZ * bd.SagittaArc(
            start_point=(-iris_size.X/2, 0, 0),
            end_point=(iris_size.X/2, 0, 0),
            sagitta=iris_size.Y
        )
        iris_sketch = bd.make_face(bd.Wire(iris_arc).close())
        iris_sketch = bd.split(
            objects=iris_sketch,
            bisect_by=bd.Plane.XZ,
            keep=bd.Keep.TOP
        )
        iris = bd.revolve(
            profiles=iris_sketch,
            axis=bd.Axis.Z,
            revolution_arc=180
        )
        iris.label = "Iris"
        iris.color = seq_to_color(p.Eye.color)
        pupil_size = bd.Vector(p.Eye.pupil_size)
        pupil_arc = bd.SagittaArc(
            start_point=(0, -pupil_size.X/2, 0),
            end_point=(0, pupil_size.X/2, 0),
            sagitta=-pupil_size.Y/2
        )
        pupil_sketch = bd.make_face(bd.Wire(pupil_arc).close())
        pupil = bd.extrude(
            to_extrude=pupil_sketch,
            target=iris,
            until=bd.Until.LAST
        )
        pupil.label = "Pupil"
        pupil.color = "Black"
        iris -= pupil
        # The draft operation failed so accomplish the same thing with a cut.
        draft_cutter = bd.Box(
            length=BIG,
            width=BIG,
            height=BIG,
            rotation=(0, p.tent_angle, 0),
            align=Align.Right
        )
        iris -= draft_cutter
        pupil -= draft_cutter
        return (iris, pupil)

    def _pupil(self) -> bd.Part:
        p = self.parameters
        return pupil

    def _sweep_paths(self) -> bd.Wire:
        p = self.parameters
        hinge_boss_thickness = (
            p.Hinge.thickness
            + p.Insert.hole_depth
            )/cosd(p.tent_angle)
        return (
            bd.Rot(Y=180)
            * bd.Wire([
                bd.Line(
                    (0, 0, 0),
                    (hinge_boss_thickness, 0, 0)
                    ),
                bd.Spline(
                    (hinge_boss_thickness, 0, 0),
                    (p.Base.width, p.Base.width - hinge_boss_thickness, 0),
                    p.Base.waist_point,
                    (p.Base.width, p.Trackball.position_y, 0),
                    tangents=(
                        (1, 0, 0),
                        (0, 1, 0),
                        (0, 1, 0),
                        (0, 1, 0)
                    )
                    ),
                bd.Line(
                    (p.Base.width, p.Trackball.position_y, 0),
                    (
                        p.Base.width,
                        p.Base.depth - p.Base.width + hinge_boss_thickness,
                        0
                        )
                    ),
                bd.Spline(
                    (
                        p.Base.width,
                        p.Base.depth - p.Base.width + hinge_boss_thickness,
                        0
                        ),
                    (hinge_boss_thickness, p.Base.depth, 0),
                    tangents=(
                        (0, 1, 0),
                        (-1, 0, 0)
                        )
                    ),
                bd.Line(
                    (hinge_boss_thickness, p.Base.depth, 0),
                    (0, p.Base.depth, 0),
                    )
                ])
            )


if __name__ == "__main__":
    from ocp_vscode import show
    import layout, parameters
    p = layout.set_derived_parameters(
        parameters.load_parameters("cad/androphage.yaml")
    )
    show(Base(p, mirror=True))