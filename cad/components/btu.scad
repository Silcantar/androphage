/*******************************************************************************\
|						BTU model for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

btu ( include_cut = false );

module btu (
	include_cut = false,
	btu_L		= Trackball_BTU_L,
	btu_H		= Trackball_BTU_H,
	btu_L1		= Trackball_BTU_L1,
	btu_D1		= Trackball_BTU_D1,
	btu_D		= Trackball_BTU_D,
	btu_d		= Trackball_BTU_d
) {
	translate ( [ 0, 0, (
		- btu_L
		- btu_H
		- btu_L1
	) ] ) {
		cylinder (
			d = btu_D1,
			h = btu_L + eps
		);
	}

	translate ( [ 0, 0, (
		- btu_H
		- btu_L1
	) ] ){
		cylinder (
			d = btu_D,
			h = btu_H + eps
		);
	}

	translate ( [ 0, 0, - btu_d / 2 ] ) {
		sphere ( d = btu_d );
	}

	if ( include_cut ) {
		translate ( [ 0, 0, -btu_L1 ] ) {
			color ( Color_cut )
			cylinder (
				d = btu_D,
				h = 10 + eps
			);
		}
	}

}