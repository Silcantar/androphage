/*******************************************************************************\
|							Assembly of Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <library/animation.scad>

androphage_assembly();

angle = ( 180 + 2 * Halves_angles.y ) * oscillate();

module androphage_assembly () {
    // Assemble and place the right half.
    echo ( "Assembling right half." );
    translate ( -[ Trackball_position.x, Trackball_position.y, Hinge_Front_position.z ] ) {
        assemble_half();
    }

    // Assemble and place the left half.
    if ( LeftHalf_visible ) {
        echo ( "Assembling left half." );
        rotate ( [ 0, LeftHalf_visible ? angle : 0, 0 ] ) {
            translate ( -[ Trackball_position.x, Trackball_position.y, Hinge_Front_position.z ] ) {
                mirror ( [ 1, 0, 0 ] ) {
                    assemble_half( secondary = true );
                }
            }
        }
    }

    // Desk
    if ( Desk_visible ) {
        echo ( "Building Desk." );
        translate ( Desk_position ) {
            color ( Desk_color ) {
                cube ( Desk_size, center = true );
            }
        }
    }
}

// Assemble one half of the Androphage keyboard.
module assemble_half( secondary = false ) {
    /*				Bottom Plate				*/
    if ( BottomPlate_visible ) {
        echo ( "    Building bottom plate." );
        rotate ( [ 0, Halves_angles.y, 0 ] ) {
            color ( BottomPlate_color ) {
                plate ( bottom );
            }
        }
    }

    /*				PCB				*/
    if ( PCB_visible ) {
        echo ( "    Building PCB." );
        translate ( PCB_position ) {
            rotate ( [ 0, Halves_angles.y, 0 ] ) {
                color ( PCB_color, 1 ) {
                    plate ( pcb, zpos = PCB_position.z );
                }
            }
        }
    }

    /*				Switch Plate				*/
    if ( SwitchPlate_present && SwitchPlate_visible ) {
        echo ( "    Building switch plate." );
        translate ( SwitchPlate_position ) {
            rotate ( [ 0, Halves_angles.y, 0 ] ) {
                color ( SwitchPlate_color, 1 ) {
                    plate ( switch, zpos = SwitchPlate_position.z );
                }
            }
        }
    }

    /*				Top Plate				*/
    if ( TopPlate_visible ) {
        echo ( "    Building top plate." );
        translate ( TopPlate_position ) {
            rotate ( [ 0, Halves_angles.y, 0 ] ) {
                color ( TopPlate_color ) {
                    plate ( top, zpos = TopPlate_position.z );
                }
            }
        }
    }

    /*				Case Frame				*/
    if ( Frame_visible ) {
        echo ( "    Building frame." );
        translate ( [ 0, -SwitchPlate_edge, 0 ] ) {
            rotate ( [ 0, Halves_angles.y, 0 ] ) {
                rotate ( [ 90, 0, -90 ] ) {
                    color ( Frame_color, 1 ) {
                        frame();
                    }
                }
            }
        }
    }

    /*				Center Block				*/
    if ( CenterBlock_visible ) {
        echo ( "    Building center block." );
        color ( CenterBlock_color ) {
            center_block();
        }
    }

    if ( Hinge_visible && !secondary ) {
        echo ( "    Building hinges." );
        color ( Hinge_color ) {
            translate ( Hinge_Front_position ) {
                rotate ( [ 0, angle / 2, 0 ] ) {
                    hinge (
                        length	= Hinge_Front_length,
                        angle	= Halves_angles.y * 2 - angle,
                        zpos = TopPlate_position.z
                    );
                }
            }

            translate ( Hinge_Back_position ) {
                rotate ( [ 0, angle / 2, 0 ] ) {
                    hinge (
                        length	= Hinge_Back_length,
                        angle	= Halves_angles.y * 2 - angle,
                        center	= false,
                        front	= false,
                        zpos = TopPlate_position.z
                    );
                }
            }
        }
    }

    /*				Trackball				*/
    if ( Trackball_visible ) {
        echo ( "    Building trackball." );
        translate ( Trackball_position ) {
            trackball ( centers = false );
        }
    }

    if ( Trackball_BTU_visible ) {
        echo ( "    Building BTUs." );
        color ( Trackball_BTU_color ) {
            place_btus();
        }
    }

    if ( Trackball_Sensor_visible ) {
        echo ( "    Building trackball sensor." );
        place_sensor () {
            trackball_sensor();

            if ( MCU_visible && !secondary && MCU_location == "trackball sensor" ) {
                // MCU piggybacking on trackball sensor PCB.
                translate ( [ -2, -5, 10 ] ) {
                    rotate ( [ 180, 180, 0 ] ) {
                        mcu();
                    }
                }
            }
        }
    }

    translate ( MagCon_position ) {
        if ( MagCon_visible ) {
            echo ( "    Building magnetic connector." );
            magnetic_connector();
        }

        if ( MCU_visible && !secondary && MCU_location == "magnetic connector" ) {
            // MCU piggybacking on magnetic connector PCB.
            translate ( [ 8, 8, -3 ] ) {
                rotate ( [ 180, -90, 0 ] ) {
                    *battery( [ 12, 30, 3 ] );
                    mcu();
                }
            }
        }
    }

    if ( MCU_visible && !secondary && MCU_location == "main PCB" ) {
        // MCU directly at USB port location.
        translate ( [ 20, 86, 0 ] ) {
            rotate ( [ 0, 0 + Halves_angles.y, 0 ] ) {
                mcu( include_cut = false );
            }
        }
    }

    if ( Battery_visible ) {
        echo ( "    Building battery." );
        translate ( [ 20, 88, 11.3 ] ) {
            rotate ( [ 0, Halves_angles.y, 0 ] )
            rotate ( [ 0, 90, 100 ] ) {
                battery();
            }
        }
    }

        translate ( SwitchPlate_position + [ 0, 0, SwitchPlate_thickness ] ) {
            rotate ( [ 0, Halves_angles.y, 0 ] ) {
                echo ( "    Building keys and switches." );
                keys();
            }
        }
}