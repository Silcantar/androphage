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
		difference () {
			plate_sketch (
				thickness = thickness,
				zpos = zpos,
			);
		};
	}
}

pcb();