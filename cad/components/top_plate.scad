/*****************************************************************************\
|												Top plate for Androphage keyboard.										|
|													Copyright 2025 Joshua Lucas 												|
\*****************************************************************************/

include <../androphage_globals.scad>

use <plate_sketch.scad>

module top_plate ( cluster, column, hinge, key, plate, switch, trackball ) {
	linear_extrude (height = plate.Top.thickness) {
		difference () {
			offset ( delta = plate.Top.edge ) {
				plate_sketch ( cluster, column, hinge, key, plate );
			}

			_place_trackball ( cluster, hinge, key, plate, trackball );

			offset (-0.5) {
				offset (1) {
					offset (delta = -3) {
						offset (delta = 3) {
							switch2 = object ( switch, size = [key.spacing.x, key.spacing.y] );
							_place_finger_switches ( column, key, switch2 );
							_place_thumb_switches ( cluster, key, switch2 );
						}
					}
				}
			}
		}
	}
}

module _place_trackball ( cluster, hinge, key, plate, trackball ) {
	InnerThumbKey = _inner_thumb_key ( cluster, key );

	startPoint = InnerThumbKey.bottomPoint + (plate.frontArcRadius + key.spacing.x / 2) * [
		-cos(InnerThumbKey.angle),
		-sin(InnerThumbKey.angle)
	];

	translate (
		startPoint
		 + trackball.position * [sin(hinge.angle), cos(hinge.angle)]
		 + plate.Top.edge * [-cos(hinge.angle), sin(hinge.angle)]
	) {
		circle (d = trackball.diameter);
	}
}