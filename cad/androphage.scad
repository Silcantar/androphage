/*******************************************************************************\
|							Assembly of Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

// $preview = false;

include <androphage_globals.scad>

use <components/bottom_plate.scad>

use <components/case_frame.scad>

use <components/center_block.scad>

use <components/choc_switch.scad>

use <components/magnetic_connector.scad>

use <components/pcb.scad>

use <components/plate_sketch.scad>

use <components/switch_plate.scad>

use <components/top_plate.scad>

use <components/trackball.scad>

use <components/trackball_sensor.scad>

// Keycap_visible = false;
BottomPlate_visible = false;
TopPlate_visible = false;
Trackball_visible = false;

// Switch_travel = Switch_maxTravel * ( 0.5 * sin ( 360 * $t ) + 0.5 );

// render () {
	androphage_assembly();
// }

module androphage_assembly() {
	/*				PCB				*/
	if ( PCB_visible ) {
		translate ( PCB_position ) {
			color ( Color_secondary ) {
				pcb ( zpos = PCB_position.z );
			}
		}
	}

	/*				Switch Plate				*/
	if ( SwitchPlate_present && SwitchPlate_visible ) {
		translate ( SwitchPlate_position ) {
			color ( Color_primary ) {
				switch_plate ( zpos = SwitchPlate_position.z );
			}
		}
	}

	/*				Bottom Plate				*/
	if ( BottomPlate_visible ) {
		translate ( [ 0, 0, 0 ] ) {
			color ( Color_primary ) {
				bottom_plate();
			}
		}
	}
	/*				Top Plate				*/
	if ( TopPlate_visible ) {
		translate ( TopPlate_position ) {
			color ( Color_primary ) {
				top_plate ( zpos = TopPlate_position.z );
			}
		}
	}

	/*				Center Block & Trackball				*/
	if ( CenterBlock_visible ) {
		color ( Color_secondary ){
			center_block();
		}
	}

	/*				Trackball				*/
	if ( Trackball_visible ) {
		translate ( Trackball_position ) {
			color ( Color_secondary ) {
				trackball ( centers = false );
			}
		}
	}

	if ( Trackball_BTU_visible ) {
		color ( Color_steel ) {
			place_btus();
		}
	}

	if ( Trackball_Sensor_visible ) {
		place_sensor();
	}

	if ( MagCon_visible ) {
		translate ( MagCon_position ) {
			color ( Color_primary ) {
				magnetic_connector();
			}
		}
	}

	key_pos = key_positions();

	place_plate () {
		for ( i = [ 0 : last ( key_pos ) ] ) {
			let ( p = key_pos[i] ) {
				translate ( [ p.x, p.y, 0 ] ){
					rotate ( p[2][0] + Keycap_style[i][1] * 180 ) {
						if ( Switch_visible ) {
							translate ( [ 0, 0, Switch_position_z ] ) {
								choc_switch ( travel = Switch_travel );
							}
						}
						if ( Keycap_visible ) {
							translate ( [ 0, 0, Keycap_position_z ] ) {
								color ( Color_secondary ) {
									import ( str ( Keycap_path, Keycap_style[i][0], ".stl" ) );
								}
							}
						}
					}
				}
			}
		}
	}
}