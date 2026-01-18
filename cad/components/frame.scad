/*******************************************************************************\
|						Case frame for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <plates_common.scad>

use <center_block.scad>

module frame () {
	intersection () {
		union () {
			linear_extrude ( h = Frame_height, convexity = 2 ) {
				difference () {
					fillet2d ( radius = Plate_outerRadius) {
						offset ( delta = TopPlate_edge ) {
							plate_sketch();
						}
					}

					fillet2d ( radius = TopPlate_innerRadius ) {
						offset ( delta = TopPlate_edge - Frame_thickness ) {
							plate_sketch();
						}
					}
				}
			}

			_screw_positions = screw_positions();
			_screw_rotations = screw_rotations();

			for ( i = [ 3 : last ( _screw_positions ) ] ) {
				translate ( _screw_positions[i] ) {
					rotate ( _screw_rotations[i] ) {
						difference () {
							screw_boss ( angle = 0 );

							for ( zpos = [ 0, Frame_height - Insert_holeDepth ] ) {
								translate ( [ 0, 0, zpos ] ) {
									cylinder ( d = Insert_holeDiameter, h = Insert_holeDepth );
								}
							}
						}
					}
				}
			}
		}

		linear_extrude ( h = Frame_height ) {
			fillet2d ( radius = Plate_outerRadius) {
				offset ( delta = TopPlate_edge ) {
					plate_sketch();
				}
			}
		}
	}
}

frame();