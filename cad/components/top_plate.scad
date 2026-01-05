/*******************************************************************************\
|							Top plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../androphage.scad>

use <plate_sketch.scad>

module top_plate ( zpos = 18 ) {
	place_plate ( zpos ){
		linear_extrude (height = Dimensions().Plate.Top.thickness) {
			difference () {
				plate_sketch ( zpos = zpos, edge = Dimensions().Plate.Top.edge );

				place_trackball ( );

				offset (-0.5) {
					offset (1) {
						offset (delta = -3) {
							offset (delta = 3) {
								place_finger_switches ( size = Dimensions().Key.spacing );
								place_thumb_switches ( size = Dimensions().Key.spacing );
							}
						}
					}
				}
			}
		}
	}
}

top_plate ( );