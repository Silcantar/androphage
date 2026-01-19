/*******************************************************************************\
|							Frame for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <plates_common.scad>

rotate ( [ -90, 0, 90 ] ) {
	frame();
}

l = "l"; // Linear extrude
m = "m"; // Mitered corner
r = "r"; // Rotate extrude

extrudes = [
//	Type,	angle,	height / radius
	[
		r,
		34,
		-Plate_backArcRadius
	],
	[
		r,
		43,
		0
	],
	[
		l,
		sqrt ( ( 2 * Key_spacing.x ) ^ 2 + Key_spacing.y ^ 2 ) * 1.25
	],
	[
		r,
		atan ( ( 2 * Key_spacing.x ) / Key_spacing.y ),
		0
	],
	[
		l,
		3 * Key_spacing.y
	],
	[
		r,
		90,
		0
	],
	[ 
		r,
		asin ( Key_spacing.x / Plate_outerArcRadius ),
		-Plate_outerArcRadius
	],
	[ 
		r,
		asin ( Key_spacing.x / Plate_outerArcRadius ), //54.5, // 
		0
	],
	[ 
		l,
		2.5 * Key_spacing.x
	],
	[
		r,
		inner_thumb_key_angle(),
		-Plate_frontArcRadius
	],
	[
		l,
		Key_spacing.x / 2
	],
	[
		r,
		90,
		0
	],
	[
		r,
		inner_thumb_key_angle() + Halves_angles.z,
		-Plate_centerArcRadius
	],
	// [
	// 	m,
	// 	90,
	// 	15
	// ],
	// [
	// 	l,
	// 	Hinge_size.y
	// ],
];

module multiextrude ( extrudes, convexity = 1 ) {
	lastExtrude = extrudes [ len ( extrudes ) - 1 ];
	otherExtrudes = [ for ( i = [ 0 : len ( extrudes ) - 2 ] ) extrudes[i] ];

	_do_extrude ( lastExtrude, convexity = convexity ) {
		children();

		multiextrude ( otherExtrudes, convexity = convexity ) {
			children();
		}
	}
}

module _do_extrude ( extrude, convexity ) {
	if ( extrude[0] == l ) {
		assert ( len ( extrude ) >= 2, "Must specify extrude height." );

		translate ( [ 0, 0, -extrude[1] ] ) {
			linear_extrude ( h = extrude[1], convexity = convexity ) {
				children(0);
			}

			if ( $children > 1 ) {
				children( [1 : $children - 1 ] );
			}
		}
	}

	if ( extrude[0] == m ) {
		assert ( len ( extrude ) >= 3, "Must specify extrude angle *and* height." )

		rotate ( [ 0, extrude[1] / 2, 0 ] ) {
			for ( i = [ 0, 1 ] ) {
				mirror ( [ 0, 0, i ] ) {
					difference () {
						rotate ( [ 0, extrude[1] / 2, 0 ] ) {
							linear_extrude ( h = extrude[2], convexity = convexity ) {
								children(0);
							}
						}

						translate ( [ 0, -extrude[2] - eps, 0 ] ) {
							cube ( [ 
								extrude[2] * ( sin ( extrude[1] ) + cos ( extrude[1] ) ) + eps,
								2 * ( extrude[2] + eps ),
								extrude[2] * sin ( extrude[1] ) + eps
							] );
						}
					}
				}
			}
		}

		if ( $children > 1 ) {
			rotate ( [ 0, extrude[1], 0 ] ) {
				children( [ 1 : $children - 1 ] );
			}
		}
	}

	if ( extrude[0] == r ) {
		assert ( len ( extrude ) >= 3, "Must specify extrude angle *and* radius." );

		translate ( [ -extrude[2], 0, 0 ] ) {
			rotate ( [ 0, ( extrude[2] >= 0 ) ? 0 : -extrude[1], 0 ] ) {
				rotate ( [ -90, 0, 0 ] ) {
					rotate_extrude ( angle = extrude[1], convexity = convexity ) {
						translate ( [ extrude[2], 0 ] ) {
							children(0);
						}
					}
				}
			}

			if ( $children > 1 ) {
				rotate ( [ 0, ( extrude[2] >= 0 ? 1 : -1 ) * extrude[1], 0 ] ) {
					translate ( [ extrude[2], 0 ] ) {
						children( [ 1 : $children - 1 ] );
					}
				}
			}
		}
	}
}

module frame () {
	multiextrude ( extrudes, convexity = 2 ) {
		_frame_sketch();
	}
}

// Cross section of the frame.
module _frame_sketch (
	chordAngle		= 5,
	filletRadius	= 1,
	lipDepth		= 2,
	mainRadius		= 50,
	plateThickness	= 1.6,
	size			= [ 5, 15 ],
) {
	chordLength = size.y / cos ( chordAngle );
	circleOffset = sqrt ( mainRadius ^ 2 - ( chordLength / 2 ) ^ 2 );
	chordCenter = ( ( chordAngle < 0 ) ? size : [ size.x, 0 ] ) + ( chordLength / 2 ) * [ cos ( 90 + chordAngle ), sin ( 90 + chordAngle ) ];
	mainArcCenter = chordCenter + circleOffset * [ cos ( chordAngle ), sin ( chordAngle ) ];

	translate ( [ 0, 0 ] ) {
		difference () {
			offset ( r = filletRadius ) {
				offset ( r = -filletRadius ) {
					difference () {
						square ( size );

						translate ( mainArcCenter ) {
							circle ( r = mainRadius );
						}
					}
				}
			}

			for ( ypos = [ -eps, size.y - plateThickness ] ) {
				translate ( [ -eps, ypos ] ) {
					square ( [ lipDepth + eps, plateThickness + eps ] );
				}
			}
		}
	}
}