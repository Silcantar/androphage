/*******************************************************************************\
|						BTU model for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../globals.scad>

include <../color.scad>

if ( is_undef ( $parent_modules ) ) {
    include <../androphage.scad>

    btu ( Trackball_BTU, include_cut = true );
}

module btu (
    btu,
    include_cut = false,
) {
    translate ( [ 0, 0, (
        - btu.L
        - btu.H
        - btu.L1
    ) ] ) {
        cylinder (
            d = btu.D1,
            h = btu.L + eps
        );
    }

    translate ( [ 0, 0, (
        - btu.H
        - btu.L1
    ) ] ){
        cylinder (
            d = btu.D,
            h = btu.H + eps
        );
    }

    translate ( [ 0, 0, - btu.d / 2 ] ) {
        sphere ( d = btu.d );
    }

    if ( include_cut ) {
        translate ( [ 0, 0, -btu.L1 ] ) {
            color ( Color.cut )
            cylinder (
                d = btu.D,
                h = 10 + eps
            );
        }
    }

}