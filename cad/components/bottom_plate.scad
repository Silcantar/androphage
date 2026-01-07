/*******************************************************************************\
|						Bottom plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../androphage.scad>

use <plate_sketch.scad>

module bottom_plate ( zpos = 0 ) {
	place_plate ( zpos ) {
		linear_extrude (height = BottomPlate_thickness() ) {
			plate_sketch ( zpos = zpos, edge = BottomPlate_edge() );
		}
	}
}

bottom_plate();