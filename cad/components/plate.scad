/*******************************************************************************\
|				Common sketch for Androphage keyboard plates.					|
|						Copyright 2026 Joshua Lucas 						    |
\*******************************************************************************/

include <../globals.scad>

use <../library/path.scad>

if ( is_undef ( $parent_modules ) ) {
    include <../androphage.scad>

    plate_sketch ( Frame );
}

module plate_sketch ( frame ) {
    mirror ( [ 1, 1, 0 ] ) {
        path_to_sketch ( frame.path );
    }
}