/*******************************************************************************\
|						Trackball for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

module trackball (
	centers		= false,
	diameter	= Trackball_diameter,
	color		= Trackball_color
) {
	color ( color ) {
		sphere ( d = diameter );
	}

	if ( centers ) {
		color ( "green", 0.5 ) {
			for ( r = [ [ 0, 0, 0 ], [ 90, 0, 0 ], [ 0, 90, 0 ] ]) {
				rotate ( r ){
					cylinder ( d = diameter + 5, h = 0.1, center = true );
				}
			}
		}
	}
}

trackball();