/*******************************************************************************\
|							Top plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <plate_sketch.scad>

module top_plate (
	edge		= TopPlate_edge,
	innerRadius	= TopPlate_innerRadius,
	spacing		= Key_spacing,
	thickness	= TopPlate_thickness,
	zpos		= 18
) {
	place_plate ( zpos ) {
		linear_extrude ( height = thickness ) {
			difference () {
				plate_sketch ( zpos = zpos, edge = edge );

				place_trackball( zpos = zpos );

				// TODO: make these offsets more rational.
				place_finger_switches ( radius = innerRadius, size = spacing );
				place_thumb_switches ( radius = innerRadius, size = spacing );
			}
		}
	}
}

top_plate();