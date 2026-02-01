/*******************************************************************************\
|					Magnetic Connector for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

module magnetic_connector (
    // magcon,
    include_cut	= false,
    pcb_color	= "DarkGreen",
) {
    dim = [
        MagCon_size,
        MagCon_lip,
        MagCon_size + [ 2 * $eps, 0, 0 ],
        MagCon_lip + [ $eps, 0, 0 ],
    ];

    dist = [
        [ MagCon_size.x / 2, 0, 0 ],
        [ MagCon_lip.x / 2 + MagCon_lipOffset, 0, 0 ],
        [ MagCon_size.x / 2, 0, 0 ],
        [ MagCon_lip.x / 2 + MagCon_lipOffset + $eps, 0, 0 ]
    ];

    color ( MagCon_color ) {
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
    color ( PCB_color ) {
        translate ( MagCon_pcbPosition ) {
            cube ( MagCon_pcbSize, center = true);
        }
    }
}