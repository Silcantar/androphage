/*******************************************************************************\
|				Trackball Sensor module for Androphage keyboard.				|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

module trackball_sensor ( dimensions ) {
	cube (
		[
			dimensions.Trackball.Sensor.size.x,
			dimensions.Trackball.Sensor.size.y,
			dimensions.PCB.thickness
		],
		center = true
	);

	translate ( [
		( dimensions.Trackball.Sensor.size.x - 15 ) / 2,
		0,
		2
	] ) {
		cube (
			[
				15,
				10,
				dimensions.Trackball.Sensor.size.z
			],
			center = true
		);
	}
}

use <../androphage.scad>

trackball_sensor ( Dimensions() );