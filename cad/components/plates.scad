/*******************************************************************************\
|				Common sketch for Androphage keyboard plates.					|
|						Copyright 2026 Joshua Lucas 						    |
\*******************************************************************************/

// include <../globals.scad>

// use <key_placement.scad>

use <../library/fillet.scad>
use <../library/path.scad>
use <../library/rainbow.scad>

// plates = object ( [
//     [ "bottom", 0 ],
//     [ "pcb",    1 ],
//     [ "switch", 2 ],
//     [ "top",    3 ],
// ] );

// function plates () = plates;

if ( is_undef ( ANDROPHAGE_MAIN ) ) {
    spacing = 2;

    for ( p = plates ) {
        translate ( [ 0, 0, plates[p] * spacing ] ) {
            rainbow ( plates[p] ) {
                plate ( plates[p], Cluster, Column, Frame, Key, LED, Plate, Switch );
            }
        }
    }
}

module plate_sketch (
    plate_id,
    // cluster,
    // column,
    // frame,
    // key,
    // led,
    // plate,
    // switch,
    zpos = 0,
) {
    is_bottom = ( plate_id == plates.bottom );
    is_pcb = ( plate_id == plates.pcb );
    is_switch = ( plate_id == plates.switch );
    is_top = ( plate_id == plates.top );

    difference () {
        fillet2d ( radius = Plate.outerRadius ) {
            offset ( delta = ( is_bottom || is_top ) ? Plate.Top.edge : Plate.Switch.edge ) {
                mirror ( [ 1, 1, 0 ] ) {
                    path_to_sketch ( Frame.path );
                }
            }
        }

        translate ( [ -10, -10, 0 ] ) {
            #square ( [ 10, 120 ] );
        }

        if ( is_switch ) {
            place_key_holes() {
                key_holes(
                    connect = is_top,
                    cutout = is_top ? Cluster.cutout : 0,
                );

                led_holes();
            }
        }

        if ( is_top ) {
            place_key_holes() {
                fillet2d ( Plate.Top.innerRadius ) {
                    key_holes(
                        connect = is_top,
                        cutout = is_top ? cluster.cutout : 0,
                    );
                }

                led_holes();
            }
        }
    }
}

module plate (
    plate_id,
    // cluster,
    // column,
    // frame,
    // key,
    // led,
    // plate,
    // switch,
    zpos = 0,
) {
    linear_extrude ( height = Plate.Switch.thickness ) {
        plate_sketch (
            plate_id,
            // cluster,
            // column,
            // frame,
            // key,
            // led,
            // plate,
            // switch,
            zpos = 0,
        );
    }
}

module led_holes (
    // led,
) {
    translate ( LED.position ) {
        for ( i = [ 0 : LED.count - 1 ] ) {
            translate ( LED.holeSpacing * i ) {
                if ( LED.shape == "circle" ) {
                    circle ( d = LED.holeSize.x );
                } else {
                    square ( LED.holeSize, center = true );
                }
            }
        }
    }
}