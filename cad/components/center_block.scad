/*******************************************************************************\
|						Center block for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../library/screw.scad>
use <../library/test.scad>

if ( is_undef ( ANDROPHAGE_MAIN ) ) {
    center_block ( include_cut = false );
}

module center_block (
    // centerBlock,
    // magCon,
    // screw,
    // trackball,
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
            translate ( MagCon.position ) {
                magnetic_connector ( include_cut = true );


                // Holes for magnetic connector screws.
                for ( ypos = ( 0.5 * MagCon.lip.y + Screw.diameter) * [ 1, -1 ] ) {
                    translate ( [ -eps, ypos, 0 ] ) {
                        rotate ( [ 0, -90, 0 ] ) {
                            screw (
                                diameter	= Screw.diameter,
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
            _trackball ( diameter = Trackball.diameter + 2 * eps );

            // Also create a cube to make clearance for the trackball sensor, etc.
            _cut_cube_size = [
                50,
                Trackball.diameter,
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

module _btu_case (
    // centerBlock,
    // screw,
    // trackball,
) {
    BTU_case_height = Trackball.BTU.L + Trackball.BTU.H + CenterBlock.wallThickness;

    translate ( [ 0, 0, -BTU_case_height ] ) {
        difference () {
            cylinder (
                d = Trackball.BTU.D1 + CenterBlock.wallThickness,
                h = BTU_case_height
            );

            cylinder (
                d = Screw.minorDiameter,
                h = 2 * ( BTU_case_height + eps ),
                center = true
            );
        }
    }
}

module _center_wall (
    // centerBlock,
    // halves,
    // hinge,
    // plate,
) {
    translate ( [ -eps, -Plate.Top.edge ] ) {
        difference () {
            // Main body
            cube ( [
                CenterBlock.wallThickness + CenterBlock.ribSize.y + eps,
                Hinge.size.y + 2 * Plate.Top.edge,
                CenterBlock.height
            ] );

            // Subtract the part that is not the ribs.
            translate ( [
                CenterBlock.wallThickness,
                CenterBlock.ribSize.x,
                (
                    Plate.Bottom.thickness
                    + CenterBlock.ribSize.x
                    - CenterBlock.wallThickness * sin ( halves.angles.y )
                ),
            ] ) {
                cube ( [
                    CenterBlock.ribSize.y + 2 * eps,
                    Hinge.size.y + 2 * Plate.Top.edge - 2 * CenterBlock.ribSize.x,
                    (
                        CenterBlock.height
                        - Plate.Bottom.thickness
                        - 2 * CenterBlock.ribSize.x
                    )
                ] );
            }
        }
    }
}

module _pcb_shelf (
    // halves,
    // hinge,
    // plate,
) {
    translate ( [ 0, 0, Plate.Bottom.thickness - eps ] ) {
        rotate ( [ 0, Halves.angles.y, 0 ] ) {
            cube ( [ 5, Hinge.size.y, Plate.Bottom.clearance + eps ] );
        }
    }
}

module screw_boss (
    // centerBlock,
    // halves,
    // insert,
    // plate,
) {
    d = Insert.holeDiameter + 2 * Insert.wallThickness;
    h = 1.1 * CenterBlock.height;

    translate ( [ 0, 0, Plate.Bottom.thickness ] ) {
        rotate ( [ 0, Halves.angles.y, 180 ] ) {
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
    // centerBlock,
    // trackball,
    include_cut							= false,
    vblock_extra						= 10,
) {
    hblock_size = [
        Trackball.Sensor.holderThickness,
        Trackball.Sensor.pcbSize.y + CenterBlock.wallThickness,
        Trackball.Sensor.holderHeight
    ];

    vblock_size = [
        Trackball.Sensor.pcbSize.x + CenterBlock.wallThickness + vblock_extra,
        Trackball.Sensor.holderThickness,
        Trackball.Sensor.holderHeight
    ];

    rot_offset = (
        - Trackball.Sensor.holderHeight / 2
        + Trackball.diameter / 2
        + Trackball.Sensor.clearance
        + Trackball.Sensor.lensSize.z
        + Trackball.Sensor.pcbSize.z
    );

    translate ( Trackball.position ) {
        rotate ( [ 0, 180 - Trackball.Sensor.angle, 0 ] ) {
            translate (
                v_mul(
                    (
                        Trackball.Sensor.pcbSize / 2
                        - Trackball.Sensor.opticalCenter
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

module _trackball_case (
    // centerBlock,
    // halves,
    // trackball,
) {
    d = (
        Trackball.diameter
        + 2 * (
            Trackball.clearance
            + CenterBlock.wallThickness
        )
    );

    translate ( Trackball.position ) {
        rotate ( [ 90, 0, 0 ] ) { rotate ( [ 0, 0, -90 ] ) {
            // Extruding 90 degrees is fine because we're going to cut this
            // feature using the _plates feature anyway and extruding the
            // proper angle causes z-fighting.
            rotate_extrude ( angle = 90 ) {
                difference () {
                    circle ( d = d );

                    translate ( [ -d, -d / 2, 0 ] ) {
                        square ( d + 2 * eps );
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
    translate ( Trackball.position ) {
        // BTUs
        for ( zrot = [ -45, -135 ] ) {
            rotate ( [ 45, 0, zrot ] ) {
                translate ( [ 0, 0, -Trackball.diameter / 2 ] ) {
                    children();
                }
            }
        }
    }
}

module _hinges (
    // halves,
    // hinge,
    // plate,
) {
    rotate ( [ 0, Halves.angles.y, 0 ] ) {
        ypos = [
            -Plate.Top.edge - eps,
            Hinge.size.y - Hinge.Back.length + Plate.Top.edge
        ];
        ydim = [
            Hinge.Front.length + eps,
            Hinge.Back.length + eps,
        ];

        for ( i = [ 0 : 1 ] ) {
            translate ( [ -5, ypos[i], Plate.Top.position.z - Hinge.size.z ] ) {
                cube ( [ 15, ydim[i], Hinge.size.z + eps ] );
            }
        }
    }
}

module _insert_holes (
    // centerBlock,
    // halves,
    // insert,
    // plate,
) {
    translate ( [ 0, 0, Plate.Bottom.thickness ] ) {
        rotate ( [ 0, Halves.angles.y, 0 ] ) {
            for ( zpos = [
                -eps,
                (
                    CenterBlock.height
                    - Insert.holeDepth
                    - Plate.Bottom.thickness
                    + eps
                ) * ( cos ( Halves.angles.y ) ),

            ] ){
                translate ( [
                    0,
                    0,
                    zpos
                ] ) {
                    cylinder (
                        d = Insert.holeDiameter,
                        h = Insert.holeDepth + eps
                    );
                }
            }
        }
    }
}

module place_insert_holes () {
    for ( i = [ 0 : CenterBlock.screwCount - 1 ] ) {
        translate ( screw_positions_translated()[i] + [
            0,
            0,
            -screw_positions_translated()[i].x * sin ( Halves.angles.y )
        ] ) {
            children();
        }
    }
}

module _center_face () {
    size = [ 10, 110, 25 ];
    // Center face.
    translate ( [ -size.x, -size.y / 10, 0 ] ) {
        cube ( size );
    }
}

module _plates (
    // centerBlock,
    // halves,
) {
    // Top and bottom faces.
    size = [ 30, 110, 8 ];
    zpos1 = [ CenterBlock.height, Plate.Bottomthickness ];
    zpos2 = [ 0, -size.z ];
    for ( i = [ 0 : 1 ] ) {
        translate ( [ 0, 0, zpos1[i] ] ) {
            rotate ( [ 0, Halves.angles.y, 0 ] ) {
                translate ( [ -size.x / 10, -size.y / 10, zpos2[i] ] ) {
                    cube ( size );
                }
            }
        }
    }
}

module place_sensor () {
    translate ( Trackball.position ) {

        // Trackball sensor board
        rotate ( [ 0, 180 - Trackball.Sensor.angle, 0 ] ) {
            translate ( [ 0, 0, Trackball.diameter / 2 ] ) {
                children();
            }
        }
    }
}

module _trackball ( diameter ) {
    diameter2 = is_undef ( diameter ) ? Trackball.diameter : diameter;
    translate ( Trackball.position ) {
        // Subtract Trackball + clearance.
        sphere ( d = (
            diameter2
            + 2 * Trackball.clearance
        ) );
    }
}