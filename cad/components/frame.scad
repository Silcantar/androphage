/*******************************************************************************\
|							Frame for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <../library/path.scad>

use <plates_common.scad>

$fa = 1;
$fs = 0.1;

l = ET_L(); // Linear extrude
m = ET_M(); // Mitered corner
r = ET_R(); // Rotate extrude (revolve)

rotate ( [ 90, 0, -90 ] ) {
	frame();
}

rotate ( [ 180, 0, -90 ] ) {
	translate ( [ 0, 3, 0 ] ) {
		path_to_sketch ( frame_extrudes );
	}
}

Plate_backEdgeAngle = atan ( ( 2 * Key_spacing.x ) / Key_spacing.y );

Plate_backEdgeLength = (
	1.25 * sqrt (
		( 2 * Key_spacing.x ) ^ 2
		+ Key_spacing.y ^ 2
	)
	+ sin ( Plate_backEdgeAngle ) * SwitchPlate_edge
);

Plate_backArcAngle = 180 - (
	- inner_thumb_key_angle()
	- Halves_angles.z
	+ 90
	- inner_thumb_key_angle()
	+ 90
	+ Plate_backEdgeAngle
);

Plate_outerEdgeLength = (
	  3 * Key_spacing.y
	+ ( 1 + cos ( Plate_backEdgeAngle ) ) * SwitchPlate_edge
);

cutter_height = Frame_notchDepth;

Frame_extraLength = 3;

frame_extrudes = [
//		Type,	Height / Radius,							Angle,										Profile Number
	[	l,		Frame_extraLength,							0,											0,				], //0
	[	r,		-Plate_backArcRadius,						43 - Plate_backArcAngle,					0,				], //1
	[	r,		0,											43,											0,				], //2
	[	l,		Plate_backEdgeLength,						0,											0,				], //3
	[	r,		0,											Plate_backEdgeAngle,						0,				], //4
	[	l,		Plate_outerEdgeLength,						0,											0,				], //5
	[	r,		0,											90,											0,				], //6
	[	r,		-Plate_outerArcRadius,						2 * Plate_outerArcAngle,					0,				], //7
	[	r,		0,											2 * Plate_outerArcAngle,					0,				], //8
	[	l,		2 * Key_spacing.x + cutter_height,			0,											0,				], //9
	[	l,		Key_spacing.x / 2 - cutter_height,			0,											1,				], //10
	[	r,		-Plate_frontArcRadius + SwitchPlate_edge,	inner_thumb_key_angle(),					1,				], //11
	[	l,		Key_spacing.x / 2 - cutter_height,			0,											1,				], //12
	[	l,		SwitchPlate_edge + cutter_height,			0,											0,				], //13
	[	r,		0,											90,											0,				], //14
	[	l,		SwitchPlate_edge,							0,											0,				], //15
	[	r,		-Plate_centerArcRadius + SwitchPlate_edge,	inner_thumb_key_angle() + Halves_angles.z,	0,				], //16
	[	l,		Frame_extraLength + 1,						0,											0,				], //17
];

module frame () {
	translate ( [ 0, 0, Frame_extraLength ] ) {
		difference () {
			sweep ( frame_extrudes, convexity = 2 ) {
				_frame_sketch();

				_frame_sketch ( notch = true );
			}

			for ( i = [ 13, 10 ] ) {
				translate_on_path ( [ for ( j = [ last ( frame_extrudes ) : -1 : i ] ) frame_extrudes[j] ] ) {
					translate ( [ 0, Frame_size.y, 0 ] ) {
						rotate ( [ -90, 0, -90 ] ) {
							_notch_end_cutter();
						}
					}
				}
			}

			translate ( [ 0, 0, -Frame_extraLength ] ) {
				rotate ( [ Halves_angles.y, 0, 0 ] ) {
					translate ( [ -110, -5, 0 ] ) {
						cube ( [ 120, 30, 10 ] );
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
	notch			= false,
	notchDepth		= Frame_notchDepth,
	plateThickness	= TopPlate_thickness,
	rebates			= true,
	size			= Frame_size,
) {
	chordLength = size.y / cos ( chordAngle );
	circleOffset = sqrt ( mainRadius ^ 2 - ( chordLength / 2 ) ^ 2 );
	chordCenter = (
		  ( chordAngle < 0 ) ? size : [ size.x, 0 ] )
		+ ( chordLength / 2 ) * [
			cos ( 90 + chordAngle ),
			sin ( 90 + chordAngle )
		];
	mainArcCenter = chordCenter + circleOffset * [
		cos ( chordAngle ),
		sin ( chordAngle )
	];

	difference () {
		offset ( r = filletRadius ) {
			offset ( r = -filletRadius ) {
				difference () {
					square ( size - [ 0, notch ? notchDepth : 0 ] );

					translate ( mainArcCenter ) {
						circle ( r = mainRadius );
					}
				}
			}
		}

		// Plate rebates.
		if ( rebates ) {
			for ( ypos = [ -eps, size.y - plateThickness ] ) {
				translate ( [ -eps, ypos ] ) {
					square ( [ lipDepth + eps, plateThickness + eps ] );
				}
			}
		}
	}
}

module _notch_end_cutter () {
	rotate_extrude ( angle = 360 ) {
		difference () {
			translate ( [ 0, -eps, 0 ] )
			square ( [ 5, Frame_size.x + 2 * eps ] );

			rotate ( 90 ) {
				translate ( [ eps, -Frame_size.y - Frame_notchDepth ] ) {
					offset ( eps ) {
						_frame_sketch ( rebates = false );
					}
				}
			}
		}
	}
}