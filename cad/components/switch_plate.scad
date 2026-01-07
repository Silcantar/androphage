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
		linear_extrude ( height = thickness ) {
			difference () {
				plate_sketch ( zpos );

				place_finger_switches();

				place_thumb_switches();
			};
		}
	}
}

switch_plate();