/*******************************************************************************\
|							Hinge for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../library/piano_hinge.scad>

if ( is_undef ( ANDROPHAGE_MAIN ) ) {
    hinge (
        // Hinge,
        length = 100,
        angle = 20
    );
}

module hinge (
    length,
    angle	= 0,
    center	= true,
    front	= true,
    zpos = 0,
) {
    scale = Hinge_unit == "inch" ? 25.4 : 1;
    difference () {
        rotate ( [ -90, 0, 0 ] ) {
            piano_hinge (
                angle			= angle,
                center			= center,
                length			= length,
                clearance		= $eps,
                diameter		= scale * Hinge_diameter,
                knuckleLength	= scale * Hinge_knuckleDepth,
                leafThickness	= scale * Hinge_leafThickness,
                leafWidth		= scale * Hinge_leafWidth,
                pinDiameter		= scale * Hinge_pinDiameter
            );
        }

        if ( front ) {
            for ( m = [ [ 0, 0, 0 ], [ 1, 0, 0 ] ] ) {
                mirror ( m ) {
                    translate ( [ 0, -length / 2 + TopPlate_edge, 0 ] ) {
                        rotate ( [ 0, angle / 2, 0] )
                            linear_extrude ( height = scale * Hinge_diameter + 2 * $eps, center = true ) {
                                fillet2d ( TopPlate_innerRadius ) {
                                    translate ( [ zpos * sin ( Halves_angles.y ) - Frame_extraLength, -SwitchPlate_edge, 0 ] ) {
                                    place_key_holes () {
                                        key_holes (
                                            connect = true,
                                            cutout	= 2 * TopPlate_edge,
                                        );
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}