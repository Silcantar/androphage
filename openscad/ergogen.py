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
    name: str = ''
    version: str = ''
    author: str = ''

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
        self.meta = self.extract_meta(self.config_dict)

    def read_config(self, config_file: typing.TextIO) -> dict[str, any]:
        return yaml.safe_load(config_file)

    def extract_meta(self, config_dict: dict[str, any]) -> Meta:
        metadict = config_dict['meta']
        engine = metadict['engine']
        try:
            name = metadict['name']
            version = metadict['version']
            author = metadict['author']
        except KeyError:
            pass
        finally:
            return Meta(engine, name, version, author)


if __name__ == '__main__':
    with open('ergogen.yaml') as yf:
        eg = Ergogen(yf)
        # print(eg._config_dict)
        print(eg.meta)