/*******************************************************************************\
|						Bottom plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../globals.scad>

use <plate.scad>

use <../library/fillet.scad>
use <../library/screw.scad>

if ( is_undef ( $parent_modules ) ) {
    include <../androphage.scad>

    bottom_plate (
        Frame,
        // Halves,
        Plate,
        // Screw
    );
}

module bottom_plate (
    frame,
    // halves,
    plate,
    // screw,
    // edge		= BottomPlate_edge,
    // outerRadius	= Plate_outerRadius,
    // thickness	= BottomPlate_thickness,
    // zpos		= 0
) {
    linear_extrude ( height = plate_Bottom_thickness ) {
        fillet2d ( radius = plate_outerRadius ) {
            plate_sketch ( frame );
        }
    }

                // Subtract coutersunk screw holes for rendering / CNC milling.
                // place_screws (
                //     thickness	= thickness
                // ) {
                //     screw (
                //         diameter	= screw_diameter,
                //         length		= 2,
                //         head		= "flat",
                //         drive		= "none"
                //     );
                // }
}