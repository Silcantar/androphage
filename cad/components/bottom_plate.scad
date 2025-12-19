/*****************************************************************************\
|											Bottom plate for Androphage keyboard.										|
|													Copyright 2025 Joshua Lucas 												|
\*****************************************************************************/

include <../androphage_globals.scad>

use <plate_sketch.scad>

module bottom_plate ( bottomPlate, column, cluster, hinge, key ) {
	linear_extrude (height = bottomPlate.thickness) {
		offset (delta = bottomPlate.edge) {
			plate_sketch ( column, cluster, hinge, key );
		}
	}
}