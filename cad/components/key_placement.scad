/*******************************************************************************\
|                       Key placement for Androphage keyboard.                  |
|                            Copyright 2026 Joshua Lucas                        |
\*******************************************************************************/

use <../library/fillet.scad>
use <../library/math.scad>
use <../library/path.scad>

// Create the holes for either the switches in the switch mounting plate or the
// keys in the top plate.
module key_holes (
    connect = false,
    cutout  = 0,
) {
    key_positions = key_positions( connect, cutout );

    for ( p = key_positions ) {
        translate ( p.position ) {
            rotate ( p.angle ){
                key_hole (
                    radius  = connect ? 0 : Switch_radius,
                    size    = connect ? Key_spacing : Switch_size,
                    cutout  = p.cutout,
                );

                //
                if ( p.connect ) {
                    key_hole_connector ( Cluster_angle, Key_spacing.y );
                }
            }
        }
    }

    // Hole connector between thumb cluster and inner index column.
    if ( connect ) {
        translate ( v_mul ( Key_spacing, [ -0.5, 0.5 ] ) ) {
            rotate ( 90 + Cluster_angle ) {
                key_hole_connector (
                    Cluster_angle,
                    Key_spacing.x,
                    // Key,
                    do_translate = false,
                );
            }
        }
    }
}

module place_key_holes () {
    path = [ for ( i = [ 17 : -1 : 10 ] ) Frame_path[i] ];
    translate_on_path (
        path,
        rad_axis = -axis.y,
        rot_axis = axis.z,
        trans_axis = -axis.x
    ) {
        translate ( [ -SwitchPlate_edge - 1, Key_spacing.y / 2 + SwitchPlate_edge ] ) {
            children();
        }
    }
}

function key_positions (
    connect = false,
    cutout = 0,
) = concat (
    finger_key_positions(),
    thumb_key_positions( connect, cutout ),
);

// Calculate the coordinates of the center and additional properties of each
// finger key.
function finger_key_positions () = [
    for (
        i = [ 0 : Column_last ],
        j = [ 0 : Column_counts[i] - 1 ]
    ) (
        let (
            position = [
                ( i - 1 ) * Key_spacing.x,
                ( j + Column_offsets[i] ) * Key_spacing.y
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
    connect = false,
    cutout = 0,
) = [
    for (
        i = [ 0 : len ( Cluster_columnCounts ) - 1 ],
        j = [ 0 : Cluster_columnCounts[i] - 1 ]
    ) (
        let (
            position = rot2d ( i * Cluster_angle ) * (
                [ 0, ( j + Cluster_columnOffsets[i] ) * Key_spacing.y ]
                + [ 0, Cluster_radius_mm ]
            )
            + [ 0, -Cluster_radius_mm ],
            angle = i * Cluster_angle,
            connect = connect && j == 0 && i != 0,
            cutout = ( j == 0 && ( i != 0 || Cluster_fiveThumbKeys ) ) ? cutout : 0,
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
    do_translate = true,
) {
    trans_factor = do_translate ? [ 0.5, -0.5 ] : [ 0, 0 ];
    translate ( v_mul ( Key_spacing, trans_factor ) ) {
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