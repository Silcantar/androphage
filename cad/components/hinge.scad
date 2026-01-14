/*******************************************************************************\
|							Hinge for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <../library/piano_hinge.scad>

module hinge (
	length,
	angle	= 0,
	center	= true
) {
	piano_hinge (
		angle			= angle,
		center			= center,
		length			= length,
		clearance		= eps,
		diameter		= Hinge_diameter, 
		knuckleLength	= Hinge_knuckleDepth,
		leafThickness	= Hinge_size.z,
		leafWidth		= Hinge_size.x,
		pinDiameter		= Hinge_pinDiameter
	);
}