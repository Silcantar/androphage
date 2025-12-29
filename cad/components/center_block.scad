/*****************************************************************************\
|											Center block for Androphage keyboard.										|
|													Copyright 2025 Joshua Lucas 												|
\*****************************************************************************/

include <../androphage_globals.scad>

module center_block ( dimensions ) {
	difference () {
		cube ( [ 20, dimensions.Hinge.length, 20 ] );

		translate ( [ 0, 50, 0 ] ) {
			rotate ( [0, -60, 0] ) {
				cube ( dimensions.Trackball.sensorSize );
			}
		}
	}
}
