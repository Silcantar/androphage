/*****************************************************************************\
|											Bottom plate for Androphage keyboard.										|
|													Copyright 2025 Joshua Lucas 												|
\*****************************************************************************/

include <../androphage_globals.scad>

use <plate_sketch.scad>

module bottom_plate ( cluster, column, hinge, key, plate ) {
	linear_extrude (height = plate.Bottom.thickness) {
		offset (delta = plate.Bottom.edge) {
			plate_sketch ( cluster, column, hinge, key, plate );
		}
	}
}