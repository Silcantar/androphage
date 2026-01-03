/*******************************************************************************\
|						BTU model for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

$fa = 1;
$fs = 0.1;

use <../androphage.scad>

module btu ( include_cut = false ) {
	translate ( [ 0, 0, (
		- Dimensions().Trackball.BTU.L
		- Dimensions().Trackball.BTU.H
		- Dimensions().Trackball.BTU.L1
	) ] ) {
		cylinder (
			d = Dimensions().Trackball.BTU.D1,
			h = Dimensions().Trackball.BTU.L,
		);
	}

	translate ( [ 0, 0, (
		- Dimensions().Trackball.BTU.H
		- Dimensions().Trackball.BTU.L1
	) ] ){
		cylinder (
			d = Dimensions().Trackball.BTU.D,
			h = Dimensions().Trackball.BTU.H,
		);
	}

	translate ( [ 0, 0, - Dimensions().Trackball.BTU.d / 2 ] ) {
		sphere ( d = Dimensions().Trackball.BTU.d );
	}

	if ( include_cut ) {
		translate ( [ 0, 0, -Dimensions().Trackball.BTU.L1 ] ) {
			color ( Color().cut )
			cylinder (
				d = Dimensions().Trackball.BTU.D,
				h = 10,
			);
		}
	}

}

btu ( include_cut = false );