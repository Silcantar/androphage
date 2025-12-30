/*******************************************************************************\
|																				|
|							Parameters for Androphage keyboard.					|
|								Copyright 2025 Joshua Lucas 					|
|																				|
|	Length Unit:	millimeter													|
|	Angle Unit:		degree														|
|	x-axis name:	"width" 	/	"inner"	- "outer"							|
|	y-axis name:	"depth" 	/	"front"	- "back"							|
|	z-axis name:	"height"	/	"top"		- "bottom"						|
|																				|
\*******************************************************************************/

include <androphage_globals.scad>

/* [Switches] */
// Radius for corners of switch openings in the switch plate.
Switch_radius = 0.5;	//[0:0.1:1]
// Spacing between keys.
Switch_type = "Choc"; //[Choc, MX]

/* [Keys] */
// Space between keycaps.
Key_clearance = 0.5; //[0:0.1:1]
Key_height = 16; //[10:30]

// Test clearance between keycaps and case.
Key_testClearance	= false;

/* [Thumb Cluster] */

// This drives the spacing between the thumb keys.
Cluster_radius	= 6.5; //[0:0.25:10]
// Angle between adjacent thumb keys.
Cluster_angle		= 10; //[0:1:30]
// Number of keys in the inner two thumb columns.
Cluster_columnCounts	= [1, 2, 1];	//[1:2]
// Offset distance of the inner two thumb columns.
Cluster_columnOffsets	= [0, 0, 0];	//[0:0.125:1]

/* [Column Key Counts] */
// Number of keys in the inner index finger column.
Column_inner_count		= 3;	//[1:4]
// Number of keys in the index finger column.
Column_index_count		= 4;	//[1:5]
// Number of keys in the middle finger column.
Column_middle_count	= 4;	//[1:5]
// Number of keys in the ring finger column.
Column_ring_count		= 4;	//[1:5]
// Number of keys in the pinky finger column.
Column_pinky_count		= 3;	//[1:5]
// Number of keys in the outer pinky finger column.
Column_outer_count		= 0;	//[0:5]

/* [Column Offsets] */
// Distance that keys in the inner index finger column are offset depthward.
Column_inner_offset	= 1;	//[1:0.125:2]
// Distance that keys in the index finger column are offset depthward.
Column_index_offset		= 0;	//[-1:0.125:2]
// Distance that keys in the middle finger column are offset depthward.
Column_middle_offset	= 0.5;	//[-1:0.125:2]
// Distance that keys in the ring finger column are offset depthward.
Column_ring_offset		= 0;	//[-1:0.125:2]
// Distance that keys in the pinky finger column are offset depthward.
Column_pinky_offset	= 0.5;	//[-1:0.125:2]
// Distance that keys in the outer pinky finger column are offset depthward.
Column_outer_offset	= 0.5;	//[-1:0.125:2]

/* [Plates] */
// Top plate thickness.
Plate_Top_thickness = 1.6; //[1.0:0.2:2.0]

// Distance from keys to edge of switch plate.
Plate_Switch_edge	= 2; //[1:5]

Plate_Bottom_thickness = 1.6;	//[1:0.2:2]
Plate_Bottom_clearance = 5; //[1:10]

// Radius of the arc at the bottom of the keyboard.
Plate_frontArcRadius = 20;	//[10:50]
// Radius of the arc at the top of the keyboard.
Plate_backArcRadius = 120;	//[50:200]
// Radius of the arc at the lower outside corner of the keyboard.
Plate_outerArcRadius = 20;	//[10:50]

/* [Case Frame] */
CaseFrame_thickness = 3; //[1:5]

/* [Center Block] */
CenterBlock_width = 20; //[1:50]

/* [Hinge] */
// Hinge Length
Hinge_length	= 90;	//[50:1:200]

// Halves Angles
Halves_angles	= [0, 5, 15];	//[-45:45]

/* [Trackball] */
// Trackball diameter
Trackball_diameter = 35; //[25:1:50]
// Trackball position
Trackball_position = 60; //[0:200]
// Trackball sensor size
Trackball_Sensor_Size = [ 22, 23.5, 10 ]; //[0:30]
// Trackball sensor angle
Trackball_Sensor_Angle = 60; //[30:5:90]

/* [Colors] */
Color_primary = [ 0.20, 0.20, 0.20, 1.00 ]; //[0.0:0.01:1.0]
Color_secondary = [ 0.50, 0.30, 0.80, 1.00 ];  //[0.0:0.01:1.0]

include <androphage_objects.scad>

include <androphage_assembly.scad>