/*******************************************************************************\
|						Bottom plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <plate_sketch.scad>

module bottom_plate ( dimensions ) {
	linear_extrude (height = dimensions.Plate.Bottom.thickness) {
		// scale ( [cos ( dimensions.Halves.angles.y ), 1, 1 ] ) {
			offset (delta = dimensions.Plate.Bottom.edge) {
				plate_sketch ( dimensions );
			}
		// }
	}
}

use <../androphage.scad>

bottom_plate ( Dimensions() );