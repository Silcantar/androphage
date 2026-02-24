/*******************************************************************************\
|				Place keys and switches for Androphage keyboard.				|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../library/cherrymx.scad>
use <../library/choc_switch.scad>
use <../library/gateron_ks33.scad>
use <../keycaps/keycap.scad>

// Switches are slightly misaligned in the y direction for reasons I cannot
// determine. This is a kludge to fix that.
fudge_factor = 0.6;

module keys () {
    key_pos = key_positions();

    place_key_holes () {
        for ( i = [ 0 : len ( key_pos ) - 1 ] ) {
            let ( p = key_pos[i] )
            translate (
                p.position
                + [
                    PCB_position.z * sin ( Halves_angles.y ) - Frame_extraLength,
                    -SwitchPlate_edge + fudge_factor,
                    0
                ]
            ) {
                rotate ( p.angle ) {

                    // Place switches.
                    if ( Switch_visible ) {
                        if ( Switch_type == switch_glp ) {
                            ks33 ( color = Switch_glpColor );
                        }
                        if ( Switch_type == switch_chocv1 || Switch_type == switch_chocv2 ) {
                            translate ( [ 0, 0, -2 ] ) {
                                choc_switch ();
                            }
                        }
                        if ( Switch_type == switch_mx ) {
                            translate ( [ 0, 0, 13 ] ) {
                                CherryMX (
                                    Switch_mxStemColor,
                                    Switch_mxTopColor,
                                    Switch_mxBottomColor
                                );
                            }
                        }
                    }

                    if ( Keycap_visible ) {
                        translate ( Keycap_position - [ 0, 0, 3.4 ] ) {
                            color ( Keycap_styles[i][2] ) {
                                keycap ();
                            }
                        }
                    }
                }
            }
        }
    }
}