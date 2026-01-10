/*******************************************************************************\
|					Outline of plates for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <../library/screw.scad>

// Approximate actual values of these parameters.
test_zpos = 360 * $t % 20;
test_edge = 360 * $t % 5;

plates_common (
	edge	 	= test_edge,
	thickness	= 0.5,
	zpos		= test_zpos,
);

// This is where the origin will be after running place_plate ()
translate ( front_center_point ( test_zpos ) ) {
	# circle (1);
}

color ( "orange" ){
	linear_extrude ( 1 + 2 * eps, center = true ) {
		place_switches (
			connect = true,
			cutout = 5,
			radius = 0,
			size = Key_spacing,
		);
		// place_thumb_switches();
		place_trackball ( test_zpos );
	}
}


inner_thumb_key_angle = (
	len( Cluster_columnCounts )
	* Cluster_angle
);

function _front_arc_inner_end () = [
	(
		( -Cluster_radius_mm + Key_spacing.y / 2 )
		* sin ( inner_thumb_key_angle )
	),
	(
		Cluster_radius_mm
		* ( cos ( inner_thumb_key_angle ) - 1 )
		- ( Key_spacing.y / 2 )
		*  cos ( inner_thumb_key_angle )
	),
	0
];

// Front middle
function _front_middle_point() = [
	0,
	-Key_spacing.y * (0.5 - min ( Column_offsets ) ),
	0
];

// Front outer
function _front_outer_point() = (
	_front_middle_point() + [
		( len ( Column_counts ) - 1.5) * Key_spacing.x,
		0,
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
		) * Key_spacing.y,
		0

	]
);

// Back middle
function _back_middle_point() = [
	( middle - 1 ) * Key_spacing.x,
	Column_counts [ middle ] * Key_spacing.x,
	0
];

function _back_center_point() = (
	_center_arc_center()
	+ Hinge_size.y
	* [
		sin( Halves_angles.z ),
		cos( Halves_angles.z ),
		0
	]
);

// The center of the center arc.
function _center_arc_center() = (
	_center_arc_outer_end()
	+ Plate_centerArcRadius
	* [
		- cos( inner_thumb_key_angle ),
		- sin ( inner_thumb_key_angle ),
		0
	]
);

// The center of the back arc.
function _back_arc_center() = (
	_center_arc_center()
	+ (
		Plate_centerArcRadius
		+ Hinge_size.y
		+ Plate_backArcRadius
	) * [
		sin(Halves_angles.z),
		cos(Halves_angles.z),
		0
	]
);

function _front_arc_center() = [
	0,
	-Cluster_radius_mm
	+ Key_spacing.y * min( Column_offsets ),
	0
];

function _outer_arc_center() = (
	_front_outer_point() + [
		0,
		Column_offsets [ pinky ] * Key_spacing.y
		- Plate_outerArcRadius,
		0
	]
);

function _center_arc_inner_end() = (
	_center_arc_center()
	+ Plate_centerArcRadius * [
		sin ( Halves_angles.z ),
		cos ( Halves_angles.z ),
		0
	]
);

function _center_arc_outer_end() = (
	_front_arc_inner_end ()
	+ Key_spacing.x / 2 * [
		- cos ( inner_thumb_key_angle ),
		- sin ( inner_thumb_key_angle ),
		0
	]
);

// The point at the front of the hinge between the halves.
function front_center_point ( zpos = 0 ) = (
	_center_arc_inner_end()
	+ zpos * sin ( Halves_angles.y ) * [
		-cos ( Halves_angles.z ),
		sin ( Halves_angles.z ),
		0
	]
);

function back_center_point ( zpos = 0 ) = (
	front_center_point ( zpos = zpos )
	+ Hinge_size.y * [
		sin ( Halves_angles.z ),
		cos ( Halves_angles.z ),
		0
	]
);

function _back_arc_inner_end() = (
	_back_arc_center()
	+ Plate_backArcRadius * [
		-sin ( Halves_angles.z ),
		-cos ( Halves_angles.z ),
		0
	]
);

function plates_common_points ( zpos = 0 ) = [
	_front_middle_point(),
	_front_outer_point(),
	_back_outer_point(),
	_back_middle_point(),
	_back_arc_inner_end(),
	back_center_point ( zpos = zpos ),
	front_center_point ( zpos = zpos ),
	_center_arc_inner_end(),
	_center_arc_outer_end(),
	_front_arc_inner_end (),
];

module plates_common (
	thickness,
	edge = 0,
	radius = 0,
	zpos = 0,
) {
	points = plates_common_points ( zpos = zpos );

	linear_extrude ( h = thickness ){
		difference() {
			fillet2d ( radius ) {
				offset ( delta = edge ) {
					difference() {
						// Main body.
						polygon ( [ for ( p = points ) [ p.x, p.y ] ] );

						// Subtract the arced sides of the plate.
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
						Hinge_size.y + 4 * edge
					] );
				}
			}
		}
	}
}

module place_led_holes (
	shape = "square",
) {
	translate ( LED_position ) {
		for ( i = [ 0 : LED_count - 1 ] ) {
			translate ( LED_holeSpacing * i ) {
				if ( shape == "circle" ) {
					circle ( d = LED_holeSize.x );
				} else {
					square ( LED_holeSize, center = true );
				}
			}
		}
	}
}

module _switch_hole (
	radius	= Switch_radius,
	size	= Switch_size,
	cutout	= 0,
) {
	fillet2d ( radius ) {
		translate ( [ 0, -cutout / 2, 0 ] ) {
			square ( size + [ 0, cutout ], center = true );
		}
	}
}

module _switch_hole_connector (
	angle	= Cluster_angle,
	radius	= Key_spacing.y,
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
	zpos,
	halves_angles	= Halves_angles,
	screw_diameter	= Screw_diameter,
	screw_positions	= screw_positions(),
) {
	for ( pos = screw_positions ) {
		translate ( pos + [
			0,//zpos * sin ( halves_angles.y ),
			0,
			thickness + eps
		] ) {
			screw (
				diameter	= screw_diameter,
				length		= 2,
				head		= head_flat,
				drive		= drive_none,
			);
		}
	}
}

function screw_positions_translated ( ) =  [
	for ( p = screw_positions() ) p - front_center_point()
] * rot3d ( [ 0, 0, -Halves_angles.z ] ) ;

function screw_positions ( ) = (
	let (
		cosz = cos ( Halves_angles.z ),
		sinz = sin ( Halves_angles.z ),
		edge_offset = TopPlate_edge - Screw_offset,
		screw1_y = (
			+ Trackball_position_y
			- Trackball_diameter / 2
			- Trackball_clearance
			- Screw_offset
		),
	) [
		_center_arc_inner_end() + [
			Screw_offset * cosz - edge_offset * sinz,
			-Screw_offset * sinz - edge_offset * cosz,
			0,
		],
		_center_arc_inner_end() + [
			Screw_offset * cosz + screw1_y * sinz,
			-Screw_offset * sinz + screw1_y * cosz,
			0,
		],
		_back_arc_inner_end() + [
			Screw_offset * cosz + edge_offset * sinz,
			-Screw_offset * sinz + edge_offset * cosz,
			0
		],
		_back_middle_point () + [ 1.5, 1, 0 ],
		_back_outer_point() + [ edge_offset, 1, 0 ],
		_front_outer_point() + [
			edge_offset,
			Key_spacing.y / 2 - edge_offset,
			0
		],
		_front_middle_point() + [ Key_spacing.x, -edge_offset, 0 ],
	]
);

function key_positions () = concat (
	// Finger keys.
	[
		for (
			i = [ 0 : Column_last ],
			j = [ 0 : Column_counts[i] - 1 ],
		) [
			(i - 1) * Key_spacing.x,
			(Column_offsets[i] + j) * Key_spacing.y,
			// Properties
			[
				// Rotation
				0,
				// Cutout
				j == 0 ? Column_cutouts[i] : 0,
				// Connector
				j == 0 ? Column_connectors[i] : [ 0, 0 ],
			],
		],
	],
	// Thumb keys.
	[
		for (
			i = [ 0 : last ( Cluster_columnCounts ) ],
			j = [ 0 : Cluster_columnCounts[i] - 1 ],
		) concat (
			(
				rot2d ( ( i + 1 ) * Cluster_angle )
				* [ 0, Cluster_radius_mm + Key_spacing.y * j ]
				+ [ 0, -Cluster_radius_mm ]
			),
			// Properties
			[ [
				// Rotation
				( i + 1 ) * Cluster_angle,
				// Cutout
				j == 0 ? 1 : 0,
				// Connector
				j == 0 ? [ Key_spacing.y, 0 ] : [ 0, 0 ],
			] ]
		)
	]
);

module place_switches (
	thickness,
	connect = false,
	cutout	= 0,
	radius	= Switch_radius,
	size	= Switch_size,
) {
	// echo ( key_positions() );
	for ( p = key_positions() ) {
		let (
			angle		= p[2][0],
			do_cutout	= p[2][1],
			connector	= p[2][2],
		) {
			translate ( [ p.x, p.y ] ) {
				rotate ( angle ){
					_switch_hole (
						cutout	= cutout * do_cutout,
						radius	= radius,
						size	= size,
					);

					if ( connect && connector != [ 0, 0 ] ) {
						translate ( v_mul ( size, [ 0.5, -0.5 ] ) ){
							rotate ( connector.y ) {
								_switch_hole_connector ( radius = connector.x );
							}
						}
					}

					// if ( p[2][2] ) {
					// 	translate ( v_mul ( Key_spacing, [ -0.5, 0.5 ] ) ) {
					// 		rotate ( [ 0, 0, 90 + Cluster_angle ]) {
					// 			_switch_hole_connector ( radius = Key_spacing.x );
					// 		}
					// 	}
					// }
				}
			}
		}
	}
}

module place_thumb_switches (
	thickness,
	connect	= false,
	cutout	= 0,
	radius	= Switch_radius,
	size	= Switch_size,
) {
	// for ( i = [ 0 : len ( Cluster_columnCounts ) - 1 ] ) {
	// 	translate ([0, - Cluster_radius_mm, 0]) {
	// 		rotate ( ( i + 1 ) * Cluster_angle ) {
	// 			translate ( [ 0, Cluster_radius_mm, 0 ] ) {
	// 				for ( j = [ 0 : Cluster_columnCounts[i] - 1 ] ) {
	// 					translate ( [ 0, j * Key_spacing.y, 0 ] ) {
	// 						_switch_hole (
	// 							cutout	= j == 0 ? cutout * Cluster_cutouts[i] : 0,
	// 							radius	= radius,
	// 							size	= size
	// 						);

	// 						if ( connect && j == 0 ) {
	// 							translate ( v_mul ( size, [ 0.5, -0.5 ] ) ){
	// 								_switch_hole_connector();
	// 							}
	// 						}
	// 					}
	// 				}
	// 			}
	// 		}
	// 	}
	// }

	//
	// }
}

function trackball_point ( zpos = 0 ) = (
	front_center_point ( zpos )
		+ Trackball_position.y * [
		sin ( Halves_angles.z ),
		cos ( Halves_angles.z )
	]
);

module place_trackball (
	thickness,
	zpos = 0,
) {
	translate ( trackball_point ( zpos ) ) {
		cylinder (
			d = (
				Trackball_diameter
				+ 2 * Trackball_clearance
			),
			h = thickness,
		);
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
