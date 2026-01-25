/*******************************************************************************\
|							Hinge for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <../library/piano_hinge.scad>

use <plates_common.scad>

hinge ( length = 100, angle = 20 );

module hinge (
	length,
	angle	= 0,
	center	= true,
	front	= true
) {
	difference () {
		rotate ( [ -90, 0, 0 ] ) {
			piano_hinge (
				angle			= angle,
				center			= center,
				length			= length,
				clearance		= eps,
				diameter		= Hinge_diameter, 
				knuckleLength	= Hinge_knuckleDepth,
				leafThickness	= Hinge_leafThickness,
				leafWidth		= Hinge_leafWidth,
				pinDiameter		= Hinge_pinDiameter
			);
		}

		if ( front ) {
			for ( m = [ [ 0, 0, 0 ], [ 1, 0, 0 ] ] ) {
				mirror ( m ) {
					translate ( [ 0, -length / 2 + TopPlate_edge, 0 ] ) {
						rotate ( [ 0, angle / 2, 0] ) rotate ( [ 0, 0, Halves_angles.z ] ) {
							translate ( -front_center_point ( zpos = TopPlate_position.z ) ) {

								// Subtract key cutout.
								linear_extrude ( height = Hinge_diameter + 2 * eps, center = true ) {
									fillet2d ( TopPlate_innerRadius ) {
										place_switches (
											connect = true,
											cutout	= 2 * TopPlate_edge,
											radius	= 0,
											size	= Key_spacing
										);
									}
								}
								
								// Subtract screw holes.
								place_screws ( thickness = 0 ) {
									cylinder ( d = Screw_diameter, h = Hinge_diameter + 4 * eps, center = true );
								}
							}
						}
					}
				}
			}
		}
	}
}