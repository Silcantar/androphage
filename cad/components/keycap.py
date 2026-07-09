import os.path
from enum import IntEnum

import build123d as bd

from common import *
from parameters import Parameters

class KeycapRow(IntEnum):
    THUMB = auto()
    R1 = auto()
    R2 = auto()
    R3 = auto()
    R4 = auto()
    R5 = auto()

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
        model_row = min(self.row, 6 - self.row)
        mesh = bd.import_stl(
            os.path.join(path, f"Choc_Chicago_Steno_r{model_row}.stl")
            )
        return bd.Compound([mesh])

    def _joints(self):
        p = self.parameters
        bd.RigidJoint(
            label="stem",
            to_part=self,
            joint_location=bd.Location(
                position=(-comp for comp in p.Keycap.offset),
                orientation=(0, 0, 0 if self.row > 3 else 180)
                )
            )

if __name__ == "__main__":
    from ocp_vscode import show
    import layout, parameters
    p = layout.set_derived_parameters(
        parameters.load_parameters("cad/androphage.yaml")
    )
    keycaps = [
        bd.Pos(Y=30*i) * KeycapSTL(row=row, parameters=p)
        for (i, row) in enumerate(KeycapRow)
        ]
    show(keycaps, render_joints=True)