/*******************************************************************************\
|							Frame for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

// include <../globals.scad>

use <../library/path.scad>

// if ( is_undef( ANDROPHAGE_MAIN ) ) {

//     $fa = 1;
//     $fs = 0.1;

//     rotate ( [ 90, 0, -90 ] ) {
//         frame( Frame, Halves, Plate );
//     }

//     rotate ( [ 180, 0, -90 ] ) {
//         translate ( [ 0, 3, 0 ] ) {
//             path_to_sketch ( Frame.path );
//         }
//     }
// }

module frame (
    // frame,
    // halves,
    // plate,
) {
    translate ( [ 0, 0, Frame.extraLength ] ) {
        difference () {
            sweep ( Frame.path, convexity = 2 ) {
                _frame_sketch();

                _frame_sketch ( notch = true );
            }

            for ( i = [ 13, 10 ] ) {
                translate_on_path ( [ for ( j = [ len ( Frame.path ) - 1 : -1 : i ] ) Frame.path[j] ] ) {
                    translate ( [ 0, Frame.size.y, 0 ] ) {
                        rotate ( [ -90, 0, -90 ] ) {
                            _notch_end_cutter();
                        }
                    }
                }
            }

            translate ( [ 0, 0, -Frame.extraLength ] ) {
                rotate ( [ Halves.angles.y, 0, 0 ] ) {
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
    // frame,
    // plate,
    notch			= false,
    rebates			= true,
) {
    chordLength = Frame.size.y / cos ( Frame.chordAngle );
    circleOffset = sqrt ( Frame.mainRadius ^ 2 - ( chordLength / 2 ) ^ 2 );
    chordCenter = (
          ( Frame.chordAngle < 0 ) ? Frame.size : [ Frame.size.x, 0 ] )
        + ( chordLength / 2 ) * [
            cos ( 90 + Frame.chordAngle ),
            sin ( 90 + Frame.chordAngle )
        ];
    mainArcCenter = chordCenter + circleOffset * [
        cos ( Frame.chordAngle ),
        sin ( Frame.chordAngle )
    ];

    difference () {
        offset ( r = Frame.filletRadius ) {
            offset ( r = -Frame.filletRadius ) {
                difference () {
                    square ( Frame.size - [ 0, notch ? Frame.notchDepth : 0 ] );

                    translate ( mainArcCenter ) {
                        circle ( r = Frame.mainRadius );
                    }
                }
            }
        }

        // Plate rebates.
        if ( rebates ) {
            for ( ypos = [ -eps, Frame.size.y - Plate.Top.thickness ] ) {
                translate ( [ -eps, ypos ] ) {
                    square ( [ Frame.lipDepth + eps, Plate.Top.thickness + eps ] );
                }
            }
        }
    }
}

module _notch_end_cutter (
    // frame,
    // plate,
) {
    rotate_extrude ( angle = 360 ) {
        difference () {
            translate ( [ 0, -eps, 0 ] )
            square ( [ Frame.notchDepth + Frame.filletRadius + eps, Frame.size.x + 2 * eps ] );

            rotate ( 90 ) {
                translate ( [ eps, -Frame.size.y - Frame.notchDepth ] ) {
                    offset ( eps ) {
                        _frame_sketch (
                            // frame,
                            // plate,
                            rebates = false
                        );
                    }
                }
            }
        }
    }
}