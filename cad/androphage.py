import typing
import yaml
from os import PathLike

import build123d as bd

from common import *

class Androphage(bd.BasePartObject):
    def __init__(self, yamlpath: PathLike):
        with open(yamlpath) as yamlfile:
            self.params = yaml.safe_load(yamlfile)
        build()

    def build(self):
        pass


if __name__ == '__main__':
    from ocp_vscode import show
    show(Androphage('androphage.yaml'))