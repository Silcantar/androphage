/*******************************************************************************\
|						Bottom plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <plate_sketch.scad>

use <screw.scad>

module bottom_plate (
	edge		= BottomPlate_edge,
	thickness	= BottomPlate_thickness,
	zpos		= 0
) {
	difference () {
		place_plate ( zpos ) {
			linear_extrude (height = thickness ) {
				plate_sketch ( zpos = zpos, edge = edge );
			}
		}

		rotate ( [ 0, Halves_angles.y, 0 ] ){
			for ( pos = Screw_positions ) {
				translate ( pos + [ zpos * sin ( Halves_angles.y ), 0, -eps ] ) {
					rotate ( [ 180, 0, 0 ] ){
						screw (
							diameter	= Screw_diameter,
							length		= 2,
							head		= "flat",
							drive		= "none",
						);
					}
				}
			}
		}
	}
}

bottom_plate();