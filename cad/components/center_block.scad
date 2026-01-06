/*******************************************************************************\
|						Center block for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <../BOSL2/utility.scad>

use <../BOSL2/vectors.scad>

use <../androphage.scad>

use <trackball_sensor.scad>

use <trackball.scad>

use <btu.scad>

module center_block ( ) {

	difference () {
		// Main Body
		union () {
			_trackball_case ( );

			_sensor_holder ( );

			_inner_wall ( );
		}

		// Move the trackball components into position
		translate ( Dimensions().Trackball.position ) {
			// Subtract Trackball + clearance.
			sphere ( d = (
				Dimensions().Trackball.diameter
				+ 2 * Dimensions().Trackball.clearance
			) );

			// Trackball sensor board
			rotate ( [ 0, 180 - Dimensions().Trackball.Sensor.angle, 0 ] ) {
				translate ( [ 0, 0, Dimensions().Trackball.diameter / 2 ] ) {
					trackball_sensor ( include_cut = true );
				}
			}

			// BTUs
			for ( zrot = [ -45, -135 ] ) {
				rotate ( [ 45, 0, zrot ] ) {
					translate ( [ 0, 0, -Dimensions().Trackball.diameter / 2 ] ) {
						btu ( include_cut = true );
					}
				}
			}
		}
	}
}

module _inner_wall ( ) {
	cube ( [ 
		Dimensions().CenterBlock.wallThickness,
		Dimensions().Hinge.length,
		Dimensions().CenterBlock.height
	] );
}

module _sensor_holder ( ) {
	let (
		height = 15,
		width = 5,
		hblock_size = [
			width, 
			Dimensions().Trackball.Sensor.PCBsize.y + Dimensions().CenterBlock.wallThickness, 
			height 
		],
		vblock_size = [ 
			Dimensions().Trackball.Sensor.PCBsize.x + Dimensions().CenterBlock.wallThickness, 
			width, 
			height 
		],
		rot_offset = (
			-height / 2 
			+ Dimensions().Trackball.diameter / 2 
			+ Dimensions().Trackball.Sensor.clearance 
			+ Dimensions().Trackball.Sensor.lensSize.z
			+ Dimensions().Trackball.Sensor.PCBsize.z
		),
	) {
		translate ( Dimensions ().Trackball.position ) {
			rotate ( [ 0, 180 - Dimensions().Trackball.Sensor.angle, 0 ] ) {
				translate ( 
					v_mul(
						(
							Dimensions().Trackball.Sensor.PCBsize / 2 
							- Dimensions().Trackball.Sensor.opticalCenter
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
}

module _trackball_case ( ) {
	diameter = (
		Dimensions().Trackball.diameter 
		+ 2 * (
			Dimensions().Trackball.clearance 
			+ Dimensions().CenterBlock.wallThickness 
		)
	);

	translate ( Dimensions().Trackball.position ) {
		rotate ( [ 90, 0, 0 ] ) { rotate ( [ 0, 0, -90 ] ) {
			rotate_extrude ( angle = 90 - Dimensions().Halves.angles.y ) {
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

//color ( "white" )
center_block ( );
//trackball_case ( );