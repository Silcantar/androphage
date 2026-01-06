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
	translate ( Dimensions().PCB.position ) {
		color ( Color().secondary ) {
			pcb ( zpos = Dimensions().PCB.position.z );
		}
	}

	/*				Switch Plate				*/
	if ( Dimensions().Plate.Switch.present ) {
		translate ( Dimensions().Plate.Switch.position ) {
			color ( Color().primary ) {
				switch_plate ( zpos = Dimensions().Plate.Switch.position.z );
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
	translate ( Dimensions().Plate.Top.position ) {
		color ( Color().primary ) {
			top_plate ( zpos = Dimensions().Plate.Top.position.z );
		}
	}

	/*				Center Block & Trackball				*/
	//translate ( [ 0, 0, Dimensions().Plate.Bottom.thickness ] ) {
		color ( Color().secondary ){
			center_block ( );
		}

	/*				Trackball				*/
		translate ( Dimensions().Trackball.position ) {
			color ( Color().secondary ) {
				trackball ( centers = false );
			}
		}
	//}
}