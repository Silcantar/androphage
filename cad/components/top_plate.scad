/*****************************************************************************\
|												Top plate for Androphage keyboard.										|
|													Copyright 2026 Joshua Lucas 												|
\*****************************************************************************/

include <../androphage_globals.scad>

use <plate_sketch.scad>

module top_plate ( dimensions ) {
	linear_extrude (height = dimensions.Plate.Top.thickness) {
		difference () {
			offset ( delta = dimensions.Plate.Top.edge ) {
				plate_sketch ( dimensions );
			}

			_place_trackball ( dimensions );

			offset (-0.5) {
				offset (1) {
					offset (delta = -3) {
						offset (delta = 3) {
							switch2 = object ( dimensions.Switch, size = [dimensions.Key.spacing.x, dimensions.Key.spacing.y] );
							dimensions2 = object ( dimensions, Switch = switch2 );
							_place_finger_switches ( dimensions2 );
							_place_thumb_switches ( dimensions2 );
						}
					}
				}
			}
		}
	}
}

use <../androphage.scad>

top_plate ( Dimensions() );