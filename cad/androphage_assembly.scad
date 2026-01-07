/*******************************************************************************\
|							Assembly of Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <androphage_globals.scad>

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

module androphage_assembly() {
	/*				PCB				*/
	translate ( PCB_position() ) {
		color ( Color_secondary() ) {
			pcb ( zpos = PCB_position().z );
		}
	}

	/*				Switch Plate				*/
	if ( SwitchPlate_present() ) {
		translate ( SwitchPlate_position() ) {
			color ( Color_primary() ) {
				switch_plate ( zpos = SwitchPlate_position().z );
			}
		}
	}

	/*				Bottom Plate				*/
	translate ( [ 0, 0, 0 ] ) {
		color ( Color_primary() ) {
			bottom_plate();
		}
	}

	/*				Top Plate				*/
	translate ( TopPlate_position() ) {
		color ( Color_primary() ) {
			top_plate ( zpos = TopPlate_position().z );
		}
	}

	/*				Center Block & Trackball				*/
	//translate ( [ 0, 0, BottomPlate_thickness ] ) {
		color ( Color_secondary() ){
			center_block();
		}

	/*				Trackball				*/
		translate ( Trackball_position() ) {
			color ( Color_secondary() ) {
				trackball ( centers = false );
			}
		}
	//}
}