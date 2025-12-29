/*****************************************************************************\
|											Trackball for Androphage keyboard.											|
|													Copyright 2025 Joshua Lucas 												|
\*****************************************************************************/

include <../androphage_globals.scad>

module trackball ( dimensions ) {
	sphere ( dimensions.Trackball.diameter / 2 );
}