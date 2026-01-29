/*******************************************************************************\
|				Place keys and switches for Androphage keyboard.				|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/


// use <choc_switch.scad>

use <key_placement.scad>

module keys () {
    key_pos = key_positions();

    // place_plate () {
        for ( i = [ 0 : len ( key_pos ) - 1 ] ) {
            let ( p = key_pos[i] ) {
                translate ( [ p.x, p.y, 0 ] ){
                    rotate ( p[2][0] ) {
                        if ( Switch.visible ) {
                            translate ( [ 0, 0, Switch.position.z ] ) {
                                if ( Switch_type == switch_chocv1 || Switch_type == switch_chocv2 ){
                                    choc_switch ( travel = Switch.travel );
                                }

                                if ( Switch.type == switch_glp ) {
                                    color ( Switch.GLP.color ) {
                                        translate ( [ 60, 0, 3.2 ] ) {
                                            import ("../stl/gateron_ks-33.stl");
                                        }
                                    }
                                }
                            }
                        }
                        if ( Keycap.visible ) {
                            rotate ( Keycap.style[i][1] * 180 ){
                                translate ( [ 0, 0, Keycap.position.z ] ) {
                                    color ( Keycap_style[i][2] ) {
                                        import ( str ( "../", Keycap.path, Keycap.style[i][0], ".stl" ) );
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    // }
}