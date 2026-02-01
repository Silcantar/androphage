/*******************************************************************************\
|				Common sketch for Androphage keyboard plates.					|
|						Copyright 2026 Joshua Lucas 						    |
\*******************************************************************************/

use <../library/fillet.scad>
use <../library/path.scad>

module plate_sketch (
    plate_id,
    zpos = 0,
) {
    is_bottom   = ( plate_id == bottom );
    is_pcb      = ( plate_id == pcb );
    is_switch   = ( plate_id == switch );
    is_top      = ( plate_id == top );

    difference () {
        translate ( [ zpos * sin ( Halves_angles.y ) - Frame_extraLength, -SwitchPlate_edge, 0 ] ) {
            difference () {
                fillet2d ( radius = Plate_outerRadius ) {
                    offset ( delta = ( is_bottom || is_top ) ? Frame_lipDepth : 0 ) {
                        mirror ( [ 1, 1, 0 ] ) {
                            path_to_sketch ( Frame_path );
                        }
                    }
                }

                if ( is_switch ) {
                    place_key_holes() {
                        key_holes(
                            connect = is_top,
                            cutout = is_top ? Cluster_cutout : 0,
                        );

                        led_holes();
                    }
                }

                if ( is_top ) {
                    place_key_holes() {
                        fillet2d ( TopPlate_innerRadius ) {
                        key_holes(
                                connect = is_top,
                                cutout = is_top ? Cluster_cutout : 0,
                            );
                        }

                        led_holes();
                    }
                }
            }
        }

        translate ( [ -10, -10, 0 ] ) {
            square ( [ 10, 120 ] );
        }
    }
}

module plate (
    plate_id,
    zpos = 0,
) {
    linear_extrude ( height = SwitchPlate_thickness ) {
        plate_sketch (
            plate_id,
            zpos = zpos,
        );
    }
}

module led_holes () {
    translate ( LED_position ) {
        for ( i = [ 0 : LED_count - 1 ] ) {
            translate ( LED_holeSpacing * i ) {
                if ( LED_holeShape == "circle" ) {
                    circle ( d = LED_holeSize.x );
                } else {
                    square ( LED_holeSize, center = true );
                }
            }
        }
    }
}