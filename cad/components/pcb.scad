/*******************************************************************************\
|						PCB model for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <plates_common.scad>

module pcb (
	thickness	= PCB_thickness,
	zpos		= 7
) {
	place_plate ( zpos ) {
		difference () {
			plates_common (
				thickness = thickness,
				zpos = zpos,
			);
		};
	}
}

pcb();