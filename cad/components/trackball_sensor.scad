/*******************************************************************************\
|				Trackball Sensor module for Androphage keyboard.				|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../androphage.scad>

module trackball_sensor ( ) {

	// Focal point of the sensor
	# sphere ( d = 1 );

	cylinder (
		d = Dimensions().Trackball.Sensor.holeSize,
		h = Dimensions().Trackball.Sensor.clearance
	);

	translate (
		Dimensions().Trackball.Sensor.PCBsize / 2
		- Dimensions().Trackball.Sensor.opticalCenter
	) {
		color ( Color().secondary ) {
			cube ( Dimensions().Trackball.Sensor.PCBsize, center = true );
		}

		translate ( [ 0, 0, (
			Dimensions().Trackball.Sensor.PCBsize.z
			+ Dimensions().Trackball.Sensor.size.z
		) / 2 ] ) {
			color ( Color().primary ) {
				cube ( Dimensions().Trackball.Sensor.size, center = true);
			}
		}

		translate ( [ 0, 0, -(
			Dimensions().Trackball.Sensor.PCBsize.z
			+ Dimensions().Trackball.Sensor.lensSize.z
		) / 2 ] ) {
			color ( Color().clear ) {
				cube ( Dimensions().Trackball.Sensor.lensSize, center = true );
			}
		}
	}
}

trackball_sensor (  );