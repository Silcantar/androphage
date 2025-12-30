/*******************************************************************************\
|					Outline of plates for Androphage keyboard.					|
|							Copyright 2025 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

function _inner_thumb_key ( dimensions ) =
	let (
		itk_angle = len(dimensions.Cluster.columnCounts) * dimensions.Cluster.angle,
		itk_coords = [
			-dimensions.Cluster.radiusmm * sin(itk_angle),
			dimensions.Cluster.radiusmm * (cos(itk_angle) - 1)
		]
	)
	object( [
		["angle", itk_angle],
		["coords", itk_coords],
		["bottomPoint", [
			itk_coords.x + (dimensions.Key.spacing.y / 2) * sin(itk_angle),
			itk_coords.y - (dimensions.Key.spacing.y / 2) * (cos(itk_angle))
		] ],
	] );

// Bottom center
function _point0 ( dimensions ) = [
	0,
	-dimensions.Key.spacing.y * (0.5 - min(dimensions.Column.offsets))
];

// Bottom right
function _point1 ( dimensions ) = _point0 ( dimensions ) + [
	(len(dimensions.Column.counts) - 1.5) * dimensions.Key.spacing.x,
	0
];

// Top right
function _point2 ( dimensions ) = _point1 ( dimensions ) + [
	0,
	(
		dimensions.Column.counts[pinky]
		+ dimensions.Column.offsets[pinky]
	) * dimensions.Key.spacing.y
];

// Top center
function _point3 ( dimensions ) = [
	(middle - 1) * dimensions.Key.spacing.x,
	dimensions.Column.counts[middle] * dimensions.Key.spacing.x
];

function _point5 (dimensions) =
	let (itk = _inner_thumb_key (dimensions) )
	itk.bottomPoint + (
		dimensions.Plate.frontArcRadius
		+ dimensions.Key.spacing.x / 2
	) * [
		-cos(itk.angle),
		-sin(itk.angle)
	];

function _point4 ( dimensions ) = _point5 ( dimensions ) + (
	dimensions.Plate.frontArcRadius
	+ dimensions.Hinge.length
	+ dimensions.Plate.backArcRadius
) * [
	sin(dimensions.Halves.angles.z),
	cos(dimensions.Halves.angles.z)
];

function plate_sketch_points ( dimensions ) =
	let ( itk = _inner_thumb_key (dimensions) )
	[
		_point0 ( dimensions ),
		_point1 ( dimensions ),
		_point2 ( dimensions ),
		_point3 ( dimensions ),
		_point4 ( dimensions ),
		_point5 ( dimensions ),
		itk.bottomPoint,
	];

function bottom_center_point ( dimensions ) =
	plate_sketch_points ( dimensions ) [5]
	+ dimensions.Plate.frontArcRadius * [
		sin ( dimensions.Halves.angles.z ),
		cos ( dimensions.Halves.angles.z )
	];

module plate_sketch ( dimensions ) {
	points = plate_sketch_points ( dimensions );

	difference () {
		polygon ( points );
		translate ( [
			0,
			-dimensions.Cluster.radiusmm
			+ dimensions.Key.spacing.y * min(dimensions.Column.offsets),
			0
		] ) {
			circle ((dimensions.Cluster.radius-0.5) * dimensions.Key.spacing.y);
		}
		translate ( points [ 4 ] ) {
			circle (dimensions.Plate.backArcRadius);
		}
		translate ( points [ 5 ] ) {
			circle (dimensions.Plate.frontArcRadius);
		}
		translate ( points [ 1 ] + [
			0,
			dimensions.Column.offsets[pinky] * dimensions.Key.spacing.y
			- dimensions.Plate.outerArcRadius
		] ) {
			circle (dimensions.Plate.outerArcRadius);
		}
	}
}

module _switch_hole( dimensions ) {
	offset (dimensions.Switch.radius) {
		offset (-dimensions.Switch.radius) {
			square( dimensions.Switch.size, center = true );
		}
	}
}

module _place_finger_switches ( dimensions ) {
	for (
		i = [ 0 : dimensions.Column.last ],
		j = [ 0 : dimensions.Column.counts[i] - 1 ]
	) {
		translate ( [
			(i - 1) * dimensions.Key.spacing.x,
			(dimensions.Column.offsets[i] + j) * dimensions.Key.spacing.y
		] ) {
			_switch_hole ( dimensions );
		};
	}
}

module _place_thumb_switches ( dimensions ) {
	for (i = [0:len(dimensions.Cluster.columnCounts) -1 ]) {
		translate ([0, - dimensions.Cluster.radiusmm, 0]) {
			rotate ((i + 1) * dimensions.Cluster.angle) {
				translate ([0, dimensions.Cluster.radiusmm, 0]) {
					for (j = [0 : dimensions.Cluster.columnCounts[i] - 1]) {
						translate ([0, j * dimensions.Key.spacing.y, 0]) {
							_switch_hole ( dimensions );
						}
					}
				}
			}
		}
	}
}

module _place_trackball ( dimensions ) {
	InnerThumbKey = _inner_thumb_key ( dimensions );

	startPoint = InnerThumbKey.bottomPoint + (
		dimensions.Plate.frontArcRadius
		+ dimensions.Key.spacing.x / 2
	) * [
		-cos(InnerThumbKey.angle),
		-sin(InnerThumbKey.angle)
	];

	translate (
		bottom_center_point( dimensions )
		 + dimensions.Trackball.position * [
			sin(dimensions.Halves.angles.z),
			cos(dimensions.Halves.angles.z)
		]
		 + dimensions.Plate.Top.edge * [
			-cos(dimensions.Halves.angles.z),
			sin(dimensions.Halves.angles.z)
		]
	) {
		circle (d = dimensions.Trackball.diameter);
	}
}