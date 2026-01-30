/*******************************************************************************\
|						Top plate for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <plates_common.scad>

use <../library/screw.scad>

top_plate();

module top_plate (
    clearance	= Hinge_diameter / 2,
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
                clearance,
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
    clearance,
    edge,
    innerRadius,
    outerRadius,
    spacing,
    zpos
) {
    difference () {
        // Main body.
        plate_sketch (
            clearance	= clearance,
            edge		= edge,
            radius		= outerRadius,
            zpos		= zpos
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

        // translate (
        // 	_front_arc_inner_end()
        // 	+ TopPlate_edge * [
        // 		sin ( inner_thumb_key_angle() ),
        // 		-cos ( inner_thumb_key_angle() )
        // 	]
        // 	+ Key_spacing.x / 2 * [
        // 		-cos ( inner_thumb_key_angle() ),
        // 		-sin ( inner_thumb_key_angle() )
        // 	]
        // ) {
        // 	rotate ( inner_thumb_key_angle() - 90 ) {
        // 		fillet_cutter2d ( innerRadius );
        // 	}
        // }

        // translate (
        // 	_front_middle_point() + [
        // 		Key_spacing.x / 2,
        // 		-TopPlate_edge
        // 	]
        // ) {
        // 	rotate ( 180 ) {
        // 		fillet_cutter2d ( innerRadius );
        // 	}
        // }

        // Subtract LED holes.
        if ( LED_present ) {
            place_led_holes ( shape = LED_holeShape );
        }

        // Place circles at the screw holes for when the sketch is used for
        // production (e_g. laser cutting).
        place_screws ( thickness = 0 ) {
            circle ( d = Screw_diameter );
        }
    }
}

module place_led_holes (
    led,
) {
    translate ( led_position ) {
        for ( i = [ 0 : led_count - 1 ] ) {
            translate ( led_holeSpacing * i ) {
                if ( led_shape == "circle" ) {
                    circle ( d = led_holeSize.x );
                } else {
                    square ( led_holeSize, center = true );
                }
            }
        }
    }
}