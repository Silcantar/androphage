import typing

import build123d as bd

from common import *
from parameters import Parameters

class Hinge(Component):
    """Piano hinge."""

    def __init__(
        self,
        parameters: Parameters,
        label: str = "Hinge",
        mode: bd.Mode = bd.Mode.ADD,
        **kwargs
    ):
        self.parameters = parameters
        self.mode = mode
        try:
            color
        except NameError:
            color = seq_to_color(self.parameters.Hinge.color)
        super().__init__(label=label, color=color, mode=mode, **kwargs)

    def _build(self):
        p = self.parameters
        component_list: list[bd.Part] = []
        with bd.BuildPart() as left_leaf:
            # Leaf
            bd.Box(
                length=p.Hinge.leaf_thickness,
                width=p.Hinge.length,
                height=p.Hinge.width/2,
                align=Align.RightFrontTop
            )
            # Knuckles
            bd.Cylinder(
                radius=p.Hinge.diameter/2,
                height=p.Hinge.length,
                align=Align.Bottom,
                rotation=(-90, 0, 0)
            )
            # Subtract space between knuckles
            if self.mode != bd.Mode.SUBTRACT:
                # Pin Hole
                bd.Cylinder(
                    radius=p.Hinge.pin_diameter/2,
                    height=p.Hinge.length,
                    align=Align.Bottom,
                    rotation=(-90, 0, 0),
                    mode=bd.Mode.SUBTRACT
                )
                with bd.Locations([
                    (0, i*p.Hinge.knuckle_length, 0) 
                    for i in range(0, int(p.Hinge.knuckle_count), 2)
                ]):
                    bd.Box(
                        length=p.Hinge.diameter,
                        width=p.Hinge.knuckle_length,
                        height=p.Hinge.diameter,
                        align=Align.Front,
                        mode=bd.Mode.SUBTRACT
                    )
                # Magnetic connector cutouts
                from components.magnetic_connector import MagneticConnector
                with bd.Locations(
                    bd.Vector(p.MagneticConnector.position)
                    + (
                        0, 
                        -p.Hinge.position_y, 
                        p.Plates.Top.position_z
                    )
                ):
                    MagneticConnector(
                        parameters=self.parameters,
                        mode=bd.Mode.SUBTRACT
                    )
                    with bd.Locations([
                        bd.Location(
                            position=(0, i*p.MagneticConnector.screw_offset, 0),
                            orientation=(0, 90, 0)
                        ) for i in (1, -1)
                    ]):
                        bd.CounterSinkHole(
                            radius=p.Screws.M3.hole_diameter/2,
                            counter_sink_radius=p.Screws.M3.counter_sink_diameter/2,
                            depth=BIG,
                            counter_sink_angle=p.Screws.M3.head_angle,
                            mode=bd.Mode.SUBTRACT
                        )
        left_leaf.part.label = "Left Leaf"
        component_list.append(left_leaf.part)
        # Duplicate and rotate left leaf to create right leaf.
        right_leaf = left_leaf.part.moved(bd.Location(
            position=(0, p.Hinge.length, 0),
            orientation=(0, 0, 180)
        ))
        right_leaf.label = "Right Leaf"
        component_list.append(right_leaf)
        if self.mode != bd.Mode.SUBTRACT:
            # Pin.
            pin = bd.Cylinder(
                radius=p.Hinge.pin_diameter/2,
                height=p.Hinge.length,
                align=Align.Bottom,
                rotation=(-90, 0, 0)
            )
            pin.label = "Pin"
            component_list.append(pin)
        return bd.Part(children=component_list)

    def _locate(self):
        pass

if __name__ == "__main__":
    from ocp_vscode import show
    from androphage import Androphage
    androphage = Androphage(build=False)
    show(Hinge(parameters=androphage.parameters))