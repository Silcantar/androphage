/*******************************************************************************\
|					Outline of plates for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

$fa = 1;
$fs = 0.1;

use <../androphage.scad>

inner_thumb_key_angle = (
	len(Dimensions().Cluster.columnCounts)
	* Dimensions().Cluster.angle
);

function _front_inner_middle_point ( ) = [
	(
		( -Dimensions().Cluster.radiusmm + Dimensions().Key.spacing.y / 2 )
		* sin ( inner_thumb_key_angle )
	),
	(
		Dimensions().Cluster.radiusmm
		* ( cos ( inner_thumb_key_angle ) - 1 )
		- ( Dimensions().Key.spacing.y / 2 )
		*  cos ( inner_thumb_key_angle ))
];

// Front middle
function _front_middle_point ( ) = [
	0,
	-Dimensions().Key.spacing.y * (0.5 - min(Dimensions().Column.offsets))
];

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
function _back_middle_point ( ) = [
	(finger().middle - 1) * Dimensions().Key.spacing.x,
	Dimensions().Column.counts[finger().middle] * Dimensions().Key.spacing.x
];

function _back_center_point ( ) = (
	_center_arc_center ( )
	+ Dimensions().Hinge.length
	* [
		sin(Dimensions().Halves.angles.z),
		cos(Dimensions().Halves.angles.z)
	]
);

// The center of the center arc.
function _center_arc_center ( ) = (
	_center_arc_outer_end ( )
	+ Dimensions().Plate.centerArcRadius
	* [
		- cos( inner_thumb_key_angle ),
		- sin ( inner_thumb_key_angle )
	]
);

// The center of the back arc.
function _back_arc_center ( ) = (
	_center_arc_center ( )
	+ (
		Dimensions().Plate.centerArcRadius
		+ Dimensions().Hinge.length
		+ Dimensions().Plate.backArcRadius
	) * [
		sin(Dimensions().Halves.angles.z),
		cos(Dimensions().Halves.angles.z)
	]
);

function _front_arc_center ( ) = [
	0,
	-Dimensions().Cluster.radiusmm
	+ Dimensions().Key.spacing.y * min(Dimensions().Column.offsets)
];

function _outer_arc_center ( ) = (
	_front_outer_point ( ) + [
		0,
		Dimensions().Column.offsets[finger().pinky] * Dimensions().Key.spacing.y
		- Dimensions().Plate.outerArcRadius
	]
);

function _center_arc_inner_end ( ) = (
	_center_arc_center ( )
	+ Dimensions().Plate.centerArcRadius * [
		sin ( Dimensions().Halves.angles.z ),
		cos ( Dimensions().Halves.angles.z )
	]
);

function _center_arc_outer_end ( ) = (
	_front_inner_middle_point ( )
	+ Dimensions().Key.spacing.x / 2 * [
		- cos ( inner_thumb_key_angle ),
		- sin ( inner_thumb_key_angle )
	]
);

// The point at the front of the hinge between the halves.
function front_center_point ( zpos = 0 ) = (
	_center_arc_inner_end ( )
	+ zpos * sin ( Dimensions().Halves.angles.y ) * [
		-cos ( Dimensions().Halves.angles.z ),
		sin ( Dimensions().Halves.angles.z )
	]
);

function back_center_point ( zpos = 0 ) = (
	front_center_point ( zpos = zpos )
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

function plate_sketch_points ( zpos = 0 ) = [
	_front_middle_point ( ),
	_front_outer_point ( ),
	_back_outer_point ( ),
	_back_middle_point ( ),
	_back_outer_center_point ( ),
	back_center_point ( zpos = zpos ),
	front_center_point ( zpos = zpos ),
	_center_arc_inner_end ( ),
	_center_arc_outer_end ( ),
	_front_inner_middle_point ( ),
];

module plate_sketch ( zpos = 0, edge = 0 ) {
	points = plate_sketch_points ( zpos = zpos );

	difference ( ) {
		offset ( delta = edge ) {
			difference ( ) {
				polygon ( points );

				translate ( _front_arc_center ( ) ) {
					circle ( Dimensions().Plate.frontArcRadius );
				}
				translate ( _back_arc_center ( ) ) {
					circle ( Dimensions().Plate.backArcRadius );
				}
				translate ( _center_arc_center ( ) ) {
					circle ( Dimensions().Plate.centerArcRadius );
				}
				translate ( _outer_arc_center ( ) ) {
					circle ( Dimensions().Plate.outerArcRadius);
				}
			}
		}

		translate (
			front_center_point ( )
			+ edge * [
				- cos ( Dimensions().Halves.angles.z ) - 2 * sin ( Dimensions().Halves.angles.z ),
				sin ( Dimensions().Halves.angles.z ) - 2 * cos ( Dimensions().Halves.angles.z )
			]
			+ zpos * sin ( Dimensions().Halves.angles.y ) * [
				- cos ( Dimensions().Halves.angles.z ),
				sin ( Dimensions().Halves.angles.z )
			]
		) {
			rotate ( -Dimensions().Halves.angles.z ) {
				square ( [
					edge,
					Dimensions().Hinge.length + 4 * edge
				] );
			}
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

function trackball_point ( zpos = 0 ) = (
	front_center_point ( zpos )
		+ Dimensions().Trackball.position.y * [
		sin ( Dimensions().Halves.angles.z ),
		cos ( Dimensions().Halves.angles.z )
	]
);

module place_trackball ( zpos = 0 ) {
	translate ( trackball_point ( zpos ) ) {
		circle (d = (
			Dimensions().Trackball.diameter
			+ 2 * Dimensions().Trackball.clearance
		) );
	}
}

module place_plate ( zpos = 0 ) {
	rotate ( [ 0, Dimensions().Halves.angles.y, 0 ] ) {
		rotate ( [ 0, 0, Dimensions().Halves.angles.z ] ) {
			translate ( -front_center_point ( zpos ) ) {
				children();
			}
		}
	}
}

// Approximate actual values of these parameters.
test_zpos = 20;
test_edge = 5;

plate_sketch ( zpos = test_zpos, edge = test_edge );

// This is where the origin will be after running place_plate ()
translate ( front_center_point ( test_zpos ) ) {
	#circle (1);
}

# place_finger_switches ( );
# place_thumb_switches ( );
# place_trackball ( test_zpos );