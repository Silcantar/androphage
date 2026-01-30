/*******************************************************************************\
|						Trackball for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

// include <../globals.scad>

// if ( is_undef ( ANDROPHAGE_MAIN ) ) {

//     trackball ( Trackball, centers = true );
// }

module trackball (
    // trackball,
    centers		= false,
    // diameter	= Trackball_diameter,
    // color		= Trackball_color
) {
    color ( Trackball_color ) {
        sphere ( d = Trackball_diameter );
    }

    if ( centers ) {
        color ( "green", 0.5 ) {
            for ( r = [ [ 0, 0, 0 ], [ 90, 0, 0 ], [ 0, 90, 0 ] ]) {
                rotate ( r ){
                    cylinder ( d = Trackball_diameter + 5, h = 0.1, center = true );
                }
            }
        }
    }
}