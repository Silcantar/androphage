/*******************************************************************************\
|							Frame for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../globals.scad>

use <../library/path.scad>

if ( is_undef( $parent_modules ) ) {
	include <../androphage.scad>

	$fa = 1;
	$fs = 0.1;

	rotate ( [ 90, 0, -90 ] ) {
		frame( Frame, Halves, Plate );
	}

	rotate ( [ 180, 0, -90 ] ) {
		translate ( [ 0, 3, 0 ] ) {
			path_to_sketch ( Frame.path );
		}
	}
}

module frame (
	frame,
	halves,
	plate,
) {
	translate ( [ 0, 0, frame.extraLength ] ) {
		difference () {
			sweep ( frame.path, convexity = 2 ) {
				_frame_sketch( frame, plate );

				_frame_sketch ( frame, plate, notch = true );
			}

			for ( i = [ 13, 10 ] ) {
				translate_on_path ( [ for ( j = [ len ( frame.path ) - 1 : -1 : i ] ) frame.path[j] ] ) {
					translate ( [ 0, frame.size.y, 0 ] ) {
						rotate ( [ -90, 0, -90 ] ) {
							_notch_end_cutter( frame, plate );
						}
					}
				}
			}

			translate ( [ 0, 0, -frame.extraLength ] ) {
				rotate ( [ halves.angles.y, 0, 0 ] ) {
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
	frame,
	plate,
	notch			= false,
	rebates			= true,
) {
	chordLength = frame.size.y / cos ( frame.chordAngle );
	circleOffset = sqrt ( frame.mainRadius ^ 2 - ( chordLength / 2 ) ^ 2 );
	chordCenter = (
		  ( frame.chordAngle < 0 ) ? frame.size : [ frame.size.x, 0 ] )
		+ ( chordLength / 2 ) * [
			cos ( 90 + frame.chordAngle ),
			sin ( 90 + frame.chordAngle )
		];
	mainArcCenter = chordCenter + circleOffset * [
		cos ( frame.chordAngle ),
		sin ( frame.chordAngle )
	];

	difference () {
		offset ( r = frame.filletRadius ) {
			offset ( r = -frame.filletRadius ) {
				difference () {
					square ( frame.size - [ 0, notch ? frame.notchDepth : 0 ] );

					translate ( mainArcCenter ) {
						circle ( r = frame.mainRadius );
					}
				}
			}
		}

		// Plate rebates.
		if ( rebates ) {
			for ( ypos = [ -eps, frame.size.y - plate.Top.thickness ] ) {
				translate ( [ -eps, ypos ] ) {
					square ( [ frame.lipDepth + eps, plate.Top.thickness + eps ] );
				}
			}
		}
	}
}

module _notch_end_cutter (
	frame,
	plate,
) {
	rotate_extrude ( angle = 360 ) {
		difference () {
			translate ( [ 0, -eps, 0 ] )
			square ( [ frame.notchDepth + frame.filletRadius + eps, frame.size.x + 2 * eps ] );

			rotate ( 90 ) {
				translate ( [ eps, -frame.size.y - frame.notchDepth ] ) {
					offset ( eps ) {
						_frame_sketch (
							frame,
							plate,
							rebates = false
						);
					}
				}
			}
		}
	}
}