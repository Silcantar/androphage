/*******************************************************************************\
|							Top plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../androphage.scad>

use <plate_sketch.scad>

module top_plate ( zpos = 18 ) {
	place_plate ( zpos ) {
		linear_extrude ( height = TopPlate_thickness() ) {
			difference () {
				plate_sketch ( zpos = zpos, edge = TopPlate_edge() );

				place_trackball( zpos = zpos );

				offset (-0.5) {
					offset (1) {
						offset (delta = -3) {
							offset (delta = 3) {
								place_finger_switches ( size = Key_spacing() );
								place_thumb_switches ( size = Key_spacing() );
							}
						}
					}
				}
			}
		}
	}
}

top_plate();