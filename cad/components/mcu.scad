/*******************************************************************************\
|					Microcontroller Unit for Androphage keyboard.				|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../globals.scad>

include <../color.scad>

use <../library/fillet.scad>

if ( is_undef ( $parent_modules ) ) {
	include <../androphage.scad>

	mcu ( MCU );
}

module mcu ( 
	mcu,
	// chipSize	= MCU_chipSize,
	// size		= MCU_size,
	// radius		= MCU_radius,
	// usbOverhang	= MCU_usbOverhang,
	// usbRadius	= MCU_usbRadius,
	// usbSize		= MCU_usbSize,
	// pcbColor	= MCU_pcbColor
) {
	color ( Color.steel ) {
		translate ( [
			0, 
			mcu.size.y / 2 + mcu.usbOverhang, 
			mcu.size.z + mcu.usbSize.z / 2 
		] ) {
			// USB Port
			rotate ( [ 90, 0, 0 ]) {
				linear_extrude ( h = mcu.usbSize.y ) {
					fillet2d ( radius = mcu.usbRadius ) {
						square ( [ mcu.usbSize.x, mcu.usbSize.z ], center = true );
					}
				}
			}
		}

		// Chip housing, or whatever that is.
		translate ( [ 0, -1, mcu.size.z + mcu.chipSize.z / 2 ] )
		cube ( [ 12, 10, 1.5 ], center = true );
	}

	difference () {
		union () {
			// PCB
			color ( mcu.pcbColor ) {
				linear_extrude ( h = mcu.size.z ) {
					fillet2d ( radius = mcu.radius ) {
						square ( [ mcu.size.x, mcu.size.y ], center = true );
					}
				}
			}

			// Pads
			color ( "Gold" ) {
				for ( i = [ 0 : 6 ], j = [ [ 0, 0, 0 ], [ 1, 0, 0 ] ] ) {
					mirror ( j ){
						translate ( mcu.size / 2 + [ -0.75, -2.8 - 2.54 * i, 0 ] ) {
							cube ( [ 1.5 + eps, 2, mcu.size.z + 2 * eps ], center = true );
							translate ( [ -0.75, 0, 0 ] ) {
								cylinder ( d = 2, h = mcu.size.z + 2 * eps, center = true );
							}
						}
					}
				}
			}
		}

		// Through holes and castellations
		for ( i = [ 0 : 6 ], j = [ [ 0, 0, 0 ], [ 1, 0, 0 ] ] ) {
			mirror ( j ){
				translate ( mcu.size / 2 + [ 0, -2.8 - 2.54 * i, 0 ] ) {
					cylinder ( d = 1, h = mcu.size.z + 4 * eps, center = true );
					translate ( [ -1.5, 0, 0 ] ) {
						cylinder ( d = 1, h = mcu.size.z + 4 * eps, center = true );
					}
				}
			}
		}
	}
}