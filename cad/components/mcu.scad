/*******************************************************************************\
|					Microcontroller Unit for Androphage keyboard.				|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../library/fillet.scad>

module mcu (
    include_cut = false,
) {
    color ( Color_steel ) {
        usb_connector();

        // Chip housing, or whatever that is.
        translate ( [ 0, -1, MCU_size.z + MCU_chipSize.z / 2 ] )
        cube ( [ 12, 10, 1.5 ], center = true );
    }

    difference () {
        union () {
            mcu_pcb();

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

    // Cut for USB port clearance
    if ( include_cut ) {
        color ( Color_cut ) {
            scale ( [ 0.75, 1, 4 ] ) {
                mcu_pcb();
            }

            translate ( [ 0, 1.5 + $eps, 0 ] ) {
                usb_connector (
                    size = MCU_usbSize + [ 1, 0, 1 ],
                    radius = MCU_usbRadius + 0.5
                );
            }

            translate ( [ 0, 11.5, 0 ] ) {
                usb_connector (
                    size = MCU_usbCutSize,
                    radius = MCU_usbRadius * 2
                );
            }
        }
    }
}

module mcu_pcb () {
    // PCB
    color ( MCU_pcbColor ) {
        linear_extrude ( h = MCU_size.z ) {
            fillet2d ( radius = MCU_radius ) {
                square ( [ MCU_size.x, MCU_size.y ], center = true );
            }
        }
    }
}

// USB Port
module usb_connector (
    size = MCU_usbSize,
    radius = MCU_usbRadius,
 ) {
    translate ( [
        0,
        MCU_size.y / 2 + MCU_usbOverhang,
        MCU_size.z + MCU_usbSize.z / 2
    ] ) {
        rotate ( [ 90, 0, 0 ]) {
            linear_extrude ( h = size.y ) {
                fillet2d ( radius = radius ) {
                    square ( [ size.x, size.z ], center = true );
                }
            }
        }
    }
}