/*******************************************************************************\
|						PCB model for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <plate_sketch.scad>

module pcb ( dimensions ) {
	linear_extrude (height = dimensions.PCB.thickness) {
		difference () {
			offset ( delta = dimensions.Plate.Switch.edge ) {
				plate_sketch ( dimensions );
			}
		};
	}
}

use <../androphage.scad>

pcb ( Dimensions() );