import typing
from enum import StrEnum, auto

import build123d as bd

from common import *

class PlateType(StrEnum):
    BOTTOM = auto()
    PCB = auto()
    SWITCH = auto()
    TOP = auto()

class Plate(Component):
    def __init__(
        self,
        key_locations: LocationDict = None,
        spacing: bd.VectorLike = (19, 19),
        thickness: float = 1.6,
        plate_type: PlateType = PlateType.SWITCH,
        **kwargs
    ):
        self.key_locations = key_locations
        self.thickness = thickness
        self.plate_type = plate_type
        super().__init__(**kwargs)

    def build(self):
        outline = plate_outline(self.key_locations)

if __name__ == '__main__':
    from ocp_vscode import show
    from parameters import Parameters
    params = Parameters.from_yaml_file('../androphage.yaml')
    kl = key_locations(params)
    show(Plate(kl, params['spacing'], params['plate_thickness']))