/*******************************************************************************\
|						Center block for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

$fa = 1;
$fs = 0.1;

use <../androphage.scad>

use <trackball_sensor.scad>

module center_block ( ) {
	difference () {
		// Main Body
		cube ( [
			Dimensions().CenterBlock.width,
			Dimensions().Hinge.length,
			(
				Dimensions().Key.height
				+ Dimensions().Plate.Bottom.clearance
				- Dimensions().Plate.Top.thickness
			) ] );

		// Subtract Trackball + clearance.
		translate ( [ 0, 60, 19 ] ) {
			sphere ( d = (
				Dimensions().Trackball.diameter
				+ 2 * Dimensions().Trackball.clearance
			) );

			rotate ( [ 0, 180 - Dimensions().Trackball.Sensor.angle, 0 ] ) {
				translate ( [ 0, 0, Dimensions().Trackball.diameter / 2 ] ) {
					# trackball_sensor ();
				}
			}
		}
	}
}

center_block ( );