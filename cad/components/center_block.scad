/*******************************************************************************\
|						Center block for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <../import_bosl.scad>

use <../androphage.scad>

use <trackball_sensor.scad>

use <trackball.scad>

use <btu.scad>

// Test
center_block();

module center_block() {

	difference () {
		// Main Body
		union () {
			_center_wall();

			_sensor_holder();

			_trackball_case();
		}

		#_btus();

		_plates ();

		_sensor();

		_trackball();
	}
}

/*******************************************************************************\
|								Additive Features								|
\*******************************************************************************/

module _center_wall() {
	translate ( [ 0, -TopPlate_edge() ] ) {
		cube ( [
			CenterBlock_wallThickness(),
			Hinge_length() + 2 * TopPlate_edge(),
			CenterBlock_height()
		] );
	}
}

module _sensor_holder() {
	height = 15;

	width = 5;

	hblock_size = [
		width,
		Trackball_Sensor_PCBsize().y + CenterBlock_wallThickness(),
		height
	];

	vblock_size = [
		Trackball_Sensor_PCBsize().x + CenterBlock_wallThickness(),
		width,
		height
	];

	rot_offset = (
		-height / 2
		+ Trackball_diameter() / 2
		+ Trackball_Sensor_clearance()
		+ Trackball_Sensor_lensSize().z
		+ Trackball_Sensor_PCBsize().z
	);

	translate ( Trackball_position() ) {
		rotate ( [ 0, 180 - Trackball_Sensor_angle(), 0 ] ) {
			translate (
				v_mul(
					(
						Trackball_Sensor_PCBsize() / 2
						- Trackball_Sensor_opticalCenter()
					),
					[1, 1, 0]
				) +
				[ 0, 0, rot_offset ]
			) {
				cube ( hblock_size, center = true );
				cube ( vblock_size, center = true );
			}
		}
	}
}

module _trackball_case() {
	diameter = (
		Trackball_diameter()
		+ 2 * (
			Trackball_clearance()
			+ CenterBlock_wallThickness()
		)
	);

	translate ( Trackball_position() ) {
		rotate ( [ 90, 0, 0 ] ) { rotate ( [ 0, 0, -90 ] ) {
			rotate_extrude ( angle = 90 - Halves_angles().y ) {
				difference () {
					circle ( d = diameter );

					translate ( [ -diameter, -diameter / 2, 0 ] ) {
						square ( diameter + 2 * eps );
					}
				}
			}
		} }
	}
}

/*******************************************************************************\
|								Subtractive Features							|
\*******************************************************************************/

module _btus ( ) {
	translate ( Trackball_position() ) {
		// BTUs
		for ( zrot = [ -45, -135 ] ) {
			rotate ( [ 45, 0, zrot ] ) {
				translate ( [ 0, 0, -Trackball_diameter() / 2 ] ) {
					btu ( include_cut = true );
				}
			}
		}
	}
}

module _plates ( ) {
	side = 200;
	zpos1 = [ CenterBlock_height(), BottomPlate_thickness() ];
	zpos2 = [ 0, -side ];
	for ( i = [ 0 : 1 ] ) {
		translate ( [ 0, -side / 2, zpos1[i] ] ) {
			rotate ( [ 0, Halves_angles().y, 0 ] ) {
				translate ( [ 0, 0, zpos2[i] ] ) {
					cube ( side );
				}
			}
		}
	}
}

module _sensor ( ) {
	translate ( Trackball_position() ) {

		// Trackball sensor board
		rotate ( [ 0, 180 - Trackball_Sensor_angle(), 0 ] ) {
			translate ( [ 0, 0, Trackball_diameter() / 2 ] ) {
				trackball_sensor ( include_cut = true );
			}
		}
	}
}

module _trackball ( ) {
	translate ( Trackball_position() ) {
		// Subtract Trackball + clearance.
		sphere ( d = (
			Trackball_diameter()
			+ 2 * Trackball_clearance()
		) );
	}
}