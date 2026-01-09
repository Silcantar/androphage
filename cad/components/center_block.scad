/*******************************************************************************\
|						Center block for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

// include <../BOSL2/std.scad>
// include <../BOSL2/vectors.scad>

use <trackball_sensor.scad>

use <trackball.scad>

use <btu.scad>

use <magnetic_connector.scad>

// Test
rotate ( [ 0, -90, 0 ] )
center_block ( test = false );

module center_block ( test = false ) {
	// Put a cube with a corner at the origin so we can measure from it.
	if ( test ) {
		cube ();
	}

	difference () {
		// Main Body
		union () {
			if ( test ){
				#_center_wall();
			} else {
				_center_wall();
			}

			_pcb_shelf ();

			_sensor_holder();

			for ( i = [ 0 : CenterBlock_screwCount - 1 ] ) {
				translate ( Screw_positions[i] ) {
					if ( test ) {
						#_screw_boss();
					} else {
						_screw_boss();
					}
				}
			}

			_trackball_case();

			// Test insert hole placement.
			if ( test ) {
				for ( i = [ 0 : CenterBlock_screwCount - 1 ] ) {
					translate ( Screw_positions[i] + [ 0, 0, -pos.x * sin ( Halves_angles.y ) ] ) {
						color ( "green" ) {
							_insert_holes();
						}
					}
				}
			}
		}

		_btus();

		if ( ! test ) {
			for ( pos = Screw_positions ) {
				translate ( pos + [ 0, 0, -pos.x * sin ( Halves_angles.y ) ] ) {
					_insert_holes();
				}
			}
		}

		translate ( MagCon_position ) {
			magnetic_connector ( include_cut = true );
		}

		if ( test ) {
			%_plates();
		} else{
			_plates();
		}
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
	translate ( [ -eps, -topPlate_edge ] ) {
		difference () {
			// Main body
			cube ( [
				centerBlock_wallThickness + centerBlock_ribSize.y + eps,
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
					centerBlock_ribSize.y + 2 * eps,
					hinge_length + 2 * topPlate_edge - 2 * centerBlock_ribSize.x,
					centerBlock_height - bottomPlate_thickness - 2 * centerBlock_ribSize.x
				] );
			}
		}
	}
}

module _pcb_shelf (
	bottomPlate_clearance	= BottomPlate_clearance,
	bottomPlate_thickness	= BottomPlate_thickness,
	halves_angles			= Halves_angles,
	hinge_length			= Hinge_length,
) {
	translate ( [ 0, 0, bottomPlate_thickness - eps ] ) {
		rotate ( [ 0, halves_angles.y, 0 ] ) {
			cube ( [ 5, hinge_length, bottomPlate_clearance + eps ] );
		}
	}
}

module _screw_boss (
	bottomPlate_thickness		= BottomPlate_thickness,
	centerBlock_height			= CenterBlock_height,
	centerBlock_wallThickness	= CenterBlock_wallThickness,
	halves_angles				= Halves_angles,
	insert_holeDiameter			= Insert_holeDiameter,
	insert_wallThickness		= Insert_wallThickness
) {
	d = insert_holeDiameter + 2 * insert_wallThickness;
	h = 2 * centerBlock_height;

	translate ( [ 0, 0, bottomPlate_thickness ] ) {
		rotate ( [ 0, -halves_angles.y, 180 ] ) {
			translate ( [ 0, 0, -h / 4 ] ) {
				cylinder ( d = d, h = h );

				translate ( [ 0, -d / 2, 0 ] ) {
					cube ( [ d, d, h ] );
				}
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
	translate ( [ 0, 0, bottomPlate_thickness ] ) {
		rotate ( [ 0, halves_angles.y, 0 ] ) {
			for ( zpos = [
				-eps, //( bottomPlate_thickness - eps ) *  cos ( halves_angles.y ),
				( centerBlock_height - insert_holeDepth - bottomPlate_thickness + eps ) * ( cos ( halves_angles.y ) ),
			] ){
				translate ( [
					0,
					0,
					zpos
				] ) {
					cylinder ( d = insert_holeDiameter, h = insert_holeDepth + eps );
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
	size = [ 30, 150, 30 ];
	zpos1 = [ centerBlock_height, bottomPlate_thickness ];
	zpos2 = [ 0, -size.z ];
	for ( i = [ 0 : 1 ] ) {
		translate ( [ 0, -size.y / 2, zpos1[i] ] ) {
			rotate ( [ 0, halves_angles.y, 0 ] ) {
				translate ( [ -size.x / 4, size.y / 4, zpos2[i] ] ) {
					cube ( size );
				}
			}
		}
	}
	translate ( [ -size.x, -size.y / 4, 0 ] ) {
		cube ( size );
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