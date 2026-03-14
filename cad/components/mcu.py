import typing
from collections.abc import Iterable

import build123d as bd

from common import *

class MCU(Component):
    def __init__(
        self,
        chipSize: Iterable = [12, 10, 1.5],
        radius: float = 2,
        size: Iterable = [17.8, 21, 1.2],
        usbOverhang: float = 1.5,
        usbRadius: float = 1.2,
        usbSize: Iterable = [9, 7.35, 3.2],
        usbCutSize: Iterable = [12, 10, 7],
        **kwargs
    ):
        super().__init__(**kwargs)

    def build(self) -> bd.Part:
        pass

if __name__ == '__main__':
    from ocp_vscode import show
    show(MCU())