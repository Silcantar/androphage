/*******************************************************************************\
|                       Key placement for Androphage keyboard.                  |
|                            Copyright 2026 Joshua Lucas                        |
\*******************************************************************************/

include <../globals.scad>

use <../library/fillet.scad>
use <../library/math.scad>
use <../library/path.scad>

if ( is_undef ( $parent_modules ) ) {
    include <../androphage.scad>

    place_key_holes ( Frame, Key, Plate ) {
        key_holes (
            Cluster,
            Column,
            Key,
            Switch,
            connect = true,
            cutout  = 0
        );
    }
}

// Create the holes for either the switches in the switch mounting plate or the 
// keys in the top plate.
module key_holes (
    cluster,
    column,
    key,
    switch,
    connect = false,
    cutout  = 0,
) {
    key_positions = key_positions ( cluster, column, key, connect, cutout );

    for ( p = key_positions ) {
        translate ( p.position ) {
            rotate ( p.angle ){
                key_hole (
                    radius  = connect ? 0 : switch.radius,
                    size    = connect ? key.spacing : switch.size,
                    cutout  = p.cutout,
                );

                // 
                if ( p.connect ) {
                    key_hole_connector ( cluster.angle, key.spacing.y, key );
                }
            }
        }
    }

    // Hole connector between thumb cluster and inner index column.
    if ( connect ) {
        translate ( v_mul ( key.spacing, [ -0.5, 0.5 ] ) ) {
            rotate ( 90 + cluster.angle ) {
                key_hole_connector ( 
                    cluster.angle, 
                    key.spacing.x, 
                    key, 
                    do_translate = false,
                );
            }
        }
    }
}

module place_key_holes ( frame, key, plate ) {
    path = [ for ( i = [ 17 : -1 : 10 ] ) frame.path[i] ];
    translate_on_path ( 
        path, 
        rad_axis = -axis.y, 
        rot_axis = axis.z, 
        trans_axis = -axis.x 
    ) {
        translate ( [ 0, key.spacing.y / 2 + plate.Switch.edge ] ) {
            children();
        }
    }
}

function key_positions (
    cluster,
    column,
    key,
    connect = false,
    cutout = 0,
) = concat (
    finger_key_positions ( column, key ),
    thumb_key_positions ( cluster, key, connect, cutout ),
);

// Calculate the coordinates of the center and additional properties of each
// finger key.
function finger_key_positions (
    column,
    key,
) = [ 
    for ( 
        i = [ 0 : column.last ], 
        j = [ 0 : column.counts[i] - 1 ] 
    ) (
        let (
            position = [
                ( i - 1 ) * key.spacing.x,
                ( j + column.offsets[i] ) * key.spacing.y
            ]
        ) (
            object ( [
                [ "position",   position    ],
                [ "angle",      0           ],
                [ "connect",    false       ],
                [ "cutout",     0           ],
            ] )
        )
    )
];

// Calculate the coordinates of the center and additional properties of each
// thumb key.
function thumb_key_positions (
    cluster,
    key,
    connect = false,
    cutout = 0,
) = [
    for (
        i = [ 0 : len ( cluster.columnCounts ) - 1 ],
        j = [ 0 : cluster.columnCounts[i] - 1 ]
    ) (
        let (
            position = rot2d ( i * cluster.angle ) * ( 
                [ 0, ( j + cluster.columnOffsets[i] ) * key.spacing.y ]
                + [ 0, cluster.radius_mm ]
            )
            + [ 0, -cluster.radius_mm ],
            angle = i * cluster.angle,
            connect = connect && j == 0 && i != 0,
            cutout = ( j == 0 && ( i != 0 || cluster.fiveThumbKeys ) ) ? cutout : 0,
        ) (
            object ( [
                [ "position",   position    ],
                [ "angle",      angle       ],
                [ "connect",    connect     ],
                [ "cutout",     cutout      ],
            ] )
        )
    )
];

module key_hole (
    radius,
    size,
    cutout	= 0,
) {
    fillet2d ( radius ) {
        translate ( [ 0, -cutout / 2, 0 ] ) {
            square ( size + [ 0, cutout ], center = true );
        }
    }
}

module key_hole_connector (
    angle,
    radius,
    key,
    do_translate = true,
) {
    trans_factor = do_translate ? [ 0.5, -0.5 ] : [ 0, 0 ];
    translate ( v_mul ( key.spacing, trans_factor ) ) {
        difference () {
            circle ( r = radius );

            xpos = [ -4 * radius, 0 ];
            angle_multiplier = [ 0, -1 ];
            for ( i = [ 0 : 1 ] ) {
                rotate ( [ 0, 0, angle * angle_multiplier[i] ] ) {
                    translate ( [ xpos[i], -2 * radius ] ) {
                        square ( 4 * radius );
                    }
                }
            }
        }
    }
}