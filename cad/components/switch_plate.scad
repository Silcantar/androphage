/*******************************************************************************\
|						Switch plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../androphage.scad>

use <plate_sketch.scad>

module switch_plate ( zpos = 10 ) {
	place_plate ( zpos ) {
		linear_extrude ( height = SwitchPlate_thickness() ) {
			difference () {
				plate_sketch ( zpos );

				place_finger_switches();

				place_thumb_switches();
			};
		}
	}
}

switch_plate();