/*******************************************************************************\
|						Bottom plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/


use <plates_common.scad>

use <../library/path.scad>

use <../library/screw.scad>

if ( is_undef ( $parent_modules ) ) {
	include <../androphage.scad>

	bottom_plate (
		Frame,
		Halves,
		Plate,
		Screw
	);
}

module bottom_plate (
	frame,
	halves,
	plate,
	screw,
	// edge		= BottomPlate_edge,
	// outerRadius	= Plate_outerRadius,
	// thickness	= BottomPlate_thickness,
	// zpos		= 0
) {
	thickness = plate.Bottom.thickness;
	translate ( [ 0, 0, thickness * cos ( halves.angles.y ) ] ){
		mirror ( [ 0, 0, 1 ]) {
			difference () {
				linear_extrude ( height = thickness ) {
					path_to_sketch ( frame.extrudes );
					// plate_sketch (
					// 	edge		= edge,
					// 	radius		= outerRadius,
					// 	zpos		= zpos,
					// );
				}

				// Subtract coutersunk screw holes for rendering / CNC milling.
				place_screws (
					thickness	= thickness
				) {
					screw (
						diameter	= screw.diameter,
						length		= 2,
						head		= "flat",
						drive		= "none"
					);
				}
			}
		}
	}
}