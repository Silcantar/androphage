/*******************************************************************************\
|							Assembly of Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

androphage_assembly();

module androphage_assembly () {
    // Assemble and place the right half.
    translate ( -[ Trackball.position.x, Trackball.position.y, Hinge.Front.position.z ] ) {
        assemble_half();
    }

    // Assemble and place the left half.
    if ( LeftHalf_visible ) {
        rotate ( [ 0, LeftHalf_visible ? 180 + 2 * Halves.angles.y : 0, 0 ] ) {
            translate ( -[ Trackball.position.x, Trackball.position.y, Hinge.Front.position.z ] ) {
                mirror ( [ 1, 0, 0 ] ) {
                    assemble_half( include_hinge = false );
                }
            }
        }
    }

    // Desk
    if ( Desk.visible ) {
        translate ( Desk.position ) {
            color ( Desk.color ) {
                cube ( Desk.size, center = true );
            }
        }
    }
}

// Assemble one half of the Androphage keyboard.
module assemble_half( include_hinge = true ) {
    /*				Bottom Plate				*/
    if ( Plate.Bottom.visible ) {
        // place_plate () {
            color ( Plate.Bottom.color ) {
                plate ( plates().bottom, Cluster, Column, Frame, Key, LED, Plate, Switch );
            }
        // }
    }

    /*				PCB				*/
    if ( PCB.visible ) {
        translate ( PCB.position ) {
            color ( PCB.color, 1 ) {
                plate ( plates().pcb, Cluster, Column, Frame, Key, LED, Plate, Switch, zpos = PCB_position.z );
            }
        }
    }

    /*				Switch Plate				*/
    if ( Plate.Switch.present && Plate.Switch.visible ) {
        translate ( Plate.Switch.position ) {
            color ( Plate.Switch.color, 1 ) {
                plate (  plates().switch, Cluster, Column, Frame, Key, LED, Plate, Switch, zpos = SwitchPlate_position.z );
            }
        }
    }

    /*				Top Plate				*/
    if ( Plate.Top.visible ) {
        translate ( Plate.Top.position ) {
            color ( Plate.Top.color ) {
                plate ( plates().top, Cluster, Column, Frame, Key, LED, Plate, Switch, zpos = TopPlate_position.z );
            }
        }
    }

    /*				Case Frame				*/
    if ( Frame.visible ) {
        translate ( [ 0, Plate.Switch.edge, 0 ] ) {
            rotate ( [ 0, Halves.angles.y, 0 ] ) {
                rotate ( [ 90, 0, -90 ] ) {
                    color ( Frame.color, 1 ) {
                        frame ( Frame, Halves, Plate );
                    }
                }
            }
        }
    }

    /*				Center Block				*/
    if ( CenterBlock.visible ) {
        color ( CenterBlock.color ) {
            center_block();
        }
    }

    if ( Hinge.visible && include_hinge ) {
        color ( Hinge.color ) {
            translate ( Hinge.Front.position ) {
                hinge (
                    length	= Hinge.Front.length,
                    angle	= Halves.angles.y * 2
                );
            }

            translate ( Hinge.Back.position ) {
                hinge (
                    length	= Hinge.Back.length,
                    angle	= Halves.angles.y * 2,
                    center	= false,
                    front	= false
                );
            }
        }
    }

    /*				Trackball				*/
    if ( Trackball.visible ) {
        translate ( Trackball.position ) {
            trackball ( centers = false );
        }
    }

    if ( Trackball.BTU.visible ) {
        color ( Trackball.BTU.color ) {
            place_btus();
        }
    }

    if ( Trackball.Sensor.visible ) {
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

    if ( MagCon.visible ) {
        translate ( MagCon.position ) {
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
        rotate ( [ 0, 0 + Halves.angles.y, 0 ] ) {
            mcu();
        }
    }

    if ( Battery.visible ) {
        translate ( [ 20, 88, 11.3 ] ) {
            rotate ( [ 0, Halves.angles.y, 0 ] )
            rotate ( [ 0, 90, 100 ] ) {
                battery();
            }
        }
    }

    keys();
}