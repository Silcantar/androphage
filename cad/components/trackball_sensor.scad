/*******************************************************************************\
|				Trackball Sensor module for Androphage keyboard.				|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

// Test
trackball_sensor ( include_cut = true );

module trackball_sensor (
	include_cut				= false,
	sensor_pcbSize			= Trackball_Sensor_pcbSize,
	sensor_opticalCenter	= Trackball_Sensor_opticalCenter,
	sensor_size				= Trackball_Sensor_size,
	sensor_lensSize			= Trackball_Sensor_lensSize,
	sensor_holeSize			= Trackball_Sensor_holeSize,
	sensor_clearance		= Trackball_Sensor_clearance,
	color_pcb				= Color_secondary,
	color_sensor			= Color_primary,
	color_lens				= Color_clear,
	color_cut				= Color_cut
) {

	// Focal point of the sensor
	* sphere ( d = 1 );

	translate (
		sensor_pcbSize / 2
		- sensor_opticalCenter
	) {
		// PCB
		color ( color_pcb ) {
			cube ( sensor_pcbSize, center = true );
		}

		// Sensor
		translate ( [ 0, 0, (
			sensor_pcbSize.z
			+ sensor_size.z
		) / 2 ] ) {
			color ( color_sensor ) {
				cube ( sensor_size, center = true);
			}
		}

		// Lens
		translate ( [ 0, 0, -(
			sensor_pcbSize.z
			+ sensor_lensSize.z
		) / 2 ] ) {
			color ( color_lens ) {
				cube ( sensor_lensSize + [ 0, 0, eps ], center = true );
			}
		}
	}

	if ( include_cut ) {
		color ( color_cut ){
			cylinder (
				d = sensor_holeSize,
				h = sensor_clearance + eps
			);

			translate (
				sensor_pcbSize / 2
				- sensor_opticalCenter
				+ [
					0,
					0,
					sensor_clearance
					+ sensor_lensSize.z
					- eps
				]
			) {
				cube (
					[
						sensor_pcbSize.x,
						sensor_pcbSize.y,
						10
					],
					center = true
				);
			}
		}
	}
}