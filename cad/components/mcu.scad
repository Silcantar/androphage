/*******************************************************************************\
|					Microcontroller Unit for Androphage keyboard.				|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

mcu();

module mcu ( 
	chipSize	= MCU_chipSize,
	size		= MCU_size,
	radius		= MCU_radius,
	usbOverhang	= MCU_usbOverhang,
	usbRadius	= MCU_usbRadius,
	usbSize		= MCU_usbSize,
	pcbColor	= MCU_pcbColor
) {
	color ( Color_steel ) {
		translate ( [
			0, 
			size.y / 2 + usbOverhang, 
			size.z + usbSize.z / 2 
		] ) {
			// USB Port
			rotate ( [ 90, 0, 0 ]) {
				linear_extrude ( h = usbSize.y ) {
					fillet2d ( radius = usbRadius ) {
						square ( [ usbSize.x, usbSize.z ], center = true );
					}
				}
			}
		}

		// Chip housing, or whatever that is.
		translate ( [ 0, -1, size.z + chipSize.z / 2 ] )
		cube ( [ 12, 10, 1.5 ], center = true );
	}

	difference () {
		union () {
			// PCB
			color ( pcbColor ) {
				linear_extrude ( h = size.z ) {
					fillet2d ( radius = radius ) {
						square ( [ size.x, size.y ], center = true );
					}
				}
			}

			// Pads
			color ( "Gold" ) {
				for ( i = [ 0 : 6 ], j = [ [ 0, 0, 0 ], [ 1, 0, 0 ] ] ) {
					mirror ( j ){
						translate ( size / 2 + [ -0.75, -2.8 - 2.54 * i, 0 ] ) {
							cube ( [ 1.5 + eps, 2, size.z + 2 * eps ], center = true );
							translate ( [ -0.75, 0, 0 ] ) {
								cylinder ( d = 2, h = size.z + 2 * eps, center = true );
							}
						}
					}
				}
			}
		}

		// Through holes and castellations
		for ( i = [ 0 : 6 ], j = [ [ 0, 0, 0 ], [ 1, 0, 0 ] ] ) {
			mirror ( j ){
				translate ( size / 2 + [ 0, -2.8 - 2.54 * i, 0 ] ) {
					cylinder ( d = 1, h = size.z + 4 * eps, center = true );
					translate ( [ -1.5, 0, 0 ] ) {
						cylinder ( d = 1, h = size.z + 4 * eps, center = true );
					}
				}
			}
		}
	}
}