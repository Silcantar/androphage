/*******************************************************************************\
|					Magnetic Connector for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

if ( is_undef ( ANDROPHAGE_MAIN ) ) {
    magnetic_connector (
        // MagCon,
        include_cut	= true,
        pcb_color	= PCB.color,
    );
}

module magnetic_connector (
    // magcon,
    include_cut	= false,
    pcb_color	= "DarkGreen",
) {
    dim = [
        MagCon.size,
        MagCon.lip,
        MagCon.size + [ 2 * eps, 0, 0 ],
        MagCon.lip + [ eps, 0, 0 ],
    ];

    dist = [
        [ MagCon.size.x / 2, 0, 0 ],
        [ MagCon.lip.x / 2 + MagCon.lipOffset, 0, 0 ],
        [ MagCon.size.x / 2, 0, 0 ],
        [ MagCon.lip.x / 2 + MagCon.lipOffset + eps, 0, 0 ]
    ];

    color ( MagCon.color ) {
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
    color ( PCB.color ) {
        translate ( MagCon.pcbPosition ) {
            cube ( MagCon.pcbSize, center = true);
        }
    }
}