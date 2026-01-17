/*******************************************************************************\
|						403450 Battery for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

battery();

module battery ( size = Battery_size ) {
	color ( Color_steel ) {
		cube ( size - [ size.z, 0, 0 ], center = true );
		
		for ( i = [ -1, 1 ] ) {
			translate ( [ i * ( size.x - size.z ) / 2, 0, 0 ] ) {
				rotate ( [ 90, 0, 0 ] ) {
					cylinder ( d = size.z, h = size.y, center = true );
				}
			}
		} 
	}
}