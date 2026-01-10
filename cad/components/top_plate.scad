/*******************************************************************************\
|						Top plate for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <plates_common.scad>

top_plate( zpos = 0 );

module top_plate (
	edge		= TopPlate_edge,
	innerRadius	= TopPlate_innerRadius,
	outerRadius = Plate_outerRadius,
	spacing		= Key_spacing,
	thickness	= TopPlate_thickness,
	zpos		= CenterBlock_height,
) {
	difference () {
		place_plate ( zpos ) {
			difference () {
				// Main body.
				plates_common (
					thickness = thickness,
					edge	= edge,
					radius	= outerRadius,
					zpos	= zpos,
				);

				// Subtract trackball cutout.
				translate ( [ 0, 0, -eps ] ) {
					place_trackball (
						thickness = thickness + 2 * eps,
						zpos = zpos,
					);

					// Subtract key cutout.
					linear_extrude ( h = thickness + 2 * eps ){
						fillet2d ( innerRadius ) {
							place_switches (
								connect = true,
								cutout	= 2 * edge,
								radius	= 0,
								size	= spacing,
							);
						}

						if ( LED_present ) {
							place_led_holes ( shape = LED_holeShape );
						}
					}
				}

				place_screws (
					thickness	= thickness,
					zpos		= zpos,
				);
			}
		}
	}
}