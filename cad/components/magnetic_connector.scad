/*******************************************************************************\
|					Magnetic Connector for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

module magnetic_connector (
	include_cut	= false,
	lip			= MagCon_lip,
	lipOffset	= MagCon_lipOffset,
	size		= MagCon_size
) {
	dim = [ 
		size, 
		lip, 
		size + [ 2 * eps, 0, 0 ], 
		lip + [ eps, 0, 0 ],
	];

	dist = [ 
		[ size.x / 2, 0, 0 ], 
		[ lip.x / 2 + lipOffset, 0, 0 ],
		[ size.x / 2, 0, 0 ],
		[ lip.x / 2 + lipOffset + eps, 0, 0 ]
	];

	for ( i = include_cut ? [ 0 : 3 ] : [ 0 : 1 ] ) {
		translate ( dist[i] ) {
			cube ( dim[i] - [ 0, dim[i].z, 0 ], center = true );

			for ( dir = [ -1, 1 ] ) {
				translate ( [ 0, dir * (dim[i].y - dim[i].z) / 2, 0 ] ) {
					rotate ( [ 0, 90, 0 ] ) {
						cylinder ( d = dim[i].z, h = dim[i].x, center = true );
					}
				}
			}
		}
	}

}

magnetic_connector();