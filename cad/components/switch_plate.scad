/*******************************************************************************\
|						Switch plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../androphage.scad>

use <plate_sketch.scad>

module switch_plate ( ) {
	linear_extrude (height = Dimensions().Plate.Switch.thickness) {
		difference () {
			offset ( delta = Dimensions().Plate.Switch.edge ) {
				plate_sketch ( );
			}

			_place_finger_switches ( );

			_place_thumb_switches ( );
		};
	}
}

switch_plate ( );