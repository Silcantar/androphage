/*******************************************************************************\
|						Bottom plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <plate_sketch.scad>

module bottom_plate (
	edge		= BottomPlate_edge,
	thickness	= BottomPlate_thickness,
	zpos		= 0
) {
	place_plate ( zpos ) {
		linear_extrude (height = thickness ) {
			plate_sketch ( zpos = zpos, edge = edge );
		}
	}
}

bottom_plate();