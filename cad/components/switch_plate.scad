/*******************************************************************************\
|						Switch plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <plate_sketch.scad>

module switch_plate ( dimensions ) {
	linear_extrude (height = dimensions.Plate.Switch.thickness) {
		difference () {
			offset ( delta = dimensions.Plate.Switch.edge ) {
				plate_sketch ( dimensions );
			}

			_place_finger_switches ( dimensions );

			_place_thumb_switches ( dimensions );
		};
	}
}

use <../androphage.scad>

switch_plate ( Dimensions() );