/*******************************************************************************\
|						Top plate for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

// include <../>

use <plates_common.scad>

use <../library/screw.scad>

top_plate();

module top_plate (
	edge		= TopPlate_edge,
	innerRadius	= TopPlate_innerRadius,
	outerRadius = Plate_outerRadius,
	spacing		= Key_spacing,
	thickness	= TopPlate_thickness,
	zpos		= CenterBlock_height
) {
	difference () {
		linear_extrude ( height = thickness, convexity = 2 ) {
			_top_plate_sketch (
				edge,
				innerRadius,
				outerRadius,
				spacing,
				zpos
			);
		}

		// Subtract coutersunk screw holes for rendering / CNC milling.
		place_screws (
			thickness	= thickness
		) {
			screw (
				diameter	= Screw_diameter,
				length		= 2,
				head		= "flat",
				drive		= "none"
			);
		}
	}
}

module _top_plate_sketch (
	edge,
	innerRadius,
	outerRadius,
	spacing,
	zpos
) {
	difference () {
		// Main body.
		plate_sketch (
			edge	= edge,
			radius	= outerRadius,
			zpos	= zpos
		);

		// Subtract trackball cutout.
		place_trackball (
			zpos = zpos
		);

		// Subtract key cutout.
		fillet2d ( innerRadius ) {
			place_switches (
				connect = true,
				cutout	= 2 * edge,
				radius	= 0,
				size	= spacing
			);
		}

		// Subtract LED holes.
		if ( LED_present ) {
			place_led_holes ( shape = LED_holeShape );
		}

		// Place circles at the screw holes for when the sketch is used for
		// production (e.g. laser cutting).
		place_screws ( thickness = 0 ) {
			circle ( d = Screw_diameter );
		}
	}
}