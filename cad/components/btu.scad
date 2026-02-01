/*******************************************************************************\
|						BTU model for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

module btu (
    include_cut = false,
) {
    translate ( [ 0, 0, (
        - Trackball_BTU_L
        - Trackball_BTU_H
        - Trackball_BTU_L1
    ) ] ) {
        cylinder (
            d = Trackball_BTU_D1,
            h = Trackball_BTU_L + $eps
        );
    }

    translate ( [ 0, 0, (
        - Trackball_BTU_H
        - Trackball_BTU_L1
    ) ] ){
        cylinder (
            d = Trackball_BTU_D,
            h = Trackball_BTU_H + $eps
        );
    }

    translate ( [ 0, 0, - Trackball_BTU_d / 2 ] ) {
        sphere ( d = Trackball_BTU_d );
    }

    if ( include_cut ) {
        translate ( [ 0, 0, -Trackball_BTU_L1 ] ) {
            color ( Color_cut )
            cylinder (
                d = Trackball_BTU_D,
                h = 10 + $eps
            );
        }
    }

}