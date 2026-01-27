/*******************************************************************************\
|						Switch plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../globals.scad>

use <key_placement.scad>
use <plate.scad>

use <../library/fillet.scad>

if ( is_undef ( $parent_modules ) ) {
    include <../androphage.scad>

    switch_plate ( 
        Cluster,
        Column,
        Frame,
        Key,
        Plate,
        Switch,
    );
}

module switch_plate (
    cluster,
    column,
    frame,
    key,
    plate,
    switch,
) {
    linear_extrude ( height = plate.Switch.thickness ) {
        difference () {
            fillet2d ( radius = plate.outerRadius ) {
                plate_sketch ( frame );
            }

            place_key_holes ( frame, key, plate ) {
                key_holes( cluster, column, key, switch );
            }
        }
    }
}