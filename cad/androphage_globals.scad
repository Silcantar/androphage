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

/* [Hidden] */
ANDROPHAGE_GLOBALS = true;

// Rendering parameters.
$fa = $preview ? 10 : 1;
$fs = $preview ? 1	: 0.1;

// Test boolean.
$test = false;

// Very small amount.
eps = 0.01;

// "Enum" of fingers/columns.
inner	= 0;
index	= 1;
middle	= 2;
ring	= 3;
pinky	= 4;
outer	= 5;

include <library/screw_globals.scad>

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
	for ( i = keyvals ) if ( i[0] == key ) i[1]
][0];

// Element-wise vector multiplication.
function v_mul ( v1, v2 ) = [
	for ( i = [ 0 : min ( last(v1), last(v2) ) ] ) (
		v1[i] * v2[i]
	)
];

function rot2d ( angle ) = [
	[ cos(angle),	-sin(angle)	],
	[ sin(angle),	cos(angle)	],
];

// Axis "enum".
x = "x";
y = "y";
z = "z";

// 3d rotation matrix.
function rot3d ( angles ) = let (
	a = angles.z,
	b = angles.y,
	c = angles.x
) [
	[
		cos(a) * cos(b),
		cos(a) * sin(b) * sin(c) - sin(a) * cos(c),
		cos(a) * sin(b) * cos(c) - sin(a) * sin(c),
	],
	[
		sin(a) * cos(b),
		sin(a) * sin(b) * sin(c) + cos(a) * cos(c),
		sin(a) * sin(b) * cos(c) - cos(a) * sin(c),
	],
	[
		-sin(b),
		cos(b) * sin(c),
		cos(b) * cos(c),
	],
];

/*******************************************************************************\
|								Global Modules									|
\*******************************************************************************/

// Conditional background
module cb ( cond = $test ) {
	ct ( $test ) {
		children(0);

		%children(0);
	}
}

// Conditional highlight
module ch ( cond = $test ) {
	ct ( $test ) {
		children(0);

		#children(0);
	}
}

// Conditional test
module ct ( cond = $test ) {
	if ( cond ) {
		if ( $children >= 2 ) {
			children(1);
		}
	} else {
		children(0);
	}
}

module nothing () {}

module fillet2d ( radius, outerFirst = true ) {
	coeff = outerFirst ? 1 : -1;
	offset ( coeff * radius ) {
		offset ( -2 * coeff * radius ) {
			offset ( coeff * radius ) {
				children();
			}
		}
	}
}

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

// Number of screws that screw into the top and bottom of the center block.
CenterBlock_screwCount = 3;

// Thickness of the center wall
CenterBlock_wallThickness = 2; //[1:10]

/*******************************************************************************\
|									Colors										|
\*******************************************************************************/

/* [Colors] */
// Primary color for the keyboard components (Black).
Color_primary = [ 0.20, 0.20, 0.20, 1.00 ]; //[0.0:0.01:1.0]

// Secondary color for the keyboard components (Purple).
Color_secondary = [ 0.50, 0.30, 0.80, 1.0 ];  //[0.0:0.01:1.0]

// Tertiary color for keyboard components (Copper).
Color_tertiary = [ 0.62, 0.36, 0.18, 1.00 ];

// Color for transparent plastic (Transparent white).
Color_clear = [ 1.0, 1.0, 1.0, 0.2 ];

// Color for displaying cutting bodies (Transparent yellow).
Color_cut = [ 1.0, 1.0, 0.0, 0.2 ];

Color_steel = [ 0.5, 0.5, 0.5, 1.0 ];

/*******************************************************************************\
|									Columns										|
\*******************************************************************************/

/* [Column Key Counts] */
// Number of keys in the inner index finger column.
Column_inner_count	= 3;	//[1:4]
// Number of keys in the index finger column.
Column_index_count	= 4;	//[1:5]
// Number of keys in the middle finger column.
Column_middle_count	= 4;	//[1:5]
// Number of keys in the ring finger column.
Column_ring_count	= 4;	//[1:5]
// Number of keys in the pinky finger column.
Column_pinky_count	= 3;	//[1:5]
// Number of keys in the outer pinky finger column.
Column_outer_count	= 0;	//[0:5]

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
Column_inner_offset		= 1;	//[1:0.125:2]
// Distance that keys in the index finger column are offset depthward.
Column_index_offset		= 0;	//[-1:0.125:2]
// Distance that keys in the middle finger column are offset depthward.
Column_middle_offset	= 0.5;	//[-1:0.125:2]
// Distance that keys in the ring finger column are offset depthward.
Column_ring_offset		= 0;	//[-1:0.125:2]
// Distance that keys in the pinky finger column are offset depthward.
Column_pinky_offset		= 0.5;	//[-1:0.125:2]
// Distance that keys in the outer pinky finger column are offset depthward.
Column_outer_offset		= 0.5;	//[-1:0.125:2]

_Column_offsets_init = [
	Column_inner_offset,
	Column_index_offset,
	Column_middle_offset,
	Column_ring_offset,
	Column_pinky_offset,
	Column_outer_offset,
];

Column_offsets = [ for ( i = [ 0 : Column_last ] ) _Column_offsets_init [ i ] ];

Column_cutouts = [ 0, 1, 0, 0, 0 ];

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

// Distance screws are inset from the plate edge.
Screw_offset = 3;

/* [Heat-set Inserts] */
// Heat-sink insert outer diameter.
Insert_diameter = 3;

// Heat-sink insert height.
Insert_height = 3;

Insert_holeDiameter = 2.8;

Insert_holeDepth = 4;

Insert_wallThickness = 1.6;

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

// Diameter of hinge pivot.
Hinge_diameter = 3;

// Hinge dimensions [ width, length, leaf thickness ].
Hinge_size	= [ (27 - Hinge_diameter) / 2, 90, 1 ];	//[50:1:200]

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
	( Keycap_type == "lamé"		) ? 6.5	: //6.5
	( Keycap_type == "mbk"		) ? 2.6	: 11
);

Keycap_path = "klp_lame_keycaps/STL/Choc Stem + Choc Size/Choc_Stem_Choc_Size_";

// Styles for KLP Lamé keycaps.
Keycap_saddle = false;
normal	= Keycap_saddle ? "Saddle"			: "Normal";
tilted	= Keycap_saddle ? "Saddle_Tilted"	: "Normal_Tilted";
homing	= Keycap_saddle ? "Saddle_Homing"	: "Normal_Homing";
thumb	= Keycap_saddle ? "Saddle"			: "Thumb";

// Should the frontmost key in the index column be pressed by the thumb?
five_thumb_keys = true;

Keycap_style = [
	// [ Style, Rotated? ]
	// Inner Column, back -> front
	[ tilted, 1, Color_primary ],
	[ normal, 0, Color_secondary ],
	[ tilted, 0, Color_primary ],
	// Index Column
	// This key can go to the index or thumb:
	five_thumb_keys ? [ thumb, 0, Color_primary ] : [ tilted, 1, Color_primary ],
	five_thumb_keys ? [ tilted, 1, Color_primary ] : [ normal, 1, Color_primary ],
	// [ tilted, 1 ],
	[ homing, 0, Color_secondary ],
	[ tilted, 0, Color_primary ],
	// Middle Column
	[ tilted, 1, Color_primary ],
	[ normal, 1, Color_primary ],
	[ normal, 0, Color_secondary ],
	[ tilted, 0, Color_primary ],
	// Ring Column
	[ tilted, 1, Color_primary ],
	[ normal, 1, Color_primary ],
	[ normal, 0, Color_secondary ],
	[ tilted, 0, Color_primary ],
	// Pinky Column
	[ tilted, 1, Color_primary ],
	[ normal, 0, Color_secondary ],
	[ tilted, 0, Color_primary ],
	// Thumb Keys, inside -> outside
	[ thumb, 0, Color_primary ],
	[ thumb, 0, Color_secondary ],
	[ tilted, 0, Color_secondary ],
	[ thumb, 0, Color_primary ],
];

/*******************************************************************************\
|									LEDs										|
\*******************************************************************************/

/* [LEDs] */
LED_present = true;

LED_count = 4;

LED_holeShape = "square";

LED_holeSize = [ 3, 3 ];

LED_holeSpacing = [ 4.5, 0 ];

LED_position_y = 13;

/*******************************************************************************\
|								Magnetic Connector								|
\*******************************************************************************/

MagCon_visible = true;

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
// Specify whether a switch plate will be used.
SwitchPlate_present	= true;

// Show the switch plate.
SwitchPlate_visible = false;

// Distance from keys to edge of switch plate.
SwitchPlate_edge		= 2; //[1:5]

/* [Top Plate] */
// Show the Top Plate.
TopPlate_visible = true;

// Top plate thickness. 1.6 mm is the minimum for anodizing at SendCutSend.
TopPlate_thickness = 1.6; //[1.0:0.2:2.0]

TopPlate_edge = SwitchPlate_edge + CaseFrame_thickness;

// Fillet radius for the cutout in the top plate.
TopPlate_innerRadius = 2; //[0.0:0.1:5.0]

/* [Plates Common] */

// Radius of the arc at the front of the keyboard.
Plate_centerArcRadius = 20;	//[10:50]

// Radius of the arc at the back of the keyboard.
Plate_backArcRadius = 120;	//[50:200]

// Radius of the arc at the front outer corner of the keyboard.
Plate_outerArcRadius = 20;	//[10:50]

// Fillet radius for the outside corners of the plates.
Plate_outerRadius = 3;

/*******************************************************************************\
|									Switches									|
\*******************************************************************************/

/* [Switches] */
// Show the switches.
Switch_visible = true;

// Radius for corners of switch openings in the switch plate.
Switch_radius = 0.5;	//[0:0.1:1]

switch_chocv1	= "chocv1";
switch_chocv2	= "chocv2";
switch_mx		= "mx";

Switch_type = switch_chocv1;

$choc_version = ( Switch_type == switch_chocv1 ) ? 1 : 2;

Switch_size = Key_testClearance ? [
	Key_spacing.x - Key_clearance,
	Key_spacing.y - Key_clearance
] : [ 14, 14 ];

Switch_travel = 0;
Switch_maxTravel = 3.3;

switch_red		= 0;
switch_blue		= 1;
switch_brown	= 2;
switch_prored	= 3;
switch_pink		= 4;
switch_robin	= 5;
switch_sunset	= 6;
switch_twilight	= 7;
switch_nocturnal= 8;
switch_sunrise	= 9;
switch_bokeh	= 10;

Switch_colorScheme = switch_sunset; // [0: Red, 1: Blue, 2: Brown, 3: Pro Red, 4: Pink, 5: Robin, 6: Sunset, 7: Twilight, 8: Nocturnal, 9: Sunrise, 10: Bokeh]
$color_scheme = Switch_colorScheme;


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

Cluster_cutouts = [ 1, 1, 1 ];

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

Column_connectors = [
	[ Key_spacing.x, 90 + Cluster_angle ],
	[ 0, 0 ],
	[ 0, 0 ],
	[ 0, 0 ],
	[ 0, 0 ],
];

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

LED_position = [
	Key_spacing.x - ( LED_count - 1 ) * LED_holeSpacing.x / 2,
	Key_spacing.y / 2 - LED_position_y,
	0
];

// Position of the connector relative to the Center Block.
MagCon_position		= [
	0,
	19.5,
	(
		+ BottomPlate_thickness
		+ BottomPlate_clearance
		+ 5
	)
];

PCB_position = [
	0,
	0,
	BottomPlate_thickness + BottomPlate_clearance
];

Switch_position_z = PCB_position.z + PCB_thickness;

Keycap_position_z = (
	+ PCB_position.z 
	+ Switch_height_lower 
	+ Switch_height_upper 
	- Switch_travel 
	// - Switch_maxTravel
);

CenterScrews_x = TopPlate_edge - Screw_diameter;

SwitchPlate_position = PCB_position + [ 0, 0, PCB_thickness + Switch_height_lower - SwitchPlate_thickness ];

TopPlate_position = [
	0,
	0,
	(
		+ BottomPlate_thickness
		+ BottomPlate_clearance
		+ PCB_thickness
		+ Key_height
	)
];

Trackball_position_z = (
	+ TopPlate_position.z
	+ TopPlate_thickness
);

Trackball_position = [
	0,
	Trackball_position_y,
	Trackball_position_z
];