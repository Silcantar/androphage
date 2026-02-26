import typing
import yaml

from dataclasses import dataclass

type FileLike = str | Path | File

type Point = tuple[float, float]

class Zone:
    pass

@dataclass
class Anchor:
    ref: str
    aggregate: tuple[list[str], str]
    orient: str | float
    shift: Point
    rotate: float
    affect: str | list[str]
    resist: bool

class MultiAnchor:
    anchors: list[Anchor]

@dataclass
class Column:
    stagger: float
    spread: float
    splay: float
    padding: float
    orient: float
    shift: Point
    rotate: float
    adjust: float
    bind: list[int]
    autobind: int
    skip: bool
    asym: str
    mirror: any
    colrow: str
    name: str
    width: float
    height: float

@dataclass
class Meta:
    engine: str
    name: str = None
    version: str = None
    author: str = None

@dataclass
class Units:
    pass

class Points:
    zones: list[Zone]

class Outlines:
    pass

class Cases:
    pass

class PCBs:
    pass

class Ergogen:
    meta: Meta
    points: Points
    outlines: Outlines
    cases: Cases
    pcbs: PCBs
    config_dict: dict[str, any]

    def __init__(self, config_file: typing.TextIO):
        self.config_dict = self.read_config(config_file)
        self.meta = self.extract_meta()

    def read_config(self, config_file: typing.TextIO) -> dict[str, any]:
        return yaml.safe_load(config_file)

    def extract_meta(self) -> Meta:
        metadict = self.config_dict['meta']
        meta = Meta(engine=metadict['engine'])
        for fieldname in ['name', 'version', 'author']:
            try:
                meta.__dict__[fieldname] = metadict[fieldname]
            except KeyError:
                pass
        return meta

    def extract_units(self) -> Units:
        unitsdict = self.config_dict['units']


if __name__ == '__main__':
    with open('cad/androphage.yaml') as yf:
        eg = Ergogen(yf)
        # print(eg._config_dict)
        print(eg.meta)