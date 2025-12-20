/*****************************************************************************\
|									Outline of plates for Androphage keyboard.									|
|													Copyright 2025 Joshua Lucas 												|
\*****************************************************************************/

include <../androphage_globals.scad>

module plate_sketch ( cluster, column, hinge, key, plate ) {

	x1 = (len(column.counts) - 1.5) * key.spacing.x;

	key_diagonal = sqrt((key.spacing.x / 2) ^ 2 + (key.spacing.y / 2) ^ 2);


	// Bottom center
	point0 = [
		0,
		-key.spacing.y * (0.5 - min(column.offsets))
	];

	// Bottom right
	point1 = point0 + [
		(len(column.counts) - 1.5) * key.spacing.x,
		0
	];

	// Top right
	point2 = point1 + [
		0,
		(column.counts[pinky] + column.offsets[pinky]) * key.spacing.y
	];

	// Top center
	point3 = [
		(middle - 1) * key.spacing.x,
		column.counts[middle] * key.spacing.x
	];

	InnerThumbKey = _inner_thumb_key ( cluster, key );

	point5 = InnerThumbKey.bottomPoint + (plate.frontArcRadius + key.spacing.x / 2) * [
		-cos(InnerThumbKey.angle),
		-sin(InnerThumbKey.angle)
	];

	point4 = point5 + (hinge.length + plate.backArcRadius) * [sin(hinge.angle), cos(hinge.angle)];

	points = [
		point0,
		point1,
		point2,
		point3,
		point4,
		point5,
		InnerThumbKey.bottomPoint,
	];

	difference () {
		polygon (points);
		translate ([0, -cluster.radiusmm + key.spacing.y * min(column.offsets), 0]) {
			circle ((cluster.radius-0.5) * key.spacing.y);
		}
		translate (point4) {
			circle (plate.backArcRadius);
		}
		translate (point5) {
			circle (plate.frontArcRadius);
		}
		translate (point1 + [0, column.offsets[pinky] * key.spacing.y - plate.outerArcRadius]) {
			circle (plate.outerArcRadius);
		}
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

function _inner_thumb_key ( cluster, key ) = 
	let (
		itk_angle = len(cluster.columnCounts) * cluster.angle,
		itk_coords = [
			-cluster.radiusmm * sin(itk_angle),
			cluster.radiusmm * (cos(itk_angle) - 1)
		]
	) 
	object( [
		["angle", itk_angle],
		["coords", itk_coords],
		["bottomPoint", [
			itk_coords.x + (key.spacing.y / 2) * sin(itk_angle),
			itk_coords.y - (key.spacing.y / 2) * (cos(itk_angle))
		] ],
	] );
	