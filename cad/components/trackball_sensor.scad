/*******************************************************************************\
|				Trackball Sensor module for Androphage keyboard.				|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

// include <../globals.scad>

// include <../color.scad>

// if ( is_undef ( ANDROPHAGE_MAIN ) ) {

//     // Test
//     trackball_sensor ( Trackball.Sensor, include_cut = true );
// }

module trackball_sensor (
    // sensor,
    include_cut				= false,
    // sensor_pcbSize			= Trackball_Sensor_pcbSize,
    // sensor_opticalCenter	= Trackball_Sensor_opticalCenter,
    // sensor_size				= Trackball_Sensor_size,
    // sensor_lensSize			= Trackball_Sensor_lensSize,
    // sensor_holeSize			= Trackball_Sensor_holeSize,
    // sensor_clearance		= Trackball_Sensor_clearance,
    // color_pcb				= PCB_color,
    // color_sensor			= Trackball_Sensor_color,
    // color_lens				= Color_clear,
    // color_cut				= Color_cut
) {
    sensor = Trackball.Sensor;

    // Focal point of the sensor
    * sphere ( d = 1 );

    translate ( sensor.pcbSize / 2 - sensor.opticalCenter ) {
        // PCB
        color ( Color.pcb ) {
            cube ( sensor.pcbSize, center = true );
        }

        // Sensor
        translate ( [ 0, 0, (
            sensor.pcbSize.z
            + sensor.size.z
        ) / 2 ] ) {
            color ( sensor.color ) {
                cube ( sensor.size, center = true);
            }
        }

        // Lens
        translate ( [ 0, 0, -(
            sensor.pcbSize.z
            + sensor.lensSize.z
        ) / 2 ] ) {
            color ( sensor.lensColor ) {
                cube ( sensor.lensSize + [ 0, 0, eps ], center = true );
            }
        }
    }

    if ( include_cut ) {
        color ( Color.cut ){
            cylinder (
                d = sensor.holeSize,
                h = sensor.clearance + eps
            );

            translate (
                sensor.pcbSize / 2
                - sensor.opticalCenter
                + [
                    0,
                    0,
                    sensor.clearance
                    + sensor.lensSize.z
                    - eps
                ]
            ) {
                cube (
                    [
                        sensor.pcbSize.x,
                        sensor.pcbSize.y,
                        10
                    ],
                    center = true
                );
            }
        }
    }
}