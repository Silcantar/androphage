/*******************************************************************************\
|							Top plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../androphage.scad>

use <plate_sketch.scad>

module top_plate ( ) {
	linear_extrude (height = Dimensions().Plate.Top.thickness) {
		difference () {
			offset ( delta = Dimensions().Plate.Top.edge ) {
				plate_sketch ( );
			}

			_place_trackball ( );

			offset (-0.5) {
				offset (1) {
					offset (delta = -3) {
						offset (delta = 3) {
							_place_finger_switches ( size = Dimensions().Key.spacing );
							_place_thumb_switches ( size = Dimensions().Key.spacing );
						}
					}
				}
			}
		}
	}
}

top_plate ( );