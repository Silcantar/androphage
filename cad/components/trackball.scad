/*****************************************************************************\
|											Trackball for Androphage keyboard.											|
|													Copyright 2026 Joshua Lucas 												|
\*****************************************************************************/

include <../androphage_globals.scad>

module trackball ( dimensions ) {
	sphere ( dimensions.Trackball.diameter / 2 );
}

use <../androphage.scad>

trackball ( Dimensions() );