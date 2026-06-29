import os.path

import build123d as bd

from common import *
from parameters import Parameters

class KeycapRow(StrEnum):
    R1 = auto()
    R2 = auto()
    R3 = auto()
    # THUMB = auto()

class KeycapSTL(Component):
    """Wrapper for Chicago Steno keycap STL files."""

    def __init__(
        self,
        row: KeycapRow,
        parameters: Parameters,
        **kwargs
        ):
        self.row = row
        self.parameters = parameters
        try:
            color
        except NameError:
            color = seq_to_color(self.parameters.CenterBlock.color)
        super().__init__(color=color, **kwargs)

    def _build(self) -> bd.Compound:
        path = os.path.join(os.path.dirname(__file__), "keycaps")
        mesh = bd.import_stl(
            os.path.join(path, f"Choc_Chicago_Steno_{self.row}.stl")
            )
        return bd.Compound([mesh])

    def _joints(self):
        bd.RigidJoint(
            label="stem",
            to_part=self,
            joint_location=bd.Pos(0, 0, -2)
            )

if __name__ == "__main__":
    from ocp_vscode import show
    import layout, parameters
    p = layout.set_derived_parameters(
        parameters.load_parameters("cad/androphage.yaml")
    )
    keycaps = [
        bd.Pos(Y=30*i) * KeycapSTL(row=row, parameters=p)
        for (row, i) in zip(KeycapRow, range(len(KeycapRow)))
        ]
    show(keycaps, render_joints=True)