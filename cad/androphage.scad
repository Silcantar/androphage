/*******************************************************************************\
|							Assembly of Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

// $preview = false;

include <androphage_globals.scad>

use <components/bottom_plate.scad>

use <components/case_frame.scad>

use <components/center_block.scad>

use <components/keys.scad>

use <components/magnetic_connector.scad>

use <components/pcb.scad>

use <components/plates_common.scad>

use <components/switch_plate.scad>

use <components/top_plate.scad>

use <components/trackball.scad>

use <components/trackball_sensor.scad>

_do_mirror = true;

translate ( -Trackball_position ) {
	androphage_assembly();
	if ( _do_mirror ) {
		mirror ( [ 1, 0, 0 ] ) {
			androphage_assembly();
		}
	}
}

// Desk
if ( Desk_visible ) {
	translate ( Desk_position ) {
		color ( Desk_color ) {
			cube ( Desk_size, center = true );
		}
	}
}


module androphage_assembly() {
	/*				Bottom Plate				*/
	if ( BottomPlate_visible ) {
		place_plate () {
			color ( BottomPlate_color ) {
				bottom_plate();
			}
		}
	}

	/*				PCB				*/
	if ( PCB_visible ) {
		place_plate ( PCB_position ) {
			color ( PCB_color ) {
				pcb ( zpos = PCB_position.z );
			}
		}
	}

	/*				Switch Plate				*/
	if ( SwitchPlate_present && SwitchPlate_visible ) {
		place_plate ( SwitchPlate_position ) {
			color ( SwitchPlate_color ) {
				switch_plate ( zpos = SwitchPlate_position.z );
			}
		}
	}

	/*				Top Plate				*/
	if ( TopPlate_visible ) {
		place_plate ( TopPlate_position ) {
			color ( TopPlate_color ) {
				top_plate ( zpos = TopPlate_position.z );
			}
		}
	}

	/*				Center Block & Trackball				*/
	if ( CenterBlock_visible ) {
		color ( CenterBlock_color ){
			center_block();
		}
	}

	/*				Trackball				*/
	if ( Trackball_visible ) {
		translate ( Trackball_position ) {
			trackball ( centers = false );
		}
	}

	if ( Trackball_BTU_visible ) {
		color ( Trackball_BTU_color ) {
			place_btus();
		}
	}

	if ( Trackball_Sensor_visible ) {
		place_sensor () {
			trackball_sensor();
		}
	}

	if ( MagCon_visible ) {
		translate ( MagCon_position ) {
			magnetic_connector();
		}
	}

	keys();
}