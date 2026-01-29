/*******************************************************************************\
|							Hinge for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

// include <../globals.scad>

use <../library/piano_hinge.scad>

if ( is_undef ( ANDROPHAGE_MAIN ) ) {
    hinge (
        // Hinge,
        length = 100,
        angle = 20
    );
}

module hinge (
    // halves,
    // hinge,
    // key,
    // plate,
    length,
    angle	= 0,
    center	= true,
    front	= true
) {
    difference () {
        rotate ( [ -90, 0, 0 ] ) {
            piano_hinge (
                angle			= angle,
                center			= center,
                length			= length,
                clearance		= eps,
                diameter		= Hinge.diameter,
                knuckleLength	= Hinge.knuckleDepth,
                leafThickness	= Hinge.leafThickness,
                leafWidth		= Hinge.leafWidth,
                pinDiameter		= Hinge.pinDiameter
            );
        }

        if ( front ) {
            for ( m = [ [ 0, 0, 0 ], [ 1, 0, 0 ] ] ) {
                mirror ( m ) {
                    translate ( [ 0, -length / 2 + TopPlate.edge, 0 ] ) {
                        rotate ( [ 0, angle / 2, 0] ) rotate ( [ 0, 0, Halves.angles.z ] ) {
                            translate ( -front_center_point ( zpos = Plate.Top.position.z ) ) {

                                // Subtract key cutout.
                                linear_extrude ( height = Hinge.diameter + 2 * eps, center = true ) {
                                    fillet2d ( TopPlate.innerRadius ) {
                                        place_switches (
                                            connect = true,
                                            cutout	= 2 * Plate.Top.edge,
                                            radius	= 0,
                                            size	= Key.spacing
                                        );
                                    }
                                }

                                // Subtract screw holes.
                                place_screws ( thickness = 0 ) {
                                    cylinder ( d = Screw.diameter, h = Hinge.diameter + 4 * eps, center = true );
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}