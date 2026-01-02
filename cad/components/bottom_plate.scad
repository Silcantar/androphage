/*******************************************************************************\
|						Bottom plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../androphage.scad>

use <plate_sketch.scad>

module bottom_plate ( ) {
	linear_extrude (height = Dimensions().Plate.Bottom.thickness) {
		// scale ( [cos ( Dimensions().Halves.angles.y ), 1, 1 ] ) {
			offset (delta = Dimensions().Plate.Bottom.edge) {
				plate_sketch ( );
			}
		// }
	}
}

bottom_plate ( );