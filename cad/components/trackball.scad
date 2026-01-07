/*******************************************************************************\
|						Trackball for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../androphage.scad>

module trackball ( centers = false ) {
	sphere ( d = Trackball_diameter() );

	if ( centers ) {
		color ( "green", 0.5 ) {
			for ( r = [ [ 0, 0, 0 ], [ 90, 0, 0 ], [ 0, 90, 0 ] ]) {
				rotate ( r ){
					cylinder ( d = Trackball_diameter() + 5, h = 0.1, center = true );
				}
			}
		}
	}
}

trackball();