/*******************************************************************************\
|				Trackball Sensor module for Androphage keyboard.				|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <../androphage.scad>

module trackball_sensor ( include_cut = false ) {

	// Focal point of the sensor
	* sphere ( d = 1 );

	translate (
		Trackball_Sensor_PCBsize() / 2
		- Trackball_Sensor_opticalCenter()
	) {
		// PCB
		color ( Color_secondary() ) {
			cube ( Trackball_Sensor_PCBsize(), center = true );
		}

		// Sensor
		translate ( [ 0, 0, (
			Trackball_Sensor_PCBsize().z
			+ Trackball_Sensor_size().z
		) / 2 ] ) {
			color ( Color_primary() ) {
				cube ( Trackball_Sensor_size(), center = true);
			}
		}

		// Lens
		translate ( [ 0, 0, -(
			Trackball_Sensor_PCBsize().z
			+ Trackball_Sensor_lensSize().z
		) / 2 ] ) {
			color ( Color_clear() ) {
				cube ( Trackball_Sensor_lensSize() + [ 0, 0, eps ], center = true );
			}
		}
	}

	if ( include_cut ) {
		color ( Color_cut() ){
			cylinder (
				d = Trackball_Sensor_holeSize(),
				h = Trackball_Sensor_clearance() + eps
			);

			translate (
				Trackball_Sensor_PCBsize() / 2
				- Trackball_Sensor_opticalCenter()
				+ [
					0,
					0,
					Trackball_Sensor_clearance()
					+ Trackball_Sensor_lensSize().z
					- eps
				]
			) {
				cube (
					[
						Trackball_Sensor_PCBsize().x,
						Trackball_Sensor_PCBsize().y,
						10
					],
					center = true
				);
			}
		}
	}
}

trackball_sensor ( include_cut = true );