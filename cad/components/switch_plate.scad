/*******************************************************************************\
|						Switch plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <plate_sketch.scad>

module switch_plate (
	thickness	= SwitchPlate_thickness,
	zpos = 10
) {
	place_plate ( zpos ) {
		difference () {
			plate_sketch ( 
				thickness	= thickness,
				zpos		= zpos,
			);


			// Subtract key cutout.
			linear_extrude ( h = thickness + 2 * eps ){
				place_switches();
			}
		};
		
	}
}

switch_plate();