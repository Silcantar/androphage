/*******************************************************************************\
|						PCB model for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <../androphage.scad>

use <plate_sketch.scad>

module pcb ( zpos = 7 ) {
	place_plate ( zpos ) {
		linear_extrude (height = Dimensions().PCB.thickness) {
			difference () {
				// offset ( delta = Dimensions().Plate.Switch.edge ) {
					plate_sketch ( zpos );
				// }
			};
		}
	}
}

pcb ( );