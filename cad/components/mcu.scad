/*******************************************************************************\
|					Microcontroller Unit for Androphage keyboard.				|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../library/fillet.scad>

if ( is_undef ( ANDROPHAGE_MAIN ) ) {
    mcu ( MCU );
}

module mcu (
    // mcu,
    // chipSize	= MCU_chipSize,
    // size		= MCU_size,
    // radius		= MCU_radius,
    // usbOverhang	= MCU_usbOverhang,
    // usbRadius	= MCU_usbRadius,
    // usbSize		= MCU_usbSize,
    // pcbColor	= MCU_pcbColor
) {
    color ( Color_steel ) {
        translate ( [
            0,
            MCU_size.y / 2 + MCU_usbOverhang,
            MCU_size.z + MCU_usbSize.z / 2
        ] ) {
            // USB Port
            rotate ( [ 90, 0, 0 ]) {
                linear_extrude ( h = MCU_usbSize.y ) {
                    fillet2d ( radius = MCU_usbRadius ) {
                        square ( [ MCU_usbSize.x, MCU_usbSize.z ], center = true );
                    }
                }
            }
        }

        // Chip housing, or whatever that is.
        translate ( [ 0, -1, MCU_size.z + MCU_chipSize.z / 2 ] )
        cube ( [ 12, 10, 1.5 ], center = true );
    }

    difference () {
        union () {
            // PCB
            color ( MCU_pcbColor ) {
                linear_extrude ( h = MCU_size.z ) {
                    fillet2d ( radius = MCU_radius ) {
                        square ( [ MCU_size.x, MCU_size.y ], center = true );
                    }
                }
            }

            // Pads
            color ( "Gold" ) {
                for ( i = [ 0 : 6 ], j = [ [ 0, 0, 0 ], [ 1, 0, 0 ] ] ) {
                    mirror ( j ){
                        translate ( MCU_size / 2 + [ -0.75, -2.8 - 2.54 * i, 0 ] ) {
                            cube ( [ 1.5 + $eps, 2, MCU_size.z + 2 * $eps ], center = true );
                            translate ( [ -0.75, 0, 0 ] ) {
                                cylinder ( d = 2, h = MCU_size.z + 2 * $eps, center = true );
                            }
                        }
                    }
                }
            }
        }

        // Through holes and castellations
        for ( i = [ 0 : 6 ], j = [ [ 0, 0, 0 ], [ 1, 0, 0 ] ] ) {
            mirror ( j ){
                translate ( MCU_size / 2 + [ 0, -2.8 - 2.54 * i, 0 ] ) {
                    cylinder ( d = 1, h = MCU_size.z + 4 * $eps, center = true );
                    translate ( [ -1.5, 0, 0 ] ) {
                        cylinder ( d = 1, h = MCU_size.z + 4 * $eps, center = true );
                    }
                }
            }
        }
    }
}