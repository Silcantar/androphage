/*******************************************************************************\
|																				|
|						Parameters for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
|																				|
|	Length Unit:	millimeter													|
|	Angle Unit:		degree														|
|																				|
|	* Terminology *																|
|		x-axis name:	"width" 	/	"inner"	- "outer"						|
|		y-axis name:	"depth" 	/	"front"	- "back"						|
|		z-axis name:	"height"	/	"top"	- "bottom"						|
|																				|
|		"center": between the halves.											|
|		"middle": in the middle of a given half (i.e. near the middle finger).	|
|																				|
|	* Naming Conventions *														|
|		Modules & Functions:	snake_case										|
|			Example:	module center_block ( ... ) { ... }						|
|		Global Variables:		PascalCaseObject_camelCaseProperty				|
|			Example:	CenterBlock_wallThickness								|
|		Function parameters:	camelCaseObject_camelCaseProperty				|
|																				|
|	Prepend an underscore for local-scope items.								|
|																				|
\*******************************************************************************/

//include <BOSL2/std.scad>
// include <BOSL2/vectors.scad>

/* [Hidden] */
ANDROPHAGE_GLOBALS = true;

// Rendering parameters.
$fa = $preview ? 10 : 1;
$fs = $preview ? 1	: 0.1;

// Very small amount.
eps = 0.01;

// "Enum" of fingers/columns.
inner	= 0;
index	= 1;
middle	= 2;
ring	= 3;
pinky	= 4;
outer	= 5;

/*******************************************************************************\
|								Global Functions								|
\*******************************************************************************/

// Get the index of the last member of a vector.
function last ( vector ) = len ( vector ) - 1;

// Create a dictionary from a list of key-value pairs.
//
// If there are duplicate keys in the list, only the value for the first key
// will be returned.
function dictionary ( keyvals, key ) = [
	for ( i = keyvals ) if (i[0] == key) i[1]
][0];

/*******************************************************************************\
|									Case Frame									|
\*******************************************************************************/

/* [Case Frame] */
// Show the case frame.
CaseFrame_visible = true;

// Thickness of the case frame.
CaseFrame_thickness = 3; //[1:5]

/*******************************************************************************\
|								Center Block									|
\*******************************************************************************/

/* [Center Block] */
// Show the center block.
CenterBlock_visible = true;

// Width of the center block
// CenterBlock_width = 25; //[1:50]

// Width and height of the strengthening ribs of the center block.
CenterBlock_ribSize = [ 2, 2 ]; //[1:5]

// Thickness of the center wall
CenterBlock_wallThickness = 2; //[1:10]

/*******************************************************************************\
|									Colors										|
\*******************************************************************************/

/* [Colors] */
// Primary color for the keyboard components.
Color_primary = [ 0.20, 0.20, 0.20, 1.00 ]; //[0.0:0.01:1.0]

// Secondary color for the keyboard components.
Color_secondary = [ 0.50, 0.30, 0.80, 1.00 ];  //[0.0:0.01:1.0]

Color_clear = [ 1.0, 1.0, 1.0, 0.2 ];
Color_cut = [ 1.0, 1.0, 0.0, 0.2 ];

/*******************************************************************************\
|									Columns										|
\*******************************************************************************/

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

_Column_counts_init = [
	Column_inner_count,
	Column_index_count,
	Column_middle_count,
	Column_ring_count,
	Column_pinky_count,
	Column_outer_count,
];

Column_count = len ( [
	for (i = [ last ( _Column_counts_init ) : -1 : 0 ] )
		if ( i != 0 )
			i
] );

Column_last = Column_count - 1;

Column_counts = [ for ( i = [ 0 : Column_last ] ) _Column_counts_init[i] ];

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

_Column_offsets_init = [
	Column_inner_offset,
	Column_index_offset,
	Column_middle_offset,
	Column_ring_offset,
	Column_pinky_offset,
	Column_outer_offset,
];

Column_offsets	= [ for ( i = [ 0 : Column_last ] ) _Column_offsets_init [ i ] ];

/*******************************************************************************\
|									Fasteners									|
\*******************************************************************************/

/* [Screws] */
// M2 screw shaft major diameter.
Screw_diameter = 2;

// M2 screw head diameter.
Screw_headDiameter = 4;

// Screw countersink angle.
Screw_headAngle = 90;

/* [Heat-set Inserts] */
// Heat-sink insert outer diameter.
Insert_diameter = 3;

// Heat-sink insert height.
Insert_height = 3;

Insert_holeDiameter = 2.8;

Insert_holeDepth = 4;

Insert_wallThickness = 1.5;

/*******************************************************************************\
|									Halves										|
\*******************************************************************************/

/* [Halves] */
// Halves Angles
Halves_angles	= [0, 5, 15];	//[-45:45]

/*******************************************************************************\
|									Hinge										|
\*******************************************************************************/

/* [Hinge] */
// Show the hinge.
Hinge_visible = true;

// Hinge Length
Hinge_length	= 90;	//[50:1:200]

/*******************************************************************************\
|									Keys										|
\*******************************************************************************/

/* [Keys] */
// Space between keycaps.
Key_clearance = 0.5; //[0:0.1:1]

// Test clearance between keycaps and case.
Key_testClearance	= false;

/*******************************************************************************\
|									Keycaps										|
\*******************************************************************************/

/* [Keycaps] */
// Show Keycaps.
Keycap_visible = true;

// Keycap profile
Keycap_type = "lamé"; //[ "cherry", "dsa", "lamé", "mbk", ]

Keycap_height = (
	( Keycap_type == "cherry"	) ? 11	:
	( Keycap_type == "dsa"		) ? 8	:
	( Keycap_type == "lamé"		) ? 6.5	:
	( Keycap_type == "mbk"		) ? 2.6	: 11
);

/*******************************************************************************\
|								Magnetic Connector								|
\*******************************************************************************/

// Size of the main body of the magnetic connector.
MagCon_size			= [ 4.7, 26.5, 6.0 ];

// Size of the lip around the magnetic connector.
MagCon_lip			= [ 1.0, 28.5, 8.0 ];

// Distance between the lip and the face of the connector.
MagCon_lipOffset	= 1.0;

/*******************************************************************************\
|									PCBs										|
\*******************************************************************************/

/* [PCB] */
// Show the PCB.
PCB_visible = true;

// PCB thickness.
PCB_thickness = 1.6;	//[1:0.2:2]

/*******************************************************************************\
|									Plates										|
\*******************************************************************************/

/* [Bottom Plate] */
// Show the bottom plate.
BottomPlate_visible = true;

// Thickness of the bottom plate.
BottomPlate_thickness = 1.6;	//[1:0.2:2]

// Clearance between the bottom plate and the PCB.
BottomPlate_clearance = 3; //[1:10]

/* [Switch Plate] */
// Show the switch plate.
SwitchPlate_visible = true;

// Distance from keys to edge of switch plate.
SwitchPlate_edge		= 2; //[1:5]

// Specify whether a switch plate will be used.
SwitchPlate_present	= true;

/* [Top Plate] */
// Show the Top Plate.
TopPlate_visible = true;

// Top plate thickness.
TopPlate_thickness = 1.6; //[1.0:0.2:2.0]

TopPlate_edge = SwitchPlate_edge + CaseFrame_thickness;

TopPlate_innerRadius = 2; //[0.0:0.1:5.0]

/* [Plates Common] */

// Radius of the arc at the front of the keyboard.
Plate_centerArcRadius = 20;	//[10:50]

// Radius of the arc at the back of the keyboard.
Plate_backArcRadius = 120;	//[50:200]

// Radius of the arc at the front outer corner of the keyboard.
Plate_outerArcRadius = 20;	//[10:50]

/*******************************************************************************\
|									Switches									|
\*******************************************************************************/

/* [Switches] */
// Show the switches.
Switch_visible = true;

// Radius for corners of switch openings in the switch plate.
Switch_radius = 0.5;	//[0:0.1:1]

Switch_type = "choc"; //["choc","mx"]

Switch_size = Key_testClearance ? [
	Key_spacing.x - Key_clearance,
	Key_spacing.y - Key_clearance
] : [ 14, 14 ];

/*******************************************************************************\
|								Thumb Cluster									|
\*******************************************************************************/

/* [Thumb Cluster] */

// Angle between adjacent thumb keys.
Cluster_angle		= 10; //[0:1:30]

// Number of keys in the inner two thumb columns.
Cluster_columnCounts	= [1, 2, 1];	//[1:2]

// Offset distance of the inner two thumb columns.
Cluster_columnOffsets	= [0, 0, 0];	//[0:0.125:1]

// This drives the spacing between the thumb keys.
Cluster_radius	= 6.5; //[0:0.25:10]

/*******************************************************************************\
|									Trackball									|
\*******************************************************************************/

/* [Trackball] */
// Show the trackball.
Trackball_visible = true;

// Trackball diameter
Trackball_diameter = 35;	//[25:1:50]

// Trackball position
Trackball_position_y = 63;	//[0:200]

// Trackball clearance
Trackball_clearance = 1;	//[0:0.1:2]

/* [Trackball Sensor] */
// Show the trackball sensor.
Trackball_Sensor_visible = true;

// Trackball sensor PCB size.
Trackball_Sensor_pcbSize = [ 16, 25 , PCB_thickness ]; //[0:30]

// Trackball sensor IC size.
Trackball_Sensor_size = [ 10.9, 16.2, 1.65 ];

// Trackball sensor lens size.
Trackball_Sensor_lensSize = [ 8.6, 16.96, 3.4 ];

// Distance between trackball sensor lens and trackball.
Trackball_Sensor_clearance = 2.4;

// Diameter of the opening in the trackball case.
Trackball_Sensor_holeSize = 8;

// Angle of the trackball sensor from horizontal.
Trackball_Sensor_angle = 60; //[30:5:90]

// Size of trackball sensor holding feature.
Trackball_Sensor_holderHeight = 15;

// Thickness of trackball sensor holding feature.
Trackball_Sensor_holderThickness = 5;

// Trackball sensor optical center coordinates.
Trackball_Sensor_opticalCenter = [
	7.85,
	15.32,
	(
		-Trackball_Sensor_lensSize.z
		- Trackball_Sensor_clearance
	)
];

/* [Trackball BTU] */
// Show the trackball BTUs.
Trackball_BTU_visible = true;

// Trackball BTU main diameter
Trackball_BTU_D1	= 7.5;

// Trackball BTU upper ring diameter
Trackball_BTU_D		= 9;

// Trackball BTU main height
Trackball_BTU_L		= 4;

// Trackball BTU upper ring height
Trackball_BTU_H		= 1;

// Trackball BTU ball height
Trackball_BTU_L1	= 1.1;

// Trackball BTU ball diameter
Trackball_BTU_d		= 4;

/*******************************************************************************\
|								Calculated Values								|
\*******************************************************************************/

Key_MXspacing = ( Switch_type == "mx" ) ? true : false;
Key_spacing = Key_MXspacing ? [19, 19] : [18, 17];

BottomPlate_edge = SwitchPlate_edge + CaseFrame_thickness;

SwitchPlate_thickness = Key_MXspacing ? 1.6 : 1.2;

Plate_frontArcRadius = ( Cluster_radius - 0.5 ) * Key_spacing.y;

Switch_height_total = (Switch_type == "mx") ? 14.9 : 11.0;
Switch_height_upper = (Switch_type == "mx") ? 6.6 : 5.8;
Switch_height_lower = (Switch_type == "mx") ? 5.0 : 2.2;
Switch_height_legs = (Switch_type == "mx") ? 3.3 : 3.0;

Cluster_radius_mm = Cluster_radius * Key_spacing.y;

Key_height = (
	Switch_height_lower
	+ Switch_height_upper
	+ Keycap_height
);

CenterBlock_height = (
		BottomPlate_thickness
	+	BottomPlate_clearance
	+	PCB_thickness
	+	Key_height
);

// Position of the connector relative to the Center Block.
MagCon_position		= [ 0, 20, ( CenterBlock_height + BottomPlate_thickness) / 2 ];

PCB_position = [
	0,
	0,
	BottomPlate_clearance + Switch_height_legs
];

CenterScrews_x = TopPlate_edge - Screw_diameter;

Screw1_y = (
	+ Trackball_position_y
	- Trackball_diameter / 2
	- Trackball_clearance
	- Screw_diameter * 2
);

Screw_positions = [
	[ CenterScrews_x,	0,				0 ],
	[ CenterScrews_x,	Screw1_y,		0 ],
	[ CenterScrews_x,	Hinge_length,	0 ],
];

SwitchPlate_position = [
	0,
	0,
	(
		BottomPlate_clearance
		+ Switch_height_legs
		+ Switch_height_lower
	)
];

TopPlate_position = [
	0,
	0,
	(
		BottomPlate_thickness
		+ BottomPlate_clearance
		+ PCB_thickness
		+ Key_height
	)
];

Trackball_position_z = (
	BottomPlate_thickness
	+ BottomPlate_clearance
	+ PCB_thickness
	+ Key_height
);

Trackball_position = [
	0,
	Trackball_position_y,
	Trackball_position_z
];