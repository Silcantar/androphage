/*******************************************************************************\
|							Assembly of Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

$preview = false;

include <androphage_globals.scad>

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

render () {
	androphage_assembly();
}

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

	NormalKeycap_path = str ( Keycap_path, "Normal.stl" );

	key_pos = key_positions();

	translate ( [0, 0, 20 ] ) {
		import ( str ( Keycap_path, "Normal.stl" ) );
	}

	import ( str ( Keycap_path, "Normal_Tilted.stl" ) );

	color ( Color_secondary ) {
		place_plate () {
			for ( i = [ 0 : last ( key_pos ) ] ) {
				let ( p = key_pos[i] ) {
					translate ( [ p.x, p.y, Keycap_position_z ] ){
						rotate ( p[2][0] + Keycap_style[i][1] * 180 ) {
							import ( str ( Keycap_path, Keycap_style[i][0], ".stl" ) );
						}
					}
				}
			}
		}
	}
}