/*******************************************************************************\
|				Place keys and switches for Androphage keyboard.				|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../library/choc_switch.scad>
use <../library/gateron_ks-33.scad>

use <key_placement.scad>

module keys () {
    // key_pos = key_positions();

    // // place_plate () {
    //     for ( i = [ 0 : len ( key_pos ) - 1 ] ) {
    //         let ( p = key_pos[i] ) {
    //             translate ( [ p.x, p.y, 0 ] ){
    //                 rotate ( p[2][0] ) {
    //                     if ( Switch_visible ) {
    //                         translate ( [ 0, 0, Switch_position.z ] ) {
    //                             if ( Switch_type == switch_chocv1 || Switch_type == switch_chocv2 ){
    //                                 choc_switch ( travel = Switch_travel );
    //                             }

    //                             if ( Switch_type == switch_glp ) {
    //                                 color ( Switch_GLP_color ) {
    //                                     translate ( [ 60, 0, 3.2 ] ) {
    //                                         import ("../stl/gateron_ks-33.stl");
    //                                     }
    //                                 }
    //                             }
    //                         }
    //                     }
    //                     if ( Keycap_visible ) {
    //                         rotate ( Keycap_style[i][1] * 180 ){
    //                             translate ( [ 0, 0, Keycap_position.z ] ) {
    //                                 color ( Keycap_style[i][2] ) {
    //                                     import ( str ( "../", Keycap_path, Keycap_style[i][0], ".stl" ) );
    //                                 }
    //                             }
    //                         }
    //                     }
    //                 }
    //             }
    //         }
    //     }
    // // }
}