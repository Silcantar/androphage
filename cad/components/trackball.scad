/*******************************************************************************\
|						Trackball for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../globals.scad>

if ( is_undef ( $parent_modules ) ) {
	include <../androphage.scad>

	trackball ( Trackball, centers = true );
}

module trackball (
	trackball,
	centers		= false,
	// diameter	= Trackball_diameter,
	// color		= Trackball_color
) {
	color ( trackball.color ) {
		sphere ( d = trackball.diameter );
	}

	if ( centers ) {
		color ( "green", 0.5 ) {
			for ( r = [ [ 0, 0, 0 ], [ 90, 0, 0 ], [ 0, 90, 0 ] ]) {
				rotate ( r ){
					cylinder ( d = trackball.diameter + 5, h = 0.1, center = true );
				}
			}
		}
	}
}