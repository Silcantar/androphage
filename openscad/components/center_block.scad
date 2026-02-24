/*******************************************************************************\
|						Center block for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../library/screw.scad>
use <../library/test.scad>
use <../library/utility.scad>

module center_block (
    include_cut = false,
) {
    // Put a cube with a corner at the origin so we can measure from it.
    ct() { nothing(); cube(); }

    difference () {
        // Main Body
        union () {
            ch() _center_wall();

            _pcb_shelf ();

            _sensor_holder ( include_cut = include_cut );

            place_insert_holes () {
                ch() screw_boss();
            }

            _trackball_case();

            place_btus () {
                _btu_case();
            }

            // Test insert hole placement.
            ct () {
                nothing ();

                place_insert_holes () {
                    color ( "green" ) {
                        _insert_holes();
                    }
                }
            }
        }

        if ( !include_cut ){
            // Subtract the openings for the trackball BTUs.
            place_btus () {
                btu ( include_cut = true );
            }

            // Subtract the holes for the heat-set inserts.
            ct () {
                place_insert_holes () {
                    _insert_holes();
                }
            }

            // Subtract the opening for the magnetic connector.
            translate ( MagCon_position ) {
                magnetic_connector ( include_cut = true );


                // Holes for magnetic connector screws.
                for ( ypos = ( 0.5 * MagCon_lip.y + Screw_diameter) * [ 1, -1 ] ) {
                    translate ( [ -$eps, ypos, 0 ] ) {
                        rotate ( [ 0, -90, 0 ] ) {
                            screw (
                                diameter	= Screw_diameter,
                                length		= 5,
                                head		= "flat"
                            );
                        }
                    }
                }
            }
        }

        _center_face();

        _hinges();

        cb() _plates();

        place_sensor () {
            trackball_sensor ( include_cut = true );
        }

        _trackball();
    }

    if ( include_cut ) {
        color ( Color_cut ) {
            // Fill the trackball case if we are using this to cut other components.
            _trackball ( diameter = Trackball_diameter + 2 * $eps );

            // Also create a cube to make clearance for the trackball sensor, etc.
            _cut_cube_size = [
                50,
                Trackball_diameter,
                35
            ];
            place_sensor () {
                translate ( [ 0, 0, -7 ] ) {
                    cube ( _cut_cube_size, center = true );
                }
            }
        }
    }
}

/*******************************************************************************\
|								Additive Features								|
\*******************************************************************************/

module _btu_case () {
    BTU_case_height = Trackball_BTU_L + Trackball_BTU_H + CenterBlock_wallThickness;

    translate ( [ 0, 0, -BTU_case_height ] ) {
        difference () {
            cylinder (
                d = Trackball_BTU_D1 + CenterBlock_wallThickness,
                h = BTU_case_height
            );

            cylinder (
                d = Screw_minorDiameter,
                h = 2 * ( BTU_case_height + $eps ),
                center = true
            );
        }
    }
}

module _center_wall () {
    translate ( [ -$eps, -TopPlate_edge ] ) {
        difference () {
            // Main body
            cube ( [
                CenterBlock_wallThickness + CenterBlock_ribSize.y + $eps,
                Hinge_length + 2 * TopPlate_edge,
                CenterBlock_height
            ] );

            // Subtract the part that is not the ribs.
            translate ( [
                CenterBlock_wallThickness,
                CenterBlock_ribSize.x,
                (
                    BottomPlate_thickness
                    + CenterBlock_ribSize.x
                    - CenterBlock_wallThickness * sin ( Halves_angles.y )
                ),
            ] ) {
                cube ( [
                    CenterBlock_ribSize.y + 2 * $eps,
                    Hinge_length + 2 * TopPlate_edge - 2 * CenterBlock_ribSize.x,
                    (
                        CenterBlock_height
                        - BottomPlate_thickness
                        - 2 * CenterBlock_ribSize.x
                    )
                ] );
            }
        }
    }
}

module _pcb_shelf () {
    translate ( [ 0, 0, BottomPlate_thickness - $eps ] ) {
        rotate ( [ 0, Halves_angles.y, 0 ] ) {
            cube ( [ 5, Hinge_length, BottomPlate_clearance + $eps ] );
        }
    }
}

module screw_boss () {
    d = Insert_holeDiameter + 2 * Insert_wallThickness;
    h = 1.1 * CenterBlock_height;

    translate ( [ 0, 0, BottomPlate_thickness ] ) {
        rotate ( [ 0, Halves_angles.y, 180 ] ) {
            translate ( [ 0, 0, -h / 10 ] ) {
                cylinder ( d = d, h = h );

                translate ( [ 0, -d / 2, 0 ] ) {
                    cube ( [ d, d, h ] );
                }
            }
        }
    }
}

module _sensor_holder(
    include_cut							= false,
    vblock_extra						= 10,
) {
    hblock_size = [
        Trackball_Sensor_holderThickness,
        Trackball_Sensor_pcbSize.y + CenterBlock_wallThickness,
        Trackball_Sensor_holderHeight
    ];

    vblock_size = [
        Trackball_Sensor_pcbSize.x + CenterBlock_wallThickness + vblock_extra,
        Trackball_Sensor_holderThickness,
        Trackball_Sensor_holderHeight
    ];

    rot_offset = (
        - Trackball_Sensor_holderHeight / 2
        + Trackball_diameter / 2
        + Trackball_Sensor_clearance
        + Trackball_Sensor_lensSize.z
        + Trackball_Sensor_pcbSize.z
    );

    translate ( Trackball_position ) {
        rotate ( [ 0, 180 - Trackball_Sensor_angle, 0 ] ) {
            translate (
                v_mul(
                    (
                        Trackball_Sensor_pcbSize / 2
                        - Trackball_Sensor_opticalCenter
                    ),
                    [1, 1, 0]
                ) +
                [ 0, 0, rot_offset ]
            ) {
                cube ( hblock_size, center = true );
                translate ( [ vblock_extra / 2, 0, 0] ) {
                    cube ( vblock_size, center = true );
                }
            }
        }
    }
}

module _trackball_case () {
    d = (
        Trackball_diameter
        + 2 * (
            Trackball_clearance
            + CenterBlock_wallThickness
        )
    );

    translate ( Trackball_position ) {
        rotate ( [ 90, 0, 0 ] ) { rotate ( [ 0, 0, -90 ] ) {
            // Extruding 90 degrees is fine because we're going to cut this
            // feature using the _plates feature anyway and extruding the
            // proper angle causes z-fighting.
            rotate_extrude ( angle = 90 ) {
                difference () {
                    circle ( d = d );

                    translate ( [ -d, -d / 2, 0 ] ) {
                        square ( d + 2 * $eps );
                    }
                }
            }
        } }
    }
}

/*******************************************************************************\
|								Subtractive Features							|
\*******************************************************************************/

module place_btus () {
    translate ( Trackball_position ) {
        // BTUs
        for ( zrot = -90 * [ 1, 1 ] + Trackball_BTU_angles.z * [ -1, 1 ] ) {
            rotate ( [ Trackball_BTU_angles.x, 0, zrot ] ) {
                translate ( [ 0, 0, -Trackball_diameter / 2 ] ) {
                    children();
                }
            }
        }
    }
}

module _hinges () {
    rotate ( [ 0, Halves_angles.y, 0 ] ) {
        ypos = [
            -TopPlate_edge - $eps,
            Hinge_length - Hinge_Back_length + TopPlate_edge
        ];
        ydim = [
            Hinge_Front_length + $eps,
            Hinge_Back_length + $eps,
        ];

        for ( i = [ 0 : 1 ] ) {
            translate ( [ -5, ypos[i], TopPlate_position.z - Hinge_leafThickness * Hinge_scale ] ) {
                cube ( [ 15, ydim[i], Hinge_leafThickness * Hinge_scale + $eps ] );
            }
        }
    }
}

module _insert_holes () {
    translate ( [ 0, 0, BottomPlate_thickness ] ) {
        rotate ( [ 0, Halves_angles.y, 0 ] ) {
            for ( zpos = [
                -$eps,
                (
                    CenterBlock_height
                    - Insert_holeDepth
                    - BottomPlate_thickness
                    + $eps
                ) * ( cos ( Halves_angles.y ) ),

            ] ){
                translate ( [
                    0,
                    0,
                    zpos
                ] ) {
                    cylinder (
                        d = Insert_holeDiameter,
                        h = Insert_holeDepth + $eps
                    );
                }
            }
        }
    }
}

module place_insert_holes () {
    // for ( i = [ 0 : CenterBlock_screwCount - 1 ] ) {
    //     translate ( screw_positions_translated()[i] + [
    //         0,
    //         0,
    //         -screw_positions_translated()[i].x * sin ( Halves_angles.y )
    //     ] ) {
    //         children();
    //     }
    // }
}

module _center_face () {
    size = [ 10, 110, 25 ];
    // Center face.
    translate ( [ -size.x, -size.y / 10, 0 ] ) {
        cube ( size );
    }
}

module _plates () {
    // Top and bottom faces.
    size = [ 30, 110, 10 ];
    zpos1 = [ TopPlate_position.z, BottomPlate_thickness ];
    zpos2 = [ 0, -size.z ];
    for ( i = [ 0 : 1 ] ) {
        translate ( [ 0, 0, zpos1[i] ] ) {
            rotate ( [ 0, Halves_angles.y, 0 ] ) {
                translate ( [ -size.x / 10, -size.y / 10, zpos2[i] ] ) {
                    cube ( size );
                }
            }
        }
    }
}

module place_sensor () {
    translate ( Trackball_position ) {

        // Trackball sensor board
        rotate ( [ 0, 180 - Trackball_Sensor_angle, 0 ] ) {
            translate ( [ 0, 0, Trackball_diameter / 2 ] ) {
                children();
            }
        }
    }
}

module _trackball ( diameter ) {
    diameter2 = is_undef ( diameter ) ? Trackball_diameter : diameter;
    translate ( Trackball_position ) {
        // Subtract Trackball + clearance.
        sphere ( d = (
            diameter2
            + 2 * Trackball_clearance
        ) );
    }
}