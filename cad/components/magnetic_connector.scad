/*******************************************************************************\
|					Magnetic Connector for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../globals.scad>

if ( is_undef ( $parent_modules ) ) {
    include <../androphage.scad>

    magnetic_connector (
        MagCon,
        include_cut	= true,
        pcb_color	= PCB.color,
    );
}

module magnetic_connector (
    magcon,
    include_cut	= false,
    pcb_color	= "DarkGreen",
) {
    dim = [
        magcon.size,
        magcon.lip,
        magcon.size + [ 2 * eps, 0, 0 ],
        magcon.lip + [ eps, 0, 0 ],
    ];

    dist = [
        [ magcon.size.x / 2, 0, 0 ],
        [ magcon.lip.x / 2 + magcon.lipOffset, 0, 0 ],
        [ magcon.size.x / 2, 0, 0 ],
        [ magcon.lip.x / 2 + magcon.lipOffset + eps, 0, 0 ]
    ];

    color ( magcon.color ) {
        for ( i = include_cut ? [ 0 : 3 ] : [ 0 : 1 ] ) {
            translate ( dist[i] ) {
                cube ( dim[i] - [ 0, dim[i].z, 0 ], center = true );

                for ( dir = [ -1, 1 ] ) {
                    translate ( [ 0, dir * ( dim[i].y - dim[i].z ) / 2, 0 ] ) {
                        rotate ( [ 0, 90, 0 ] ) {
                            cylinder ( d = dim[i].z, h = dim[i].x, center = true );
                        }
                    }
                }
            }
        }
    }

    // VIK PCB
    color ( pcb_color ) {
        translate ( magcon.pcbPosition ) {
            cube ( magcon.pcbSize, center = true);
        }
    }
}

magnetic_connector();