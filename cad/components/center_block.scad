/*******************************************************************************\
|						Center block for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

module center_block ( dimensions ) {
	difference () {
		cube ( [
			dimensions.CenterBlock.width,
			dimensions.Hinge.length,
			(
				dimensions.Key.height
				+ dimensions.Plate.Bottom.clearance
				- dimensions.Plate.Top.thickness
			) ] );

		translate ( [
			20,
			(
				dimensions.Trackball.position
				- dimensions.Trackball.Sensor.size.y / 2
			),
			0
		] ) {
			rotate ( [ 0, -dimensions.Trackball.Sensor.angle, 0 ] ) {
				cube ( dimensions.Trackball.Sensor.size );
			}
		}
	}
}

use <../androphage.scad>
use <trackball.scad>

center_block ( Dimensions () );

translate ( [ 0, 60, 18 ] ) {
	# trackball ( Dimensions () );
}