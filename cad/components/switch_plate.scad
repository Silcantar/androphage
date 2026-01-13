/*******************************************************************************\
|						Switch plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <plates_common.scad>

use <center_block.scad>

switch_plate ( zpos = SwitchPlate_position.z );

module switch_plate (
	thickness	= SwitchPlate_thickness,
	zpos = 10,
) {
	difference () {
		translate ( SwitchPlate_position ) {
			place_plate ( zpos = zpos ) {
				difference () {
					plate_sketch ( 
						edge		= SwitchPlate_edge,
						thickness	= thickness,
						zpos		= zpos,
					);


					// Subtract key cutout.
					translate ( [ 0, 0, -eps ] ) {
						linear_extrude ( h = thickness + 2 * eps ) {
							place_switches();
						}
					}
				};
				
			}
		}

		center_block( include_cut = true );
	}
}