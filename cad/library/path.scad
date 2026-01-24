/*******************************************************************************\
|	Library for performing a sequence of extrudes on one sketch (2d object).	|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <math.scad>

axis = [
	[ 1, 0, 0 ], // x
	[ 0, 1, 0 ], // y
	[ 0, 0, 1 ]  // z
];

// "Enum" of extrude types.
// May be used whether you are "use"-ing or "include"-ing this library.
function ET_L () = "l"; // Linear extrude
function ET_M () = "m"; // Mitered corner
function ET_R () = "r"; // Rotate extrude (revolve)

// Shorthand for the above.
// May only be used directly if "include"-ing this library: copy-paste these
// lines into your file if you want to use these shorthands.
l = ET_L(); // Linear extrude
m = ET_M(); // Mitered corner
r = ET_R(); // Rotate extrude (revolve)

// Automatic colors for identifying extrusion segments.
colors = [
	"Red",
	"Orange",
	"Yellow",
	"Lime",
	"Green",
	"Cyan",
	"Blue",
	"Purple",
	"Magenta",
	"Pink"
];

function get_color ( index ) = colors [ ( index / 3 - 1 ) % 10 ];

function reverse ( list ) = [ for ( i = [ 1 : len ( list ) ] ) list [ len ( list ) - i ] ];

function arc_center ( p1, p2, r ) = (
	let (
		v = p2 - p1,
		lv = norm ( v ),
		u = v / lv,
		a = asin ( lv / 2 / r ),
	)
	p1 + r * u * rot2d ( 90 - a )
);

function segment_to_transform (
	seg,
	rad_axis = axis.x,
	rot_axis = axis.y,
	trans_axis = axis.z
) = (
	seg[0] == l ? (
		trans ( -seg[1] * trans_axis )
	) :
	seg[0] == m ? (
		to_affine ( rot3d ( -seg[2] * rot_axis ) )
	) :
	seg[0] == r && seg[1] < 0 ? (
		trans ( -seg[1] * rad_axis )
		* to_affine ( rot3d ( -seg[2] * rot_axis ) )
		* trans ( seg[1] * rad_axis )
	) :
	seg[0] == r && seg[1] >= 0 ? (
		trans ( -seg[1] * rad_axis )
		* to_affine ( rot3d ( seg[2] * rot_axis ) )
		* trans ( seg[1] * rad_axis )
	) :
	id ( 4 )
);

function path_to_transforms (
	path,
	rad_axis = axis.x,
	rot_axis = axis.y,
	trans_axis = axis.z
) = [
	for ( seg = path ) (
		segment_to_transform (
			seg,
			rad_axis = rad_axis,
			rot_axis = rot_axis,
			trans_axis = trans_axis
		)
	)
];

function path_to_points (
	path,
	rad_axis = axis.x,
	rot_axis = axis.y,
	trans_axis = axis.z
) = concat (
	[
		for ( i = [ 0 : len ( path ) - 1 ] ) (
			product(
				path_to_transforms (
					[ for ( j = [ 0 : i ] ) path[j] ],
					rad_axis = rad_axis,
					rot_axis = rot_axis,
					trans_axis = trans_axis
				)
			) * [ 0, 0, 0, 1 ]
		)
	],
	[[ 0, 0, 0, 1 ]]
);

module path_to_polygon (
	path,
	rad_axis = axis.x,
	rot_axis = axis.y,
	trans_axis = axis.z
) {
	points = path_to_points (
		path,
		rad_axis = rad_axis,
		rot_axis = rot_axis,
		trans_axis = trans_axis
	);

	points2d = [ for ( p = points ) [ p.x, p.z ] ];

	polygon ( points2d );
}

module path_to_sketch ( path ) {
	path2 = reverse ( path );
	points = path_to_points ( path2 );
	// for ( p = points ) {
	// 	translate ( [ p.x, p.z ] ) {
	// 		#circle ( 1 );
	// 	}
	// }
	difference () {
		union () {
			path_to_polygon ( path2 );

			// TODO: Convex arcs
		}

		// Concave arcs
		for ( i = [ 0 : len ( path2 ) - 1 ] ) {
			if ( path2[i][0] == r && path2[i][1] < 0 ) {
				let (
					c = arc_center (
						[ points[i].x, points[i].z ],
						[ points[ i - 1 ].x, points[ i - 1 ].z ],
						abs ( path2[i][1] )
					)
				) {
					translate ( c ) {
						circle ( abs ( path2[i][1] ) );//i ); //
					}
				}
			}
		}
	}
}

// Perform sequence of extrudes.
// Extrude definition format:
// extrudes = [
//     [ l, height {Twist Angle},                          {Vector}, {Scale}, Profile],
//     [ m, angle, maximum dimension of sketch,            ],
//     [ r, angle, radius (negative for concave revolve),  ],
// ];
module sweep ( extrudes, convexity = 1 ) {
	lastExtrude = extrudes [ len ( extrudes ) - 1 ];
	otherExtrudes = [ for ( i = [ 0 : len ( extrudes ) - 2 ] ) extrudes[i] ];
	profile = is_undef ( lastExtrude[3] ) ? 0 : lastExtrude[3];

	_do_extrude ( lastExtrude, convexity = convexity ) {
		children ( profile );

		sweep ( otherExtrudes, convexity = convexity ) {
			children(0);

			if ( $children > 0 ) children(1);

			if ( $children > 1 ) children(2);

			if ( $children > 2 ) children(3);
		}
	}
}

module translate_on_path (
	path,
	rad_axis = axis.x,
	rot_axis = axis.y,
	trans_axis = axis.z

) {
	transmat = product (
		path_to_transforms (
			path,
			rad_axis = rad_axis,
			rot_axis = rot_axis,
			trans_axis = trans_axis
		)
	);

	multmatrix ( transmat ) {
		children();
	}
}

// Choose which type of extrude to perform.
module _do_extrude ( extrude, convexity ) {
	if ( extrude[0] == l ) {
		_linear ( extrude, convexity ) {
			children(0);

			children(1);
		}
	}

	if ( extrude[0] == m ) {
		_miter ( extrude, convexity ) {
			children(0);

			children(1);
		}
	}

	if ( extrude[0] == r ) {
		_revolve ( extrude, convexity ) {
			children(0);

			children(1);
		}
	}
}

// Perform linear extrude.
module _linear ( extrude, convexity ) {
	assert ( len ( extrude ) >= 2, "Must specify extrude height." );

	bs	= is_undef ( extrude[5] ) ? [ 1, 1 ] : extrude[5];
	es	= is_undef ( extrude[6] ) ? [ 1, 1 ] : extrude[6];
	t	= is_undef ( extrude[2] ) ? 0 : extrude[2];
	v	= is_undef ( extrude[4] ) ? axis.z : extrude[4];

	translate ( [ 0, 0, -extrude[1] ] ) {
		color ( get_color ( $parent_modules ) ) {
			linear_extrude (
				convexity	= convexity,
				height		= extrude[1],
				scale		= es,
				twist		= t,
				v			= v
			) {
				scale ( bs ) {
					children(0);
				}
			}
		}

		if ( $children > 1 ) {
			children( [ 1 : $children - 1 ] );
		}
	}
}

// Perform mitered corner.
module _miter ( extrude, convexity ) {
	assert ( len ( extrude ) >= 3, "Must specify extrude angle *and* height." )


	color ( get_color ( $parent_modules ) ) {
		rotate ( [ 0, extrude[2] / 2, 0 ] ) {
			for ( i = [ 0, 1 ] ) {
				mirror ( [ 0, 0, i ] ) {
					difference () {
						rotate ( [ 0, extrude[2] / 2, 0 ] ) {
							linear_extrude ( h = extrude[1], convexity = convexity ) {
								children(0);
							}
						}

						translate ( [ 0, -extrude[1] - eps, 0 ] ) {
							cube ( [
								extrude[1] * ( sin ( extrude[2] ) + cos ( extrude[2] ) ) + eps,
								2 * ( extrude[1] + eps ),
								extrude[1] * sin ( extrude[2] ) + eps
							] );
						}
					}
				}
			}
		}
	}

	if ( $children > 1 ) {
		rotate ( [ 0, extrude[2], 0 ] ) {
			children( [ 1 : $children - 1 ] );
		}
	}
}

// Perform rotate extrude.
module _revolve ( extrude, convexity ) {
	assert ( len ( extrude ) >= 3, "Must specify extrude angle *and* radius." );
	bs = is_undef ( extrude[5] ) ? [ 1, 1 ] : extrude[5];


	translate ( [ -extrude[1], 0, 0 ] ) {

		color ( get_color ( $parent_modules ) ) {
			rotate ( [ 0, ( extrude[1] >= 0 ) ? 0 : -extrude[2], 0 ] ) {
				rotate ( [ -90, 0, 0 ] ) {
					rotate_extrude ( angle = extrude[2], convexity = convexity ) {
						translate ( [ extrude[1], 0 ] ) {
							scale ( bs ) {
								children(0);
							}
						}
					}
				}
			}
		}

		if ( $children > 1 ) {
			rotate ( [ 0, ( extrude[1] >= 0 ? 1 : -1 ) * extrude[2], 0 ] ) {
				translate ( [ extrude[1], 0 ] ) {
					children( [ 1 : $children - 1 ] );
				}
			}
		}
	}
}