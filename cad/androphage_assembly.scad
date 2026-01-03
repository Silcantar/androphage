/*******************************************************************************\
|							Assembly of Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <androphage.scad>

use <components/bottom_plate.scad>

use <components/case_frame.scad>

use <components/center_block.scad>

use <components/magnetic_connector.scad>

use <components/pcb.scad>

use <components/plate_sketch.scad>

use <components/switch_plate.scad>

use <components/top_plate.scad>

use <components/trackball.scad>

use <components/trackball_sensor.scad>

module androphage_assembly ( ) {
	/*				PCB				*/
	translate ( [ 0, 0, Dimensions().Plate.Bottom.clearance + Dimensions().Switch.height.legs ] ) {
		color ( Color().secondary ) {
			pcb ( );
		}
	}

	/*				Switch Plate				*/
	if ( Dimensions().Plate.Switch.present ) {
		translate ( [ 0, 0, (
				Dimensions().Plate.Bottom.clearance
				+ Dimensions().Switch.height.legs
				+ Dimensions().Switch.height.lower
		) ] ) {
			color ( Color().primary ) {
				switch_plate ( );
			}
		}
	}

	/*				Bottom Plate				*/
	translate ( [ 0, 0, 0 ] ) {
		color ( Color().primary ) {
			bottom_plate ( );
		}
	}

	/*				Top Plate				*/
	translate ( [
		0,
		0,
		(
			Dimensions().Plate.Bottom.thickness
			+ Dimensions().Plate.Bottom.clearance
			+ Dimensions().PCB.thickness
			+ Dimensions().Key.height
			//- Dimensions().Plate.Top.thickness
		)
	] ) {
		color ( Color().primary ) {
			top_plate ( );
		}
	}

	/*				Center Block & Trackball				*/
	translate ( [ 0, 0, Dimensions().Plate.Bottom.thickness ] ) {
		color ( Color().secondary ){
			center_block ( );
		}

	/*				Trackball				*/
		translate ( Dimensions().Trackball.position ) {
			color ( Color().secondary ) {
				trackball ( centers = true );
			}
		}
	}
}