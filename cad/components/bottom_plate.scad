/*******************************************************************************\
|						Bottom plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <plates_common.scad>

use <../library/screw.scad>

bottom_plate();

module bottom_plate (
	edge		= BottomPlate_edge,
	outerRadius	= Plate_outerRadius,
	thickness	= BottomPlate_thickness,
	zpos		= 0
) {
	// place_plate ( zpos ) {
		translate ( [ 0, 0, thickness * cos ( Halves_angles.y ) ] ){
			mirror ( [ 0, 0, 1 ]) {
				difference () {
					linear_extrude ( height = thickness ) {
						plate_sketch (
							edge		= edge,
							radius		= outerRadius,
							zpos		= zpos,
						);
					}

					// Subtract coutersunk screw holes for rendering / CNC milling.
					place_screws (
						thickness	= thickness
					) {
						screw (
							diameter	= Screw_diameter,
							length		= 2,
							head		= "flat",
							drive		= "none"
						);
					}
				}
			}
		}
	// }
}