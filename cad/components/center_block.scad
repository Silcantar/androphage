/*******************************************************************************\
|						Center block for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <../import_bosl.scad>

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

		_btus ();

		_plates ();

		_sensor();

		_trackball();
	}
}

/*******************************************************************************\
|								Additive Features								|
\*******************************************************************************/

module _center_wall (
	centerBlock_height			= CenterBlock_height,
	centerBlock_wallThickness	= CenterBlock_wallThickness,
	hinge_length				= Hinge_length,
	topPlate_edge				= TopPlate_edge
) {
	translate ( [ 0, -topPlate_edge ] ) {
		cube ( [
			centerBlock_wallThickness,
			hinge_length + 2 * topPlate_edge,
			centerBlock_height
		] );
	}
}

module _sensor_holder(
	centerBlock_wallThickness			= CenterBlock_wallThickness,
	trackball_diameter					= Trackball_diameter,
	trackball_position					= Trackball_position,
	trackball_sensor_angle				= Trackball_Sensor_angle,
	trackball_sensor_clearance			= Trackball_Sensor_clearance,
	trackball_sensor_holderHeight		= Trackball_Sensor_holderHeight,
	trackball_sensor_holderThickness	= Trackball_Sensor_holderThickness,
	trackball_sensor_lensSize			= Trackball_Sensor_lensSize,
	trackball_sensor_opticalCenter		= Trackball_Sensor_opticalCenter,
	trackball_sensor_pcbSize			= Trackball_Sensor_pcbSize
) {
	hblock_size = [
		trackball_sensor_holderThickness,
		trackball_sensor_pcbSize.y + centerBlock_wallThickness,
		trackball_sensor_holderHeight
	];

	vblock_size = [
		trackball_sensor_pcbSize.x + centerBlock_wallThickness,
		trackball_sensor_holderThickness,
		trackball_sensor_holderHeight
	];

	rot_offset = (
		- trackball_sensor_holderHeight / 2
		+ trackball_diameter / 2
		+ trackball_sensor_clearance
		+ trackball_sensor_lensSize.z
		+ trackball_sensor_pcbSize.z
	);

	translate ( trackball_position ) {
		rotate ( [ 0, 180 - trackball_sensor_angle, 0 ] ) {
			translate (
				v_mul(
					(
						trackball_sensor_pcbSize / 2
						- trackball_sensor_opticalCenter
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

module _trackball_case (
	centerBlock_wallThickness	= CenterBlock_wallThickness,
	halves_angles				= Halves_angles,
	trackball_clearance			= Trackball_clearance,
	trackball_diameter			= Trackball_diameter,
	trackball_position			= Trackball_position
) {
	d = (
		trackball_diameter
		+ 2 * (
			trackball_clearance
			+ centerBlock_wallThickness
		)
	);

	translate ( trackball_position ) {
		rotate ( [ 90, 0, 0 ] ) { rotate ( [ 0, 0, -90 ] ) {
			rotate_extrude ( angle = 90 - halves_angles.y ) {
				difference () {
					circle ( d = d );

					translate ( [ -d, -d / 2, 0 ] ) {
						square ( d + 2 * eps );
					}
				}
			}
		} }
	}
}

/*******************************************************************************\
|								Subtractive Features							|
\*******************************************************************************/

module _btus (
	trackball_diameter	= Trackball_diameter,
	trackball_position	= Trackball_position
) {
	translate ( trackball_position ) {
		// BTUs
		for ( zrot = [ -45, -135 ] ) {
			rotate ( [ 45, 0, zrot ] ) {
				translate ( [ 0, 0, -trackball_diameter / 2 ] ) {
					btu ( include_cut = true );
				}
			}
		}
	}
}

module _plates (
	halves_angles			= Halves_angles,
	centerBlock_height		= CenterBlock_height,
	bottomPlate_thickness	= BottomPlate_thickness
) {
	side = 200;
	zpos1 = [ centerBlock_height, bottomPlate_thickness ];
	zpos2 = [ 0, -side ];
	for ( i = [ 0 : 1 ] ) {
		translate ( [ 0, -side / 2, zpos1[i] ] ) {
			rotate ( [ 0, halves_angles.y, 0 ] ) {
				translate ( [ 0, 0, zpos2[i] ] ) {
					cube ( side );
				}
			}
		}
	}
}

module _sensor (
	trackball_sensor_angle	= Trackball_Sensor_angle,
	trackball_diameter		= Trackball_diameter,
	trackball_position		= Trackball_position
) {
	translate ( trackball_position ) {

		// Trackball sensor board
		rotate ( [ 0, 180 - trackball_sensor_angle, 0 ] ) {
			translate ( [ 0, 0, trackball_diameter / 2 ] ) {
				trackball_sensor ( include_cut = true );
			}
		}
	}
}

module _trackball (
	trackball_clearance	= Trackball_clearance,
	trackball_diameter	= Trackball_diameter,
	trackball_position	= Trackball_position
) {
	translate ( trackball_position ) {
		// Subtract Trackball + clearance.
		sphere ( d = (
			trackball_diameter
			+ 2 * trackball_clearance
		) );
	}
}