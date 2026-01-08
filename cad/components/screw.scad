/*******************************************************************************\
|					Simple screw models for Androphage keyboard.				|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

// Test
screw (
	diameter	= 2,
	length		= 10,
	head		= head_flat,
	drive		= drive_hex,
);

// Head type enum
head_none	= "none";
head_flat	= "flat";
head_round	= "round";
head_socket	= "socket";

function _head_height_multiplier ( head_type ) = dictionary (
	[
		[ head_none,	0		],
		[ head_flat,	0		],
		[ head_round,	0.75	],
		[ head_socket,	1		],
	],
	head_type
);

// Drive type enum
drive_none	= "none";
drive_hex	= "hex";
drive_slot	= "slot";
drive_phil	= "phillips";

function _drive_hex_size ( diameter ) = dictionary (
	[
		[ 2,	1.3	],
		[ 2.5,	1.5	],
		[ 3,	2	],
	],
	diameter
);

module screw (
	diameter,
	length,
	chamfer,
	drive	= drive_none,
	head	= head_none,
) {
	chamfer = is_undef ( chamfer ) ? diameter / 10 : chamfer;
	head_height = diameter * _head_height_multiplier ( head );

	rotate ( [ 180, 0, 0 ] ) {
		difference (){
			union () {
				shaft_length = length - 2 * chamfer;

				translate ( [ 0, 0, length / 2 ] ) {
					cylinder (
						d = diameter,
						h = shaft_length,
						center = true
					);

					for ( angle = [ 0, 180 ] ) {
						rotate ( [ angle, 0, 0 ] ) {
							translate ( [ 0, 0, shaft_length / 2 ] ) {
								cylinder ( d1 = diameter, d2 = diameter - 2 * chamfer, h = chamfer);
							}
						}
					}
				}

				if ( head == head_flat ) {
					_head_flat ( chamfer, diameter, drive );
				}
				if ( head == head_round ) {
					_head_round ( chamfer, diameter, drive );
				}
			}

			if ( drive == drive_hex ) {
				_drive_hex ( diameter, head_height );
			}
			if ( drive == drive_slot ) {
				_drive_slot ( diameter, head_height );
			}
		}
	}
}

module _head_flat (
	chamfer,
	diameter,
	drive,
) {
	difference () {
		union () {
			translate ( [ 0, 0, chamfer ] ) {
				cylinder (
					d1 = 2 * diameter,
					d2 = diameter,
					h = diameter / 2
				);
			}

			cylinder (
				d = 2 * diameter,
				h = chamfer + eps
			);
		}
	}
}

module _head_round ( chamfer, diameter, drive ) {
	cylinder ( d = diameter, h = chamfer + eps );

	difference () {
		sphere ( d = 1.5 * diameter );

		translate ( -1.5 * diameter * [ 1, 1, 0 ] ) {
			cube ( 3 * diameter );
		}
	}
}

module _drive_hex ( diameter, head_height ) {
	drive_size_lookup = _drive_hex_size ( diameter );
	drive_size = is_undef ( drive_size_lookup ) ? 0.65 * diameter : drive_size_lookup;

	unit_hexagon = [
		[ 0,		1 			],
		[ cos(30),	sin(30)		],
		[ cos(30),	-sin(30)	],
		[ 0,		-1			],
		[ -cos(30),	-sin(30)	],
		[ -cos(30), sin(30)		]
	] / 2 / cos(30);

	translate ( [ 0, 0, -head_height - eps ] ) {
		linear_extrude ( h = drive_size + eps ) {
			polygon ( drive_size * unit_hexagon );
		}
	}
}

module _drive_slot ( diameter, head_height ) {
	translate ( [ 0, 0, -head_height ] ) {
		cube ( [ diameter * 4, diameter / 5, diameter ], center = true );
	}
}