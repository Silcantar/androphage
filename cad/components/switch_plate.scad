/*****************************************************************************\
|											Switch plate for Androphage keyboard.										|
|													Copyright 2025 Joshua Lucas 												|
\*****************************************************************************/

include <../androphage_globals.scad>

use <plate_sketch.scad>

module switch_plate ( cluster, column, hinge, key, plate, switch ) {
	linear_extrude (height = plate.Switch.thickness) {
		difference () {
			offset ( delta = plate.Switch.edge ) {
				plate_sketch ( cluster, column, hinge, key, plate );
			}

			_place_finger_switches ( column, key, switch );

			_place_thumb_switches ( cluster, key, switch );
		};
	}
}