/*******************************************************************************\
|							Battery for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas							|
\*******************************************************************************/

include <../globals.scad>

if ( is_undef ( $parent_modules ) ) {
    include <../androphage.scad>
    battery ( Battery );
}

module battery ( battery ) {
    color ( battery.color ) {
        cube ( battery.size - [ battery.size.z, 0, 0 ], center = true );

        for ( i = [ -1, 1 ] ) {
            translate ( [ i * ( battery.size.x - battery.size.z ) / 2, 0, 0 ] ) {
                rotate ( [ 90, 0, 0 ] ) {
                    cylinder ( d = battery.size.z, h = battery.size.y, center = true );
                }
            }
        }
    }
}