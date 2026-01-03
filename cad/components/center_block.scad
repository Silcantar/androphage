/*******************************************************************************\
|						Center block for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

$fa = 1;
$fs = 0.1;

use <../androphage.scad>

use <trackball_sensor.scad>

use <trackball.scad>

use <btu.scad>

module center_block ( ) {
	difference () {
		// Main Body
		cube ( [
			Dimensions().CenterBlock.width,
			Dimensions().Hinge.length,
			(
				Dimensions().Plate.Bottom.clearance
				+ Dimensions().PCB.thickness
				+ Dimensions().Key.height

				//- Dimensions().Plate.Top.thickness
			) ] );

		* echo ( Dimensions().Trackball.position.z );

		// Subtract Trackball + clearance.
		translate ( Dimensions().Trackball.position ) {
			sphere ( d = (
				Dimensions().Trackball.diameter
				+ 2 * Dimensions().Trackball.clearance
			) );

			rotate ( [ 0, 180 - Dimensions().Trackball.Sensor.angle, 0 ] ) {
				translate ( [ 0, 0, Dimensions().Trackball.diameter / 2 ] ) {
					trackball_sensor ( include_cut = true );
				}
			}

			for ( zrot = [ -45, -135 ] ) {
				rotate ( [ 0, 0, zrot ] ) {
					rotate ( [ 45, 0, 0 ] ) {
						translate ( [ 0, 0, -Dimensions().Trackball.diameter / 2 ] ) {
							btu ( include_cut = true );
						}
					}
				}
			}
		}
	}
}

color ( "white" )
center_block ( );