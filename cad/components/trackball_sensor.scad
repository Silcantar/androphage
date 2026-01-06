/*******************************************************************************\
|				Trackball Sensor module for Androphage keyboard.				|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <../androphage.scad>

module trackball_sensor ( include_cut = false ) {

	let ( Sensor = Dimensions().Trackball.Sensor ) {

		// Focal point of the sensor
		* sphere ( d = 1 );

		translate (
			Dimensions().Trackball.Sensor.PCBsize / 2
			- Dimensions().Trackball.Sensor.opticalCenter
		) {
			// PCB
			color ( Color().secondary ) {
				cube ( Dimensions().Trackball.Sensor.PCBsize, center = true );
			}

			// Sensor
			translate ( [ 0, 0, (
				Dimensions().Trackball.Sensor.PCBsize.z
				+ Dimensions().Trackball.Sensor.size.z
			) / 2 ] ) {
				color ( Color().primary ) {
					cube ( Dimensions().Trackball.Sensor.size, center = true);
				}
			}

			// Lens
			translate ( [ 0, 0, -(
				Dimensions().Trackball.Sensor.PCBsize.z
				+ Dimensions().Trackball.Sensor.lensSize.z
			) / 2 ] ) {
				color ( Color().clear ) {
					cube ( Dimensions().Trackball.Sensor.lensSize + [ 0, 0, eps ], center = true );
				}
			}
		}

		if ( include_cut ) {
			color ( Color().cut ){
				cylinder (
					d = Dimensions().Trackball.Sensor.holeSize,
					h = Dimensions().Trackball.Sensor.clearance + eps
				);

				translate (
					Dimensions().Trackball.Sensor.PCBsize / 2
					- Dimensions().Trackball.Sensor.opticalCenter
					+ [
						0,
						0,
						Dimensions().Trackball.Sensor.clearance
						+ Sensor.lensSize.z
						- eps
					]
				) {
					cube (
						[
							Dimensions().Trackball.Sensor.PCBsize.x,
							Dimensions().Trackball.Sensor.PCBsize.y,
							10
						],
						center = true
					);
				}
			}
		}
	}
}

trackball_sensor ( include_cut = true );