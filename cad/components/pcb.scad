/*******************************************************************************\
|						PCB model for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <plate_sketch.scad>

module pcb (
	thickness	= PCB_thickness,
	zpos		= 7
) {
	place_plate ( zpos ) {
		linear_extrude ( height = thickness ) {
			difference () {
				plate_sketch ( zpos );
			};
		}
	}
}

pcb();