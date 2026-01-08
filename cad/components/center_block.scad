/*******************************************************************************\
|						Center block for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <../import/vectors.scad>

use <trackball_sensor.scad>

use <trackball.scad>

use <btu.scad>

use <magnetic_connector.scad>

// Test
center_block ();

module center_block () {
	difference () {
		// Main Body
		union () {
			_center_wall();

			_sensor_holder();

			_trackball_case();

			_screw_boss();
		}

		_btus();

		translate ( [ 0, 0, 0 ] ) {
			#_insert_holes();
		}

		translate ( MagCon_position ) {
			magnetic_connector ( include_cut = true );
		}

		_plates();

		_sensor();

		_trackball();
	}
}

/*******************************************************************************\
|								Additive Features								|
\*******************************************************************************/

module _center_wall (
	centerBlock_height			= CenterBlock_height,
	centerBlock_ribSize			= CenterBlock_ribSize,
	centerBlock_wallThickness	= CenterBlock_wallThickness,
	hinge_length				= Hinge_length,
	topPlate_edge				= TopPlate_edge,
	bottomPlate_thickness		= BottomPlate_thickness,
	halves_angles				= Halves_angles
) {
	translate ( [ 0, -topPlate_edge ] ) {
		difference () {
			// Main body
			cube ( [
				centerBlock_wallThickness + centerBlock_ribSize.y,
				hinge_length + 2 * topPlate_edge,
				centerBlock_height
			] );

			// Subtract the part that is not the ribs.
			translate ( [ 
				centerBlock_wallThickness,
				centerBlock_ribSize.x,
				bottomPlate_thickness + centerBlock_ribSize.x - centerBlock_wallThickness * sin ( halves_angles.y )
			] ) {
				cube ( [
					centerBlock_ribSize.y + eps,
					hinge_length + 2 * topPlate_edge - 2 * centerBlock_ribSize.x,
					centerBlock_height - bottomPlate_thickness - 2 * centerBlock_ribSize.x
				] );
			}
		}
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
	trackball_sensor_pcbSize			= Trackball_Sensor_pcbSize,
	vblock_extra						= 10
) {
	hblock_size = [
		trackball_sensor_holderThickness,
		trackball_sensor_pcbSize.y + centerBlock_wallThickness,
		trackball_sensor_holderHeight
	];

	vblock_size = [
		trackball_sensor_pcbSize.x + centerBlock_wallThickness + vblock_extra,
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
				translate ( [ vblock_extra / 2, 0, 0] ) {
					cube ( vblock_size, center = true );
				}
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
			// Extruding 90 degrees is fine because we're going to cut this 
			// feature using the _plates feature anyway and extruding the 
			// proper angle causes z-fighting.
			rotate_extrude ( angle = 90 ) {
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
	trackball_position	= Trackball_position,
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

module _insert_holes ( 
	bottomPlate_thickness	= BottomPlate_thickness,
	centerBlock_height		= CenterBlock_height,
	halves_angles			= Halves_angles,
	insert_holeDepth		= Insert_holeDepth,
	insert_holeDiameter		= Insert_holeDiameter,
	insert_wallThickness	= Insert_wallThickness,
) {
	translate ( [ insert_holeDiameter / 1 + insert_wallThickness, 0, 0 ] ){
		rotate ( [ 0, halves_angles.y, 0 ] ) {
			for ( zpos = [ 
				bottomPlate_thickness, 
				centerBlock_height - insert_holeDepth,
			] ){
				translate ( [ 
					0, 
					0, 
					zpos 
				] ) {
					cylinder ( d = insert_holeDiameter, h = insert_holeDepth );
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
				translate ( [ -side / 2, 0, zpos2[i] ] ) {
					cube ( side );
				}
			}
		}
	}
}

module _screw_boss (
	centerBlock_height			= CenterBlock_height,
	centerBlock_wallThickness	= CenterBlock_wallThickness,
	halves_angles				= Halves_angles,
	insert_holeDiameter			= Insert_holeDiameter,
	insert_wallThickness		= Insert_wallThickness
) {
	d = insert_holeDiameter + 2 * insert_wallThickness;
	h = 2 * centerBlock_height;

	translate ( [ d / 2, 0, 0 ] ) {
		rotate ( [ 0, -halves_angles.y, 180 ] ) {
			cylinder ( d = d, h = h );

			translate ( [ 0, -d / 2, 0 ] ) {
				cube ( [ d, d, h ] );
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