/*******************************************************************************\
|					Outline of plates for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../library/screw.scad>

use <../library/math.scad>

use <../library/fillet.scad>

if ( is_undef ( $parent_modules ) ) {
	include <../androphage.scad>

	test_zpos = 360 * $t % 20;
	test_edge = 360 * $t % 5;

	// plate_sketch (
	// 	edge	 	= test_edge,
	// 	zpos		= test_zpos
	// );

	// // This is where the origin will be after running place_plate ()
	// translate ( front_center_point ( test_zpos ) ) {
	// 	# circle (1);
	// }

	// linear_extrude ( 1 + 2 * eps, center = true ) {
		place_switches (
			Cluster,
			Column,
			Key,
			Switch,
			connect = false,
			cutout = 0,
		);

		place_trackball ( test_zpos );
	// }
}


// function inner_thumb_key_angle () = (
// 	len( Cluster_columnCounts )
// 	* Cluster_angle
// );

// function _front_arc_inner_end () = [
// 	(
// 		( -Cluster_radius_mm + Key_spacing.y / 2 )
// 		* sin ( inner_thumb_key_angle() )
// 	),
// 	(
// 		Cluster_radius_mm
// 		* ( cos ( inner_thumb_key_angle() ) - 1 )
// 		- ( Key_spacing.y / 2 )
// 		*  cos ( inner_thumb_key_angle() )
// 	),
// 	0
// ];

// // Front middle
// function _front_middle_point() = [
// 	0,
// 	-Key_spacing.y * (0.5 - min ( Column_offsets ) ),
// 	0
// ];

// // Front outer
// function _front_outer_point() = (
// 	_front_middle_point() + [
// 		( len ( Column_counts ) - 1.5) * Key_spacing.x,
// 		0,
// 		0
// 	]
// );

// // Back outer
// function _back_outer_point() = (
// 	_front_outer_point() + [
// 		0,
// 		(
// 			Column_counts [ pinky ]
// 			+ Column_offsets [ pinky ]
// 		) * Key_spacing.y,
// 		0

// 	]
// );

// // Back middle
// function _back_middle_point() = [
// 	( middle - 1 ) * Key_spacing.x,
// 	Column_counts [ middle ] * Key_spacing.x,
// 	0
// ];

// function _back_center_point() = (
// 	_center_arc_center()
// 	+ Hinge_size.y
// 	* [
// 		sin( Halves_angles.z ),
// 		cos( Halves_angles.z ),
// 		0
// 	]
// );

// // The center of the center arc.
// function _center_arc_center() = (
// 	_center_arc_outer_end()
// 	+ Plate_centerArcRadius
// 	* [
// 		- cos( inner_thumb_key_angle() ),
// 		- sin ( inner_thumb_key_angle() ),
// 		0
// 	]
// );

// // The center of the back arc.
// function _back_arc_center() = (
// 	_center_arc_center()
// 	+ (
// 		Plate_centerArcRadius
// 		+ Hinge_length
// 		+ Plate_backArcRadius
// 	) * [
// 		sin(Halves_angles.z),
// 		cos(Halves_angles.z),
// 		0
// 	]
// );

// function _front_arc_center() = [
// 	0,
// 	-Cluster_radius_mm
// 	+ Key_spacing.y * min( Column_offsets ),
// 	0
// ];

// function _outer_arc_center() = (
// 	_front_outer_point() + [
// 		0,
// 		Column_offsets [ pinky ] * Key_spacing.y
// 		- Plate_outerArcRadius,
// 		0
// 	]
// );

// function _center_arc_inner_end() = (
// 	_center_arc_center()
// 	+ Plate_centerArcRadius * [
// 		sin ( Halves_angles.z ),
// 		cos ( Halves_angles.z ),
// 		0
// 	]
// );

// function _center_arc_outer_end() = (
// 	_front_arc_inner_end ()
// 	+ Key_spacing.x / 2 * [
// 		- cos ( inner_thumb_key_angle() ),
// 		- sin ( inner_thumb_key_angle() ),
// 		0
// 	]
// );

// // The point at the front of the hinge between the halves.
// function front_center_point ( zpos = 0 ) = (
// 	_center_arc_inner_end()
// 	+ ( zpos * sin ( Halves_angles.y ) + Halves_clearance ) * [
// 		-cos ( Halves_angles.z ),
// 		sin ( Halves_angles.z ),
// 		0
// 	]
// );

// function back_center_point ( zpos = 0 ) = (
// 	front_center_point ( zpos = zpos )
// 	+ Hinge_size.y * [
// 		sin ( Halves_angles.z ),
// 		cos ( Halves_angles.z ),
// 		0
// 	]
// );

// function _back_arc_inner_end() = (
// 	_back_arc_center()
// 	+ Plate_backArcRadius * [
// 		-sin ( Halves_angles.z ),
// 		-cos ( Halves_angles.z ),
// 		0
// 	]
// );

// function plate_sketch_points ( zpos = 0 ) = [
// 	_front_middle_point(),
// 	_front_outer_point(),
// 	_back_outer_point(),
// 	_back_middle_point(),
// 	_back_arc_inner_end(),
// 	back_center_point ( zpos = zpos ),
// 	front_center_point ( zpos = zpos ),
// 	_center_arc_inner_end(),
// 	_center_arc_outer_end(),
// 	_front_arc_inner_end ()
// ];

// module plate_sketch (
// 	clearance = 0,
// 	edge = 0,
// 	radius = 0,
// 	zpos = 0
// ) {
// 	points = plate_sketch_points ( zpos = zpos );

// 	difference() {
// 		fillet2d ( radius ) {
// 			offset ( delta = edge ) {
// 				difference() {
// 					// Main body.
// 					polygon ( [ for ( p = points ) [ p.x, p.y ] ] );

// 					// Subtract the arced sides of the plate.
// 					translate ( _front_arc_center() ) {
// 						circle ( Plate_frontArcRadius );
// 					}
// 					translate ( _back_arc_center() ) {
// 						circle ( Plate_backArcRadius );
// 					}
// 					translate ( _center_arc_center() ) {
// 						circle ( Plate_centerArcRadius );
// 					}
// 					translate ( _outer_arc_center() ) {
// 						circle ( Plate_outerArcRadius );
// 					}
// 				}
// 			}
// 		}


// 		translate (
// 			front_center_point()
// 			+ ( edge + eps ) * [
// 				- cos ( Halves_angles.z ) - 2 * sin ( Halves_angles.z ),
// 				sin ( Halves_angles.z ) - 2 * cos ( Halves_angles.z )
// 			]
// 			+ zpos * sin ( Halves_angles.y ) * [
// 				- cos ( Halves_angles.z ),
// 				sin ( Halves_angles.z )
// 			]
// 		) {
// 			rotate ( -Halves_angles.z ) {
// 				square ( [
// 					edge + clearance + eps,
// 					Hinge_size.y + 4 * edge
// 				] );
// 			}
// 		}
// 	}
// }

module _switch_hole (
	radius	= Switch.radius,
	size	= Switch.size,
	cutout	= 0,
) {
	fillet2d ( radius ) {
		translate ( [ 0, -cutout / 2, 0 ] ) {
			square ( size + [ 0, cutout ], center = true );
		}
	}
}

module _switch_hole_connector (
	angle	= Cluster.angle,
	radius	= Key.spacing.y,
) {
	difference () {
		circle ( r = radius );

		xpos = [ -4 * radius, 0 ];
		angle_multiplier = [ 0, -1 ];
		for ( i = [ 0 : 1 ] ) {
			rotate ( [ 0, 0, angle * angle_multiplier[i] ] ) {
				translate ( [ xpos[i], -2 * radius ] ) {
					square ( 4 * radius );
				}
			}
		}
	}
}

// "Drill" and "countersink" screw holes.
module place_screws (
	thickness,
	halves_angles	= halves.angles,
	screw_diameter	= Screw.diameter,
	screw_positions	= screw_positions(),
) {
	_screw_positions = screw_positions();
	_screw_rotations = screw_rotations();
	for ( i = [ 0 : len ( _screw_positions ) - 1 ] ) {
		let (
			pos = _screw_positions[i],
			rot = _screw_rotations[i]
		) {
			translate ( pos + [ 0, 0, thickness + eps ] ) {
				rotate ( rot ) {
					children();
				}
			}
		}
	}
}

function screw_positions_translated ( 
	angle = halves.angles.z,
	screw_positions = screw_positions(),
) = [
	for ( p = screw_positions ) p - front_center_point()
] * rot3d ( [ 0, 0, -angle ] );

function screw_positions ( 
	halves,
	key,
	plate,
	screw,
	trackball,
) = (
	let (
		cosz = cos ( halves.angles.z ),
		sinz = sin ( halves.angles.z ),
		edge_offset = plate.Top.edge - screw.offset,
		screw1_y = (
			+ trackball.position.y
			- trackball.diameter / 2
			- trackball.clearance
			- screw.offset
		)
	) [
		_center_arc_inner_end() + [
			screw.offset * cosz - edge_offset * sinz,
			-screw.offset * sinz - edge_offset * cosz,
			0,
		],
		_center_arc_inner_end() + [
			screw.offset * cosz + screw1_y * sinz,
			-screw.offset * sinz + screw1_y * cosz,
			0,
		],
		_back_arc_inner_end() + [
			screw.offset * cosz + edge_offset * sinz,
			-screw.offset * sinz + edge_offset * cosz,
			0
		],
		_back_middle_point () + [ 1.5, 1, 0 ],
		_back_outer_point() + [ edge_offset, 1, 0 ],
		_front_outer_point() + [
			edge_offset,
			key.spacing.y / 2 - edge_offset,
			0
		],
		_front_middle_point() + [ key.spacing.x, -edge_offset, 0 ],
	]
);

function screw_rotations ( halves ) = [
	-halves.angles.z,
	-halves.angles.z,
	-halves.angles.z,
	-90,
	180,
	180,
	90
];

function key_positions (
	cluster,
	column,
	key,
) = concat (
	// Finger keys.
	[
		for (
			i = [ 0 : column.last ],
			j = [ 0 : column.counts[i] - 1 ]
		) [
			(i - 1) * key.spacing.x,
			(column.offsets[i] + j) * key.spacing.y,
			// Properties
			[
				// Rotation
				0,
				// Cutout
				j == 0 ? column.cutouts[i] : 0,
				// Connector
				j == 0 ? column.connectors[i] : [ 0, 0 ],
			],
		],
	],
	// Thumb keys.
	[
		for (
			i = [ 0 : len ( cluster.columnCounts ) - 1 ],
			j = [ 0 : cluster.columnCounts[i] - 1 ]
		) concat (
			(
				rot2d ( ( i + 1 ) * cluster.angle )
				* [ 0, cluster.radius_mm + key.spacing.y * j ]
				+ [ 0, -cluster.radius_mm ]
			),
			// Properties
			[ [
				// Rotation
				( i + 1 ) * cluster.angle,
				// Cutout
				j == 0 ? 1 : 0,
				// Connector
				j == 0 ? [ key.spacing.y, 0 ] : [ 0, 0 ],
			] ]
		)
	]
);

module place_switches (
	cluster,
	column,
	key,
	switch,
	connect = false,
	cutout	= 0,
	// radius	= Switch_radius,
	// size	= Switch_size,
) {
	for ( p = key_positions ( cluster, column, key ) ) {
		let (
			angle		= p[2][0],
			do_cutout	= p[2][1],
			connector	= p[2][2]
		) {
			translate ( [ p.x, p.y ] ) {
				rotate ( angle ){
					_switch_hole (
						cutout	= cutout * do_cutout,
						radius	= switch.radius,
						size	= switch.size
					);

					if ( connect && connector != [ 0, 0 ] ) {
						translate ( v_mul ( size, [ 0.5, -0.5 ] ) ){
							rotate ( connector.y ) {
								_switch_hole_connector ( radius = connector.x );
							}
						}
					}
				}
			}
		}
	}
}

function trackball_point (
	halves,
	trackball,
	zpos = 0 
) = (
	front_center_point ( zpos )
		+ trackball.position.y * [
		sin ( halves.angles.z ),
		cos ( halves.angles.z )
	]
);

module place_trackball (
	trackball,
	zpos = 0,
) {
	translate ( trackball_point ( zpos ) ) {
		circle (
			d = (
				trackball.diameter
				+ 2 * trackball.clearance
			)
		);
	}
}

module place_plate ( 
	halves,
	pos = [ 0, 0, 0 ],
) {
	rotate ( [ 0, halves.angles.y, 0 ] ) {
		rotate ( [ 0, 0, halves.angles.z ] ) {
			translate ( pos - front_center_point ( 0 )) {
				children();
			}
		}
	}
}
