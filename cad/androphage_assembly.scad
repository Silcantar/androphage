/*******************************************************************************\
|							Assembly of Androphage keyboard.					|
|							Copyright 2025 Joshua Lucas 						|
\*******************************************************************************/

use <components/bottom_plate.scad>

use <components/case_frame.scad>

use <components/center_block.scad>

use <components/magnetic_connector.scad>

use <components/plate_sketch.scad>

use <components/switch_plate.scad>

use <components/top_plate.scad>

use <components/trackball.scad>

use <components/trackball_sensor.scad>

/*				Switch Plate				*/
translate ( [ 0, 0, Dimensions.Plate.Bottom.clearance ] ) {
	color ( Color_primary ) {
		switch_plate ( Dimensions );
	}
}

/*				Bottom Plate				*/
translate ( [ 0, 0, 0 ] ) {
	color ( Color_primary ) {
		bottom_plate ( Dimensions );
	}
}

/*				Top Plate				*/
translate ( [
	0,
	0,
	Dimensions.Key.height + Dimensions.Plate.Bottom.clearance
] ) {
	color ( Color_primary ) {
		top_plate ( Dimensions );
	}
}

plateSketchPoints = plate_sketch_points ( Dimensions );

/*				Center Block				*/
translate (
	concat (
		bottom_center_point ( Dimensions ),
		[ Dimensions.Plate.Bottom.thickness ]
	)
) {
	rotate ( [ 0, 0, -Dimensions.Halves.angles.z ] ) {
		color (Color_secondary){
			center_block ( Dimensions );
		}
	}
}

/*				Trackball				*/
translate ( [ -70, 26, 16 ] ) {
	color ( Color_secondary ) {
		trackball ( Dimensions );
	}
}