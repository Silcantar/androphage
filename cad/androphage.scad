/*******************************************************************************\
|																				|
|				Main File and Parameters for Androphage keyboard.				|
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
|	    Modules & Functions:	snake_case										|
|			Example:	module center_block ( ... ) { ... }						|
|		Global Variables:		PascalCaseObject_camelCaseProperty				|
|			Example:	CenterBlock_wallThickness								|
|		Function parameters:	camelCaseObject_camelCaseProperty				|
|																				|
|	Prepend an underscore for local-scope items.								|
|																				|
\*******************************************************************************/

/* [Hidden] */
// Other files test whether this is defined to determine whether this file has
// been loaded.
ANDROPHAGE_MAIN = true;

/* [Testing] */
// Set to true to enable testing features.
$test = false;

/*******************************************************************************\
|							Component Visibility								|
\*******************************************************************************/

/* [Component Visibility] */

// Show the left half of the keyboard.
LeftHalf_visible = true;

// Show the battery.
Battery_visible				= true;

// Show the center block.
CenterBlock_visible			= true;

// Show the desk.
Desk_visible				= true;

// Show the case frame.
Frame_visible				= true;

// Show the hinge.
Hinge_visible				= true;

// Show heat-set inserts.
Insert_visible				= true;

// Show Keycaps.
Keycap_visible				= true;

// Show the magnetic connector.
MagCon_visible				= true;

// Show the microcontroller unit.
MCU_visible                 = true;

// Show the PCB.
PCB_visible					= true;

// Show the bottom plate.
BottomPlate_visible			= true;

// Show the switch plate.
SwitchPlate_visible			= true;

// Show the Top Plate.
TopPlate_visible			= true;

Screw_visible				= true;

// Show the switches.
Switch_visible				= true;

// Show the trackball.
Trackball_visible			= true;

// Show the trackball BTUs.
Trackball_BTU_visible		= true;

// Show the trackball sensor.
Trackball_Sensor_visible	= true;

/*******************************************************************************\
|									Battery										|
\*******************************************************************************/

/* [Battery] */

Battery_size = [ 12, 30, 3 ];

/*******************************************************************************\
|									Case Frame									|
\*******************************************************************************/

/* [Case Frame] */

Frame_chordAngle = 5;

Frame_filletRadius = 1;

Frame_lipDepth = 1;

Frame_mainRadius = 50;

Frame_notchDepth = 6;

// Thickness of the case frame.
Frame_thickness = 5; //[1:5]

Frame_extraLength = 3;

/*******************************************************************************\
|								Center Block									|
\*******************************************************************************/

/* [Center Block] */

// Width and height of the strengthening ribs of the center block.
CenterBlock_ribSize = [ 2, 2 ]; //[1:5]

// Number of screws that screw into the top and bottom of the center block.
CenterBlock_screwCount = 3;

// Thickness of the center wall
CenterBlock_wallThickness = 2; //[1:10]

/*******************************************************************************\
|								Thumb Cluster									|
\*******************************************************************************/

/* [Thumb Cluster] */

// Angle between adjacent thumb keys.
Cluster_angle		= 10; //[0:1:30]

// Number of keys in the inner two thumb columns.
Cluster_columnCounts	= [1, 1, 2, 1];	//[1:2]

// Offset distance of the inner two thumb columns.
Cluster_columnOffsets	= [0, 0, 0, 0];	//[0:0.125:1]

Cluster_cutout = 10;

Cluster_cutouts = [ 1, 1, 1, 1 ];

// Should the frontmost key in the index column be pressed by the thumb?
Cluster_fiveThumbKeys = true;

// This drives the spacing between the thumb keys.
Cluster_radius	= 6.5; //[0:0.25:10]

/*******************************************************************************\
|									Columns										|
\*******************************************************************************/

/* [Column Key Counts] */
// Number of keys in the inner index finger column.
Column_inner_count	= 3;	//[1:4]
// Number of keys in the index finger column.
Column_index_count	= 3;	//[1:5]
// Number of keys in the middle finger column.
Column_middle_count	= 4;	//[1:5]
// Number of keys in the ring finger column.
Column_ring_count	= 4;	//[1:5]
// Number of keys in the pinky finger column.
Column_pinky_count	= 3;	//[1:5]
// Number of keys in the outer pinky finger column.
Column_outer_count	= 0;	//[0:5]

/* [Column Offsets] */
// Distance that keys in the inner index finger column are offset depthward.
Column_inner_offset		= 1;	//[1:0.125:2]
// Distance that keys in the index finger column are offset depthward.
Column_index_offset		= 1;	//[-1:0.125:2]
// Distance that keys in the middle finger column are offset depthward.
Column_middle_offset	= 0.5;	//[-1:0.125:2]
// Distance that keys in the ring finger column are offset depthward.
Column_ring_offset		= 0;	//[-1:0.125:2]
// Distance that keys in the pinky finger column are offset depthward.
Column_pinky_offset		= 0.5;	//[-1:0.125:2]
// Distance that keys in the outer pinky finger column are offset depthward.
Column_outer_offset		= 0.5;	//[-1:0.125:2]

/*******************************************************************************\
|										Desk									|
\*******************************************************************************/

/* [Desk] */

Desk_size = [ 300, 200, 1 ];

Desk_position = [ 0, 0, -40 ];

/*******************************************************************************\
|									Fasteners									|
\*******************************************************************************/

/* [Screws] */

// M2 screw shaft major diameter.
Screw_diameter = 2;

// M2 screw shaft minor diameter.
Screw_minorDiameter = 1.6;

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
Halves_angles	= [0, 7, 15];	//[-45:45]

Halves_clearance = 1;

/*******************************************************************************\
|									Hinge										|
\*******************************************************************************/

/* [Hinge] */

// Unlike keyboard components, hinges available in the US are mostly sized in
// inches.
Hinge_unit = "inch"; //["inch", "mm"]

// Outer diameter of hinge pivot.
Hinge_diameter = 0.174;	//[]

// Length of each hinge knuckle.
Hinge_knuckleDepth = 0.5; //[0:0.1:1]

// Length of joint between halves.
Hinge_length = 90;

// Hinge leaf thickness.
Hinge_leafThickness = 0.04; //[0.01:0.01:0.1]

// Hinge leaf width.
Hinge_leafWidth	= 0.53125;	//[0.03125:0.03125:1]

// Diameter of hinge pin.
Hinge_pinDiameter = 0.09375;	//[0.03125:0.03125:1]

/*******************************************************************************\
|									Keycaps										|
\*******************************************************************************/

/* [Keycaps] */

// Space between keycaps.
Keycap_clearance = 0.5; //[0:0.1:1]

// Test clearance between keycaps and case.
Keycap_testClearance = false;

// Keycap profile
Keycap_profile = "lamé"; //[ "cherry", "dsa", "lamé", "mbk", "steno" ]

// Styles for KLP Lamé keycaps.
Keycap_saddle = false;

// What type of key spacing to use.
Key_spacingType = "choc"; // [ "choc", "mx", "custom" ]

// Spacing to use if spacingType is "custom".
Key_customSpacing = [ 16, 16 ];

/*******************************************************************************\
|									LEDs										|
\*******************************************************************************/

/* [LEDs] */
LED_present = true;

LED_count = 4;

LED_holeRadius = 0.2;

LED_holeShape = "square"; //["square", "circle"]

LED_holeSize = [ 3, 3 ];

LED_holeSpacing = [ 4.5, 0 ];

LED_position_y = 13;

/*******************************************************************************\
|								Magnetic Connector								|
\*******************************************************************************/

/* [Magnetic Connector] */

// Size of the main body of the magnetic connector.
MagCon_size			= [ 4.7, 26.5, 6.0 ];

// Size of the lip around the magnetic connector.
MagCon_lip			= [ 1.0, 28.5, 8.0 ];

// Distance between the lip and the face of the connector.
MagCon_lipOffset	= 1.0;

/*******************************************************************************\
|										MCU										|
\*******************************************************************************/

/* [MCU] */

MCU_chipSize = [ 12, 10, 1.5 ];

MCU_location = "trackball sensor"; //["trackball sensor", "magnetic connector", "main PCB"]

MCU_radius = 2;

MCU_size = [ 17.8, 21, 1.2 ];

MCU_usbOverhang = 1.5;

MCU_usbRadius = 1.2;

MCU_usbSize = [ 9, 7.35, 3.2 ];

MCU_usbCutSize = [ 12, 10, 7 ];

/*******************************************************************************\
|										PCBs									|
\*******************************************************************************/

/* [PCB] */

PCB_color = "DarkGreen";

// PCB thickness.
PCB_thickness = 1.2;	//[1:0.2:2]

/*******************************************************************************\
|									Plates										|
\*******************************************************************************/

/* [Bottom Plate] */

// Thickness of the bottom plate.
BottomPlate_thickness = 1.2;	//[1:0.2:2]

// Clearance between the bottom plate and the PCB.
BottomPlate_clearance = 3; //[1:10]

/* [Switch Plate] */

// Specify whether a switch plate will be included.
SwitchPlate_present	= true;

SwitchPlate_clearance = 0.2;

// Distance from keys to edge of switch plate.
SwitchPlate_edge = 2; //[0:5]

SwitchPlate_radius = 1;

/* [Top Plate] */

// Top plate thickness.
TopPlate_thickness = 1.2; //[1.0:0.2:2.0]

// Fillet radius for the cutout in the top plate.
TopPlate_innerRadius = 2; //[0.0:0.1:5.0]

/* [Plates Common] */

// Radius of the arc at the front of the keyboard.
Plate_centerArcRadius = 20;	//[10:50]

// Radius of the arc at the back of the keyboard.
Plate_backArcRadius = 120;	//[50:200]

Plate_backCornerAngle = 43;

/*******************************************************************************\
|									Switches									|
\*******************************************************************************/

/* [Switches] */

// Radius for corners of switch openings in the switch plate.
Switch_radius = 0.5;	//[0:0.1:1]

Switch_type = "glp"; //["chocv1", "chocv2", "mx", "glp"]

Switch_travel = 0;
Switch_maxTravel = 3.3;

// Color for Choc switches.
Switch_chocColor = "Sunset"; //["Red", "Blue", "Brown", "Pro Red", "Pink", "Robin", "Sunset", "Twilight", "Nocturnal", "Sunrise", "Bokeh"]

// Color for Gateron Low-Profile (KS-33) switches.
Switch_glpColor = "Banana"; //["Banana", "Blue", "Brown", "Chocolate", "Red", "Aloe", "Cowberry", "Daisy", "Moss", "Panda", "Wisteria"]

// Default MX color based on Durock Shrimps.
Switch_mxStemColor = [ 1.00, 1.00, 1.00, 0.80 ]; //[ 0.00 : 0.01 : 1.00 ]

Switch_mxTopColor = [ 0.00, 0.90, 1.00, 0.60 ]; //[ 0.00 : 0.01 : 1.00 ]

Switch_mxBottomColor = [ 0.00, 0.90, 1.00, 0.60 ]; //[ 0.00 : 0.01 : 1.00 ]

/*******************************************************************************\
|									Trackball									|
\*******************************************************************************/

/* [Trackball] */

// Trackball diameter
Trackball_diameter = 35;	//[25:1:50]

// Trackball position
Trackball_position_y = 63;	//[0:200]

// Trackball clearance
Trackball_clearance = 1;	//[0:0.1:2]

/* [Trackball Sensor] */

// Trackball sensor PCB size.
Trackball_Sensor_pcbSize_xy = [ 16, 25 ]; //[0:30]

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

/* [Trackball BTU] */

Trackball_BTU_angles = [ 45, 0, 45 ];

// Trackball BTU ball diameter
Trackball_BTU_d		= 4;

// Trackball BTU upper ring diameter
Trackball_BTU_D		= 9;

// Trackball BTU main diameter
Trackball_BTU_D1	= 7.5;

// Trackball BTU upper ring height
Trackball_BTU_H		= 1;

// Trackball BTU main height
Trackball_BTU_L		= 4;

// Trackball BTU ball height
Trackball_BTU_L1	= 1.1;

/*******************************************************************************\
|									Assembly									|
\*******************************************************************************/

// Definitions and calclations.
include <library/globals.scad>

include <globals.scad>

include <color.scad>

include <derives.scad>

// Components.
include <components/battery.scad>

include <components/btu.scad>

include <components/center_block.scad>

include <components/frame.scad>

include <components/hinge.scad>

include <components/key_placement.scad>

include <components/keys.scad>

include <components/magnetic_connector.scad>

include <components/mcu.scad>

include <components/plates.scad>

include <components/trackball_sensor.scad>

include <components/trackball.scad>

// Assembly.
include <assembly.scad>
