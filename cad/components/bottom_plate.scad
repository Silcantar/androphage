/*******************************************************************************\
|						Bottom plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../androphage.scad>

use <plate_sketch.scad>

module bottom_plate ( zpos = 0 ) {
	place_plate ( zpos ) {
		linear_extrude (height = Dimensions().Plate.Bottom.thickness) {
			plate_sketch ( zpos = zpos, edge = Dimensions().Plate.Bottom.edge );
		}
	}
}

bottom_plate ( );