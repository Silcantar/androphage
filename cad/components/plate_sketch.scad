/*******************************************************************************\
|					Outline of plates for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../androphage.scad>

function _inner_thumb_key ( ) =
	let (
		itk_angle = len(Dimensions().Cluster.columnCounts) * Dimensions().Cluster.angle,
		itk_coords = [
			-Dimensions().Cluster.radiusmm * sin(itk_angle),
			Dimensions().Cluster.radiusmm * (cos(itk_angle) - 1)
		]
	)
	object( [
		["angle", itk_angle],
		["coords", itk_coords],
		["bottomPoint", [
			itk_coords.x + (Dimensions().Key.spacing.y / 2) * sin(itk_angle),
			itk_coords.y - (Dimensions().Key.spacing.y / 2) * (cos(itk_angle))
		] ],
	] );

// Bottom center
function _point0 ( ) = [
	0,
	-Dimensions().Key.spacing.y * (0.5 - min(Dimensions().Column.offsets))
];

// Bottom right
function _point1 ( ) = _point0 ( ) + [
	(len(Dimensions().Column.counts) - 1.5) * Dimensions().Key.spacing.x,
	0
];

// Top right
function _point2 ( ) = _point1 ( ) + [
	0,
	(
		Dimensions().Column.counts [ finger().pinky ]
		+ Dimensions().Column.offsets [ finger().pinky ]
	) * Dimensions().Key.spacing.y
];

// Top center
function _point3 ( ) = [
	(finger().middle - 1) * Dimensions().Key.spacing.x,
	Dimensions().Column.counts[finger().middle] * Dimensions().Key.spacing.x
];

function _point5 ( ) =
	let ( itk = _inner_thumb_key ( ) )
	itk.bottomPoint + (
		Dimensions().Plate.frontArcRadius
		+ Dimensions().Key.spacing.x / 2
	) * [
		-cos(itk.angle),
		-sin(itk.angle)
	];

function _point4 ( ) = _point5 ( ) + (
	Dimensions().Plate.frontArcRadius
	+ Dimensions().Hinge.length
	+ Dimensions().Plate.backArcRadius
) * [
	sin(Dimensions().Halves.angles.z),
	cos(Dimensions().Halves.angles.z)
];

function plate_sketch_points ( ) =
	let ( itk = _inner_thumb_key ( ) )
	[
		_point0 ( ),
		_point1 ( ),
		_point2 ( ),
		_point3 ( ),
		_point4 ( ),
		_point5 ( ),
		itk.bottomPoint,
	];

function bottom_center_point ( ) =
	plate_sketch_points ( ) [5]
	+ Dimensions().Plate.frontArcRadius * [
		sin ( Dimensions().Halves.angles.z ),
		cos ( Dimensions().Halves.angles.z )
	];

module plate_sketch ( ) {
	points = plate_sketch_points ( );

	difference () {
		polygon ( points );
		translate ( [
			0,
			-Dimensions().Cluster.radiusmm
			+ Dimensions().Key.spacing.y * min(Dimensions().Column.offsets),
			0
		] ) {
			circle ((Dimensions().Cluster.radius-0.5) * Dimensions().Key.spacing.y);
		}
		translate ( points [ 4 ] ) {
			circle (Dimensions().Plate.backArcRadius);
		}
		translate ( points [ 5 ] ) {
			circle (Dimensions().Plate.frontArcRadius);
		}
		translate ( points [ 1 ] + [
			0,
			Dimensions().Column.offsets[finger().pinky] * Dimensions().Key.spacing.y
			- Dimensions().Plate.outerArcRadius
		] ) {
			circle (Dimensions().Plate.outerArcRadius);
		}
	}
}

module _switch_hole ( size = Dimensions().Switch.size ) {
	offset (Dimensions().Switch.radius) {
		offset (-Dimensions().Switch.radius) {
			square ( size, center = true );
		}
	}
}

module _place_finger_switches ( size = Dimensions().Switch.size ) {
	for (
		i = [ 0 : Dimensions().Column.last ],
		j = [ 0 : Dimensions().Column.counts[i] - 1 ]
	) {
		translate ( [
			(i - 1) * Dimensions().Key.spacing.x,
			(Dimensions().Column.offsets[i] + j) * Dimensions().Key.spacing.y
		] ) {
			_switch_hole ( size = size );
		};
	}
}

module _place_thumb_switches ( size = Dimensions().Switch.size ) {
	for (i = [0:len(Dimensions().Cluster.columnCounts) -1 ]) {
		translate ([0, - Dimensions().Cluster.radiusmm, 0]) {
			rotate ((i + 1) * Dimensions().Cluster.angle) {
				translate ([0, Dimensions().Cluster.radiusmm, 0]) {
					for (j = [0 : Dimensions().Cluster.columnCounts[i] - 1]) {
						translate ([0, j * Dimensions().Key.spacing.y, 0]) {
							_switch_hole ( size = size );
						}
					}
				}
			}
		}
	}
}

module _place_trackball ( ) {
	InnerThumbKey = _inner_thumb_key ( );

	startPoint = InnerThumbKey.bottomPoint + (
		Dimensions().Plate.frontArcRadius
		+ Dimensions().Key.spacing.x / 2
	) * [
		-cos(InnerThumbKey.angle),
		-sin(InnerThumbKey.angle)
	];

	translate (
		bottom_center_point( )
		 + Dimensions().Trackball.position * [
			sin(Dimensions().Halves.angles.z),
			cos(Dimensions().Halves.angles.z)
		]
		 + Dimensions().Plate.Top.edge * [
			-cos(Dimensions().Halves.angles.z),
			sin(Dimensions().Halves.angles.z)
		]
	) {
		circle (d = (
			Dimensions().Trackball.diameter
			+ 2 * Dimensions().Trackball.clearance
		));
	}
}

plate_sketch ( );