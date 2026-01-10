/*******************************************************************************\
|				Place keys and switches for Androphage keyboard.				|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <choc_switch.scad>

use <plates_common.scad>

module keys () {
	key_pos = key_positions();
	
	place_plate () {
		for ( i = [ 0 : last ( key_pos ) ] ) {
			let ( p = key_pos[i] ) {
				translate ( [ p.x, p.y, 0 ] ){
					rotate ( p[2][0] + Keycap_style[i][1] * 180 ) {
						if ( Switch_visible ) {
							translate ( [ 0, 0, Switch_position_z ] ) {
								choc_switch ( travel = Switch_travel );
							}
						}
						if ( Keycap_visible ) {
							translate ( [ 0, 0, Keycap_position_z ] ) {
								color ( Keycap_style[i][2] ) {
									import ( str ( "../", Keycap_path, Keycap_style[i][0], ".stl" ) );
								}
							}
						}
					}
				}
			}
		}
	}
}