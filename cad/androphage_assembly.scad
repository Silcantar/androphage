/*****************************************************************************\
|												Assembly of Androphage keyboard.											|
|													Copyright 2025 Joshua Lucas 												|
\*****************************************************************************/

use <components/bottom_plate.scad>

use <components/case_frame.scad>

use <components/center_block.scad>

use <components/magnetic_connector.scad>

use <components/switch_plate.scad>

use <components/top_plate.scad>

use <components/trackball.scad>

use <components/trackball_sensor.scad>

// rotate ( [ 0, 0, Dimensions.Halves.angles.z ] ) {
color ( Color_primary ) {
		switch_plate ( Dimensions );
	}

	translate ([ 0, 0, -10 ]) {
		// rotate ( [ 0, -Dimensions.Halves.angles.y, 0 ] ) {
			color ( Color_primary ) {
				bottom_plate ( Dimensions );
			}
		// }
	}


	translate ( [ 0, 0, Dimensions.Key.height ] ) {
		color ( Color_primary ) {
			top_plate ( Dimensions );
		}
	}
// }

!color (Color_secondary){
	center_block ( Dimensions );
}

* translate ( [ -70, 26, 16 ] ) {
	color ( Color_secondary ) {
		trackball ( Dimensions );
	}
}