/*******************************************************************************\
|						PCB model for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <switch_plate.scad>

module pcb (
	edge		= PCB_edge,
	thickness	= PCB_thickness,
	zpos		= PCB_position.z,
) {
	switch_plate (
		PCB			= true,
		edge		= edge,
		thickness	= thickness,
		zpos		= zpos
	);
}

pcb();