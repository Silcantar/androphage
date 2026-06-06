import typing

import build123d as bd

from common import *
from parameters import Parameters

class Eye(Component):
    """"""

    def __init__(
        self,
        parameters: Parameters,
        label: str = "Eye",
        **kwargs
    ):
        self.parameters = parameters
        try:
            self.color = color
        except NameError:
            self.color = seq_to_color(self.parameters.Eye.color)
        super().__init__(label=label, color=None, **kwargs)

    def _build(self) -> bd.Part:
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
        iris.color = self.color
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
        return bd.Part(children=[iris, pupil])

if __name__ == "__main__":
    from ocp_vscode import show
    import layout, parameters
    p = layout.set_derived_parameters(
        parameters.load_parameters("cad/androphage.yaml")
    )
    show(Eye(p))