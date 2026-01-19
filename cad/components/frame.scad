/*******************************************************************************\
|							Frame for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <../library/multiextrude.scad>

use <plates_common.scad>

l = ET_L(); // Linear extrude
m = ET_M(); // Mitered corner
r = ET_R(); // Rotate extrude (revolve)

frame();


Plate_backEdgeAngle = atan ( ( 2 * Key_spacing.x ) / Key_spacing.y );

Plate_backEdgeLength = sqrt ( ( 2 * Key_spacing.x ) ^ 2 + Key_spacing.y ^ 2 ) * 1.25;

Plate_backArcAngle = 180 - (
	- inner_thumb_key_angle()
	- Halves_angles.z
	+ 90
	- inner_thumb_key_angle()
	+ 90
	+ Plate_backEdgeAngle
);

step = 5;
scale = 0.75;
length = SwitchPlate_edge;

frame_extrudes = [
//		Type,	Height / Radius,															Angle,										Profile Number,	Vector,			Begin Scale,	End Scale
	[	r,		-Plate_backArcRadius,														43 - Plate_backArcAngle,					0,				[ 0, 0, 1 ],	[ 1, 1 ],		[ 1, 1 ],	],
	[	r,		0,																			43,											0,				[ 0, 0, 1 ],	[ 1, 1 ],		[ 1, 1 ],	],
	[	l,		Plate_backEdgeLength + sin ( Plate_backEdgeAngle ) * SwitchPlate_edge,		0,											0,				[ 0, 0, 1 ],	[ 1, 1 ],		[ 1, 1 ],	],
	[	r,		0,																			Plate_backEdgeAngle,						0,				[ 0, 0, 1 ],	[ 1, 1 ],		[ 1, 1 ],	],
	[	l,		3 * Key_spacing.y + ( 1 + cos ( Plate_backEdgeAngle ) ) * SwitchPlate_edge,	0,											0,				[ 0, 0, 1 ],	[ 1, 1 ],		[ 1, 1 ],	],
	[	r,		0,																			90,											0,				[ 0, 0, 1 ],	[ 1, 1 ],		[ 1, 1 ],	],
	[	r,		-Plate_outerArcRadius,														2 * Plate_outerArcAngle,					0,				[ 0, 0, 1 ],	[ 1, 1 ],		[ 1, 1 ],	],
	[	r,		0,																			2 * Plate_outerArcAngle,					0,				[ 0, 0, 1 ],	[ 1, 1 ],		[ 1, 1 ],	],
	[	l,		2.5 * Key_spacing.x,														0,											0,				[ 0, 0, 1 ],	[ 1, 1 ],		[ 1, 1 ],	],
	[	r,		-Plate_frontArcRadius + SwitchPlate_edge,									inner_thumb_key_angle(),					0,				[ 0, 0, 1 ],	[ 1, 1 ],		[ 1, 1 ],	],
	[	l,		Key_spacing.x / 2 + SwitchPlate_edge,										0,											0,				[ 0, 0, 1 ],	[ 1, 1 ],		[ 1, 1 ],	],

	// for ( i = [ 0 : step : 180 - step ] )
	// 	[	l,		SwitchPlate_edge / ( 180 / step ),											0,											0,				[ 0, 0, 1 ],	[ 1, ( scale - 1 ) * cos ( i ) / 2 + ( scale + 1 ) / 2 ],		[ 1, ( ( scale - 1 ) * cos ( i + step ) / 2 + ( scale + 1 ) / 2 ) / ( ( scale - 1 ) * cos ( i ) / 2  + ( scale + 1 ) / 2 ) ]	],

	[	r,		0,																			90,											0,				[ 0, 0, 1 ],	[ 1, 1 ],		[ 1, 1 ],	],
	[	l,		SwitchPlate_edge,															0,											0,				[ 0, 0, 1 ],	[ 1, 1 ],		[ 1, 1 ],	],
	[	r,		-Plate_centerArcRadius + SwitchPlate_edge,									inner_thumb_key_angle() + Halves_angles.z,	0,				[ 0, 0, 1 ],	[ 1, 1 ],		[ 1, 1 ],	],
	[	l,		1	/* IDK where this comes from. */,										0,											0,				[ 0, 0, 1 ],	[ 1, 1 ],		[ 1, 1 ],	]
];

module frame () {
	difference () {
		translate ( front_center_point() ) {
			rotate ( [ 90, 0, -90 - Halves_angles.z ] ) {
				multiextrude ( frame_extrudes, convexity = 2 ) {
					_frame_sketch();
				}
			}
		}

		key_positions = key_positions();
		key_indices = [ 3, 21 ];

		for ( i = [ 0, 1 ] ) {
			let ( pos = key_positions[ key_indices[i] ] ) {
				translate ( [ pos.x, pos.y, Frame_height ] ) {
					rotate ( pos[2][0] ) {
						translate ( [ 0, -Key_spacing.y / 2, 0 ] ) {
							translate ( [ ( 2 * i - 1 ) * ( Key_spacing.x + Switch_maxTravel ), 0, 0 ] ) {
								rotate ( [ 90, 0, 0 ] ) {
									#square ( [ 3 * Key_spacing.x, Switch_maxTravel * 2 ], center = true );
								}
							}

							translate ( [ ( 1 - 2 * i ) * ( Key_spacing.x - 2 * Switch_maxTravel ) / 2, 0, 0 ] ) {
								rotate ( [ 90, 0, 0 ] ) {
									#circle( r = Switch_maxTravel );
								}
							}
						}
					}
				}
			}
		}
	}
}

// Cross section of the frame.
module _frame_sketch (
	chordAngle		= Frame_chordAngle,
	filletRadius	= Frame_filletRadius,
	lipDepth		= Frame_lipDepth,
	mainRadius		= Frame_mainRadius,
	plateThickness	= TopPlate_thickness,
	size			= Frame_size,
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