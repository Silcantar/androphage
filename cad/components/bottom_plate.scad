/*******************************************************************************\
|						Bottom plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <plate_sketch.scad>

use <../library/screw.scad>

module bottom_plate (
	edge		= BottomPlate_edge,
	outerRadius	= Plate_outerRadius,
	thickness	= BottomPlate_thickness,
	zpos		= 0
) {
	place_plate ( zpos ) {
		translate ( [ 0, 0, thickness * cos ( Halves_angles.y ) ] ){
			mirror ( [ 0, 0, 1 ]) {
				difference () {
					plate_sketch (
						edge		= edge,
						radius		= outerRadius,
						thickness	= thickness,
						zpos		= zpos,
					);

					place_screws (
						thickness	= thickness,
						zpos		= zpos,
					);
				}
			}
		}
	}
}

bottom_plate();