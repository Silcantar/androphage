/*******************************************************************************\
|                       Key placement for Androphage keyboard.                  |
|                            Copyright 2026 Joshua Lucas                        |
\*******************************************************************************/

// include <../globals.scad>

use <../library/fillet.scad>
use <../library/math.scad>
use <../library/path.scad>

// if ( is_undef ( ANDROPHAGE_MAIN ) ) {

//     place_key_holes ( Frame, Key, Plate ) {
//         key_holes (
//             Cluster,
//             Column,
//             Key,
//             Switch,
//             connect = true,
//             cutout  = 0
//         );
//     }
// }

// Create the holes for either the switches in the switch mounting plate or the
// keys in the top plate.
module key_holes (
    // cluster,
    // column,
    // key,
    // switch,
    connect = false,
    cutout  = 0,
) {
    key_positions = key_positions();

    for ( p = key_positions ) {
        translate ( p.position ) {
            rotate ( p.angle ){
                key_hole (
                    radius  = connect ? 0 : Switch.radius,
                    size    = connect ? Key.spacing : Switch.size,
                    cutout  = p.cutout,
                );

                //
                if ( p.connect ) {
                    key_hole_connector ( /*Cluster.angle, Key.spacing.y, key*/ );
                }
            }
        }
    }

    // Hole connector between thumb cluster and inner index column.
    if ( connect ) {
        translate ( v_mul ( Key.spacing, [ -0.5, 0.5 ] ) ) {
            rotate ( 90 + Cluster.angle ) {
                key_hole_connector (
                    // Cluster.angle,
                    // Key.spacing.x,
                    // Key,
                    do_translate = false,
                );
            }
        }
    }
}

module place_key_holes ( /*frame, key, plate*/ ) {
    path = [ for ( i = [ 17 : -1 : 10 ] ) Frame.path[i] ];
    translate_on_path (
        path,
        rad_axis = -axis.y,
        rot_axis = axis.z,
        trans_axis = -axis.x
    ) {
        translate ( [ 0, Key.spacing.y / 2 + Plate.Switch.edge ] ) {
            children();
        }
    }
}

function key_positions (
    // cluster,
    // column,
    // key,
    connect = false,
    cutout = 0,
) = concat (
    finger_key_positions(),
    thumb_key_positions(),
);

// Calculate the coordinates of the center and additional properties of each
// finger key.
function finger_key_positions (
    // column,
    // key,
) = [
    for (
        i = [ 0 : Column.last ],
        j = [ 0 : Column.counts[i] - 1 ]
    ) (
        let (
            position = [
                ( i - 1 ) * Key.spacing.x,
                ( j + Column.offsets[i] ) * Key.spacing.y
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
    // cluster,
    // key,
    connect = false,
    cutout = 0,
) = [
    for (
        i = [ 0 : len ( Cluster.columnCounts ) - 1 ],
        j = [ 0 : Cluster.columnCounts[i] - 1 ]
    ) (
        let (
            position = rot2d ( i * Cluster.angle ) * (
                [ 0, ( j + Cluster.columnOffsets[i] ) * Key.spacing.y ]
                + [ 0, Cluster.radius_mm ]
            )
            + [ 0, -Cluster.radius_mm ],
            angle = i * Cluster.angle,
            connect = connect && j == 0 && i != 0,
            cutout = ( j == 0 && ( i != 0 || Cluster.fiveThumbKeys ) ) ? cutout : 0,
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
    // key,
    do_translate = true,
) {
    trans_factor = do_translate ? [ 0.5, -0.5 ] : [ 0, 0 ];
    translate ( v_mul ( Key.spacing, trans_factor ) ) {
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