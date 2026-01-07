/*******************************************************************************\
|					Outline of plates for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

inner_thumb_key_angle = (
	len( Cluster_columnCounts )
	* Cluster_angle
);

function _front_inner_middle_point() = [
	(
		( -Cluster_radius_mm + Key_spacing.y / 2 )
		* sin ( inner_thumb_key_angle )
	),
	(
		Cluster_radius_mm
		* ( cos ( inner_thumb_key_angle ) - 1 )
		- ( Key_spacing.y / 2 )
		*  cos ( inner_thumb_key_angle )
	)
];

// Front middle
function _front_middle_point() = [
	0,
	-Key_spacing.y * (0.5 - min ( Column_offsets ) )
];

// Front outer
function _front_outer_point() = (
	_front_middle_point() + [
		( len ( Column_counts ) - 1.5) * Key_spacing.x,
		0
	]
);

// Back outer
function _back_outer_point() = (
	_front_outer_point() + [
		0,
		(
			Column_counts [ pinky ]
			+ Column_offsets [ pinky ]
		) * Key_spacing.y
	]
);

// Back middle
function _back_middle_point() = [
	( middle - 1 ) * Key_spacing.x,
	Column_counts [ middle ] * Key_spacing.x
];

function _back_center_point() = (
	_center_arc_center()
	+ Hinge_length
	* [
		sin( Halves_angles.z ),
		cos( Halves_angles.z )
	]
);

// The center of the center arc.
function _center_arc_center() = (
	_center_arc_outer_end()
	+ Plate_centerArcRadius
	* [
		- cos( inner_thumb_key_angle ),
		- sin ( inner_thumb_key_angle )
	]
);

// The center of the back arc.
function _back_arc_center() = (
	_center_arc_center()
	+ (
		Plate_centerArcRadius
		+ Hinge_length
		+ Plate_backArcRadius
	) * [
		sin(Halves_angles.z),
		cos(Halves_angles.z)
	]
);

function _front_arc_center() = [
	0,
	-Cluster_radius_mm
	+ Key_spacing.y * min( Column_offsets )
];

function _outer_arc_center() = (
	_front_outer_point() + [
		0,
		Column_offsets [ pinky ] * Key_spacing.y
		- Plate_outerArcRadius
	]
);

function _center_arc_inner_end() = (
	_center_arc_center()
	+ Plate_centerArcRadius * [
		sin ( Halves_angles.z ),
		cos ( Halves_angles.z )
	]
);

function _center_arc_outer_end() = (
	_front_inner_middle_point()
	+ Key_spacing.x / 2 * [
		- cos ( inner_thumb_key_angle ),
		- sin ( inner_thumb_key_angle )
	]
);

// The point at the front of the hinge between the halves.
function front_center_point ( zpos = 0 ) = (
	_center_arc_inner_end()
	+ zpos * sin ( Halves_angles.y ) * [
		-cos ( Halves_angles.z ),
		sin ( Halves_angles.z )
	]
);

function back_center_point ( zpos = 0 ) = (
	front_center_point ( zpos = zpos )
	+ Hinge_length * [
		sin ( Halves_angles.z ),
		cos ( Halves_angles.z )
	]
);

function _back_outer_center_point() = (
	_back_arc_center()
	+ Plate_backArcRadius * [
		-sin ( Halves_angles.z ),
		-cos ( Halves_angles.z )
	]
);

function plate_sketch_points ( zpos = 0 ) = [
	_front_middle_point(),
	_front_outer_point(),
	_back_outer_point(),
	_back_middle_point(),
	_back_outer_center_point(),
	back_center_point ( zpos = zpos ),
	front_center_point ( zpos = zpos ),
	_center_arc_inner_end(),
	_center_arc_outer_end(),
	_front_inner_middle_point(),
];

module plate_sketch ( zpos = 0, edge = 0 ) {
	points = plate_sketch_points ( zpos = zpos );

	difference() {
		offset ( delta = edge ) {
			difference() {
				polygon ( points );

				translate ( _front_arc_center() ) {
					circle ( Plate_frontArcRadius );
				}
				translate ( _back_arc_center() ) {
					circle ( Plate_backArcRadius );
				}
				translate ( _center_arc_center() ) {
					circle ( Plate_centerArcRadius );
				}
				translate ( _outer_arc_center() ) {
					circle ( Plate_outerArcRadius );
				}
			}
		}

		translate (
			front_center_point()
			+ ( edge + eps ) * [
				- cos ( Halves_angles.z ) - 2 * sin ( Halves_angles.z ),
				sin ( Halves_angles.z ) - 2 * cos ( Halves_angles.z )
			]
			+ zpos * sin ( Halves_angles.y ) * [
				- cos ( Halves_angles.z ),
				sin ( Halves_angles.z )
			]
		) {
			rotate ( -Halves_angles.z ) {
				square ( [
					edge + eps,
					Hinge_length + 4 * edge
				] );
			}
		}
	}
}

module _switch_hole (
	radius	= Switch_radius,
	size	= Switch_size
) {
	offset ( radius ) {
		offset ( -radius ) {
			square ( size, center = true );
		}
	}
}

module place_finger_switches (
	radius	= Switch_radius,
	size	= Switch_size
) {
	for (
		i = [ 0 : Column_last ],
		j = [ 0 : Column_counts[i] - 1 ]
	) {
		translate ( [
			(i - 1) * Key_spacing.x,
			(Column_offsets[i] + j) * Key_spacing.y
		] ) {
			_switch_hole ( radius = radius, size = size );
		};
	}
}

module place_thumb_switches (
	radius	= Switch_radius,
	size = Switch_size
) {
	for ( i = [ 0 : len ( Cluster_columnCounts ) - 1 ] ) {
		translate ([0, - Cluster_radius_mm, 0]) {
			rotate ( ( i + 1 ) * Cluster_angle ) {
				translate ( [ 0, Cluster_radius_mm, 0 ] ) {
					for ( j = [ 0 : Cluster_columnCounts[i] - 1 ] ) {
						translate ( [ 0, j * Key_spacing.y, 0 ] ) {
							_switch_hole ( radius = radius, size = size );
						}
					}
				}
			}
		}
	}
}

function trackball_point ( zpos = 0 ) = (
	front_center_point ( zpos )
		+ Trackball_position.y * [
		sin ( Halves_angles.z ),
		cos ( Halves_angles.z )
	]
);

module place_trackball ( zpos = 0 ) {
	translate ( trackball_point ( zpos ) ) {
		circle (d = (
			Trackball_diameter
			+ 2 * Trackball_clearance
		) );
	}
}

module place_plate ( zpos = 0 ) {
	rotate ( [ 0, Halves_angles.y, 0 ] ) {
		rotate ( [ 0, 0, Halves_angles.z ] ) {
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
	# circle (1);
}

# place_finger_switches();
# place_thumb_switches();
# place_trackball ( test_zpos );