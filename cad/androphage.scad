/*******************************************************************************\
|							Assembly of Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

// $preview = false;

include <androphage_globals.scad>

use <components/battery.scad>

use <components/bottom_plate.scad>

use <components/frame2.scad>

use <components/center_block.scad>

use <components/hinge.scad>

use <components/keys.scad>

use <components/magnetic_connector.scad>

use <components/mcu.scad>

use <components/pcb.scad>

use <components/plates_common.scad>

use <components/switch_plate.scad>

use <components/top_plate.scad>

use <components/trackball.scad>

use <components/trackball_sensor.scad>

_do_mirror = false;
_do_rotate = false;

translate ( -[ Trackball_position.x, Trackball_position.y, FrontHinge_position.z ] ) {
	androphage_assembly();
}

if ( _do_mirror ) {
	rotate ( [ 0, _do_rotate ? 180 + 2 * Halves_angles.y : 0, 0 ] ) {
		translate ( -[ Trackball_position.x, Trackball_position.y, FrontHinge_position.z ] ) {
			mirror ( [ 1, 0, 0 ] ) {
				androphage_assembly( include_hinge = false );
			}
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


module androphage_assembly( include_hinge = true ) {
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
			color ( PCB_color, 1 ) {
				pcb ( zpos = PCB_position.z );
			}
		}
	}

	/*				Switch Plate				*/
	if ( SwitchPlate_present && SwitchPlate_visible ) {
		place_plate ( SwitchPlate_position ) {
			color ( SwitchPlate_color, 1 ) {
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

	/*				Case Frame				*/
	if ( Frame_visible ) {
		translate ( Frame_position ) {
			rotate ( [ 0, Halves_angles.y, 0 ] ) {
				rotate ( [ 90, 0, -90 ] ) {
					color ( Frame_color, 0.5 ) {
						frame();
					}
				}
			}
		}
	}

	/*				Center Block				*/
	if ( CenterBlock_visible ) {
		color ( CenterBlock_color ) {
			center_block();
		}
	}

	if ( Hinge_visible && include_hinge ) {
		color ( Hinge_color ) {
			translate ( FrontHinge_position ) {
				// rotate ( [ -90, 0, 0 ] ) {
						hinge (
							length	= FrontHinge_length,
							angle	= Halves_angles.y * 2
						);
					// }
				}

			translate ( BackHinge_position ) {
				// rotate ( [ -90, 0, 0 ] ) {
					hinge (
						length	= BackHinge_length,
						angle	= Halves_angles.y * 2,
						center	= false,
						front	= false
					);
				// }
			}
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

			// MCU piggybacking on trackball sensor PCB.
			*translate ( [ 0, 0, 10 ] ) {
				rotate ( [ 180, 180, 0 ] ) {
					mcu();
				}
			}
		}
	}

	if ( MagCon_visible ) {
		translate ( MagCon_position ) {
			magnetic_connector();

			// MCU piggybacking on magnetic connector PCB.
			translate ( [ 8, 8, -3 ] ) {
				rotate ( [ 180, -90, 0 ] ) {
					*battery( [ 12, 30, 3 ] );
					mcu();
				}
			}
		}
	}

	// MCU directly at USB port location.
	*translate ( [ 20, 84, 3 ] ) {
		rotate ( [ 0, 0 + Halves_angles.y, 0 ] ) {
			mcu();
		}
	}
	
	if ( Battery_visible ) {
		translate ( [ 20, 88, 11.3 ] ) {
			rotate ( [ 0, Halves_angles.y, 0 ] )
			rotate ( [ 0, 90, 100 ] ) {
				battery();
			}
		}
	}

	keys();
}