/*******************************************************************************\
|						Bottom plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../androphage.scad>

use <plate_sketch.scad>

module bottom_plate ( zpos = 0 ) {
	place_plate ( zpos ) {
		linear_extrude (height = Dimensions().Plate.Bottom.thickness) {
			//offset (delta = Dimensions().Plate.Bottom.edge) {
				plate_sketch ( zpos );
			//}
		}
	}
}

bottom_plate ( );