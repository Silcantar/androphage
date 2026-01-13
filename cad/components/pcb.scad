/*******************************************************************************\
|						PCB model for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <center_block.scad>

use <plates_common.scad>

module pcb (
	edge		= PCB_edge,
	thickness	= PCB_thickness,
	zpos		= PCB_position.z,
) {
	difference () {
		translate ( PCB_position ){
			place_plate ( zpos ) {
				difference () {
					plate_sketch (
						edge		= edge,
						thickness	= thickness,
						zpos		= zpos,
					);
				};
			}
		}

		center_block ( include_cut = true );
	}
}

pcb();