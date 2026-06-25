import build123d as bd

from common import *

class KeycapRow(StrEnum):
    R1 = auto()
    R2 = auto()
    R3 = auto()
    THUMB = auto()

class KeycapSTL(Component):
    """Wrapper for Chicago Steno keycap STL files."""

    def __init__(self, row: KeycapRow, **kwargs):
        self.row = row
        super().__init__(**kwargs)

    def _build(self) -> bd.Compound:
        mesh = bd.import_stl(f"./cad/keycaps/stl/choc/{self.row}.stl")
        return bd.Compound([mesh])

if __name__ == "__main__":
    from ocp_vscode import show
    keycaps = [
        bd.Pos(Y=30*i) * KeycapSTL(row)
        for (row, i) in zip(KeycapRow, range(len(KeycapRow)))
        ]
    show(keycaps)