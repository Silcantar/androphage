/*******************************************************************************\
|							Hinge for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../globals.scad>

use <../library/piano_hinge.scad>

if ( is_undef ( $parent_modules ) ) {
    include <../androphage.scad>

    hinge (
        Hinge,
        length = 100,
        angle = 20
    );
}

module hinge (
    halves,
    hinge,
    key,
    plate,
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
                diameter		= hinge.diameter,
                knuckleLength	= hinge.knuckleDepth,
                leafThickness	= hinge.leafThickness,
                leafWidth		= hinge.leafWidth,
                pinDiameter		= hinge.pinDiameter
            );
        }

        if ( front ) {
            for ( m = [ [ 0, 0, 0 ], [ 1, 0, 0 ] ] ) {
                mirror ( m ) {
                    translate ( [ 0, -length / 2 + topPlate.edge, 0 ] ) {
                        rotate ( [ 0, angle / 2, 0] ) rotate ( [ 0, 0, halves.angles.z ] ) {
                            translate ( -front_center_point ( zpos = plate.Top.position.z ) ) {

                                // Subtract key cutout.
                                linear_extrude ( height = hinge.diameter + 2 * eps, center = true ) {
                                    fillet2d ( TopPlate_innerRadius ) {
                                        place_switches (
                                            connect = true,
                                            cutout	= 2 * plate.Top.edge,
                                            radius	= 0,
                                            size	= key.spacing
                                        );
                                    }
                                }

                                // Subtract screw holes.
                                place_screws ( thickness = 0 ) {
                                    cylinder ( d = Screw_diameter, h = Hinge_diameter + 4 * eps, center = true );
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}