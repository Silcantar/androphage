/*******************************************************************************\
|						Center block for Androphage keyboard.					|
|							Copyright 2025 Joshua Lucas 						|
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
			0,
			(
				dimensions.Trackball.position
				- dimensions.Trackball.Sensor.size.y / 2
			),
			0
		] ) {
			rotate ( [0, -dimensions.Trackball.Sensor.angle, 0] ) {
				cube ( dimensions.Trackball.Sensor.size + [ 10, 0, 0 ] );
			}
		}
	}
}
