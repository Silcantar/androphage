/*******************************************************************************\
|				Trackball Sensor module for Androphage keyboard.				|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

// include <../globals.scad>

// include <../color.scad>

// if ( is_undef ( ANDROPHAGE_MAIN ) ) {

//     // Test
//     trackball_sensor ( Trackball_Sensor, include_cut = true );
// }

module trackball_sensor ( include_cut = false ) {
    // Focal point of the sensor
    * sphere ( d = 1 );

    translate ( Trackball_Sensor_pcbSize / 2 - Trackball_Sensor_opticalCenter ) {
        // PCB
        color ( PCB_color ) {
            cube ( Trackball_Sensor_pcbSize, center = true );
        }

        // Sensor
        translate ( [ 0, 0, (
            Trackball_Sensor_pcbSize.z
            + Trackball_Sensor_size.z
        ) / 2 ] ) {
            color ( Trackball_Sensor_color ) {
                cube ( Trackball_Sensor_size, center = true);
            }
        }

        // Lens
        translate ( [ 0, 0, -(
            Trackball_Sensor_pcbSize.z
            + Trackball_Sensor_lensSize.z
        ) / 2 ] ) {
            color ( Trackball_Sensor_lensColor ) {
                cube ( Trackball_Sensor_lensSize + [ 0, 0, $eps ], center = true );
            }
        }
    }

    if ( include_cut ) {
        color ( Color_cut ){
            cylinder (
                d = Trackball_Sensor_holeSize,
                h = Trackball_Sensor_clearance + $eps
            );

            translate (
                Trackball_Sensor_pcbSize / 2
                - Trackball_Sensor_opticalCenter
                + [
                    0,
                    0,
                    Trackball_Sensor_clearance
                    + Trackball_Sensor_lensSize.z
                    - $eps
                ]
            ) {
                cube (
                    [
                        Trackball_Sensor_pcbSize.x,
                        Trackball_Sensor_pcbSize.y,
                        10
                    ],
                    center = true
                );
            }
        }
    }
}