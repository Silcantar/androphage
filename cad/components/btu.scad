/*******************************************************************************\
|						BTU model for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

if ( is_undef ( ANDROPHAGE_MAIN ) ) {
    btu ( Trackball_BTU, include_cut = true );
}

module btu (
    // btu,
    include_cut = false,
) {
    translate ( [ 0, 0, (
        - BTU.L
        - BTU.H
        - BTU.L1
    ) ] ) {
        cylinder (
            d = BTU.D1,
            h = BTU.L + eps
        );
    }

    translate ( [ 0, 0, (
        - BTU.H
        - BTU.L1
    ) ] ){
        cylinder (
            d = BTU.D,
            h = BTU.H + eps
        );
    }

    translate ( [ 0, 0, - BTU.d / 2 ] ) {
        sphere ( d = BTU.d );
    }

    if ( include_cut ) {
        translate ( [ 0, 0, -BTU.L1 ] ) {
            color ( Color.cut )
            cylinder (
                d = BTU.D,
                h = 10 + eps
            );
        }
    }

}