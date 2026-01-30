/*******************************************************************************\
|							Frame for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../library/path.scad>

module frame () {
    translate ( [ 0, 0, Frame_extraLength ] ) {
        difference () {
            sweep ( Frame_path, convexity = 2 ) {
                _frame_sketch();

                _frame_sketch ( notch = true );
            }

            for ( i = [ 13, 10 ] ) {
                translate_on_path ( [
                    for ( j = [ len ( Frame_path ) - 1 : -1 : i ] ) (
                        Frame_path[j]
                    )
                ] ) {
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
    // frame,
    // plate,
    notch			= false,
    rebates			= true,
) {
    chordLength = Frame_size.y / cos ( Frame_chordAngle );
    circleOffset = sqrt ( Frame_mainRadius ^ 2 - ( chordLength / 2 ) ^ 2 );
    chordCenter = (
          ( Frame_chordAngle < 0 ) ? Frame_size : [ Frame_size.x, 0 ] )
        + ( chordLength / 2 ) * [
            cos ( 90 + Frame_chordAngle ),
            sin ( 90 + Frame_chordAngle )
        ];
    mainArcCenter = chordCenter + circleOffset * [
        cos ( Frame_chordAngle ),
        sin ( Frame_chordAngle )
    ];

    difference () {
        offset ( r = Frame_filletRadius ) {
            offset ( r = -Frame_filletRadius ) {
                difference () {
                    square ( Frame_size - [ 0, notch ? Frame_notchDepth : 0 ] );

                    translate ( mainArcCenter ) {
                        circle ( r = Frame_mainRadius );
                    }
                }
            }
        }

        // Plate rebates.
        if ( rebates ) {
            for ( ypos = [ -$eps, Frame_size.y - TopPlate_thickness ] ) {
                translate ( [ -$eps, ypos ] ) {
                    square ( [ Frame_lipDepth + $eps, TopPlate_thickness + $eps ] );
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
            translate ( [ 0, -$eps, 0 ] )
            square ( [ Frame_notchDepth + Frame_filletRadius + $eps, Frame_size.x + 2 * $eps ] );

            rotate ( 90 ) {
                translate ( [ $eps, -Frame_size.y - Frame_notchDepth ] ) {
                    offset ( $eps ) {
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