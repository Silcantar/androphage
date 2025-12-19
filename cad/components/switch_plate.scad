/*****************************************************************************\
|											Switch plate for Androphage keyboard.										|
|													Copyright 2025 Joshua Lucas 												|
\*****************************************************************************/

include <../androphage_globals.scad>

use <plate_sketch.scad>

module switch_plate ( cluster, column, hinge, key, switch, switchPlate ) {
	linear_extrude (height = switchPlate.thickness) {
		difference () {
			offset ( delta = switchPlate.edge ) {
				plate_sketch ( column, cluster, hinge, key );
			}

			_place_finger_switches ( column, key, switch );

			_place_thumb_switches ( cluster, key, switch );
		};
	}
}

module _switch_hole( switch ) {
	offset (switch.radius) {
		offset (-switch.radius) {
			square( switch.size, center = true );
		}
	}
}

module _place_finger_switches ( column, key, switch ) {
	for (i = [ 0 : column.last ], j = [ 0 : column.counts[i] - 1 ]) {
		translate([(i - 1) * key.spacing.x, (column.offsets[i] + j) * key.spacing.y]) {
			_switch_hole ( switch );
		};
	}
}

module _place_thumb_switches ( cluster, key, switch ) {
	for (i = [0:len(cluster.columnCounts) -1 ]) {
		translate ([0, - cluster.radiusmm, 0]) {
			rotate ((i + 1) * cluster.angle) {
				translate ([0, cluster.radiusmm, 0]) {
					for (j = [0 : cluster.columnCounts[i] - 1]) {
						translate ([0, j * key.spacing.y, 0]) {
							_switch_hole ( switch );
						}
					}
				}
			}
		}
	}
}