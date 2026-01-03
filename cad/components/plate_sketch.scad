/*******************************************************************************\
|					Outline of plates for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

$fa = 1;
$fs = 0.1;

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

// Front middle
function _front_middle_point ( ) = (
	[
		0,
		-Dimensions().Key.spacing.y * (0.5 - min(Dimensions().Column.offsets))
	]
);

// Front outer
function _front_outer_point ( ) = (
	_front_middle_point ( ) + [
		(len(Dimensions().Column.counts) - 1.5) * Dimensions().Key.spacing.x,
		0
	]
);

// Back outer
function _back_outer_point ( ) = (
	_front_outer_point ( ) + [
		0,
		(
			Dimensions().Column.counts [ finger().pinky ]
			+ Dimensions().Column.offsets [ finger().pinky ]
		) * Dimensions().Key.spacing.y
	]
);

// Back middle
function _back_middle_point ( ) = (
	[
		(finger().middle - 1) * Dimensions().Key.spacing.x,
		Dimensions().Column.counts[finger().middle] * Dimensions().Key.spacing.x
	]
);

// The center of the front arc.
function _front_arc_center ( ) = (
	let ( itk = _inner_thumb_key ( ) )
	itk.bottomPoint + (
		Dimensions().Plate.frontArcRadius
		+ Dimensions().Key.spacing.x / 2
	) * [
		-cos(itk.angle),
		-sin(itk.angle)
	]
);

// The center of the back arc.
function _back_arc_center ( ) = (
	_front_arc_center ( )
	+ (
		Dimensions().Plate.frontArcRadius
		+ Dimensions().Hinge.length
		+ Dimensions().Plate.backArcRadius
	) * [
		sin(Dimensions().Halves.angles.z),
		cos(Dimensions().Halves.angles.z)
	]
);

function _front_outer_center_point ( ) = (
	_front_arc_center ( )
	+ Dimensions().Plate.frontArcRadius * [
		sin ( Dimensions().Halves.angles.z ),
		cos ( Dimensions().Halves.angles.z )
	]
);

// The point at the front of the hinge between the halves.
function front_center_point ( zpos ) = (
	_front_outer_center_point ( )
	+ zpos * sin ( Dimensions().Halves.angles.y ) * [
		-cos ( Dimensions().Halves.angles.z ),
		sin ( Dimensions().Halves.angles.z )
	]
);

function back_center_point ( zpos ) = (
	front_center_point ( zpos )
	+ Dimensions().Hinge.length * [
		sin ( Dimensions().Halves.angles.z ),
		cos ( Dimensions().Halves.angles.z )
	]
);

function _back_outer_center_point ( ) = (
	_back_arc_center ( )
	+ Dimensions().Plate.backArcRadius * [
		-sin ( Dimensions().Halves.angles.z ),
		-cos ( Dimensions().Halves.angles.z )
	]
);

function plate_sketch_points ( zpos ) = (
	[
		_front_middle_point ( ),
		_front_outer_point ( ),
		_back_outer_point ( ),
		_back_middle_point ( ),
		_back_arc_center ( ),
		_back_outer_center_point (),
		back_center_point ( zpos ),
		front_center_point ( zpos ),
		_front_outer_center_point ( ),
		_front_arc_center ( ),
		_inner_thumb_key().bottomPoint,
	]
);

module plate_sketch ( zpos = 0 ) {
	points = plate_sketch_points ( zpos );

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
		translate ( _back_arc_center ( ) ) {
			circle (Dimensions().Plate.backArcRadius);
		}
		translate ( _front_arc_center ( ) ) {
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

module place_finger_switches ( size = Dimensions().Switch.size ) {
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

module place_thumb_switches ( size = Dimensions().Switch.size ) {
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

function trackball_point ( zpos, edge ) = (
	front_center_point ( zpos )
		+ Dimensions().Trackball.position.y * [
		sin ( Dimensions().Halves.angles.z ),
		cos ( Dimensions().Halves.angles.z )
	]
		+ edge * [
		-cos ( Dimensions().Halves.angles.z ),
		sin ( Dimensions().Halves.angles.z )
	]
);

module place_trackball ( zpos, edge ) {
	translate ( trackball_point ( zpos, edge ) ) {
		circle (d = (
			Dimensions().Trackball.diameter
			+ 2 * Dimensions().Trackball.clearance
		) );
	}
}

module place_plate ( zpos ) {
	rotate ( [ 0, Dimensions().Halves.angles.y, 0 ] ) {
		rotate ( [ 0, 0, Dimensions().Halves.angles.z ] ) {
			translate ( -front_center_point ( zpos ) ) {
				children();
			}
		}
	}
}

zpos = 0;
edge = 0;

plate_sketch ( zpos = zpos );
# _place_finger_switches ( );
# place_thumb_switches ( );
# _place_trackball ( zpos = zpos, edge = edge );