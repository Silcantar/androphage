/*******************************************************************************\
|						Top plate for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <screw.scad>

use <plate_sketch.scad>

top_plate();

module top_plate (
	edge		= TopPlate_edge,
	innerRadius	= TopPlate_innerRadius,
	spacing		= Key_spacing,
	thickness	= TopPlate_thickness,
	zpos		= 0
) {
	difference () {
		place_plate ( zpos ) {
			linear_extrude ( height = thickness ) {
				difference () {
					plate_sketch ( zpos = zpos, edge = edge );

					place_trackball( zpos = zpos );

					// TODO: make these offsets more rational.
					// offset ( innerRadius ) {
					// 	offset ( -innerRadius ) {
						fillet2d ( innerRadius ) {
							place_finger_switches ( radius = 0, size = spacing );
							place_thumb_switches ( radius = 0, size = spacing, connect = true );
						}
					// 	}
					// }
				}
			}
		}

		rotate ( [ 0, Halves_angles.y, 0 ] ){
			for ( pos = Screw_positions ) {
				translate ( pos + [ zpos * sin ( Halves_angles.y ), 0, thickness + eps ] ) {
					screw (
						diameter	= Screw_diameter,
						length		= 2,
						head		= "flat",
						drive		= "none",
					);
				}
			}
		}
	}
}