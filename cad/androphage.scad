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
\*******************************************************************************/

include <androphage_globals.scad>

// Dimensions = object ( [
// 	[ "CaseFrame",		CaseFrame	],
// 	[ "CenterBlock",	CenterBlock	],
// 	[ "Cluster",		Cluster		],
// 	[ "Column",			Column		],
// 	[ "Halves",			Halves		],
// 	[ "Hinge",			Hinge		],
// 	[ "Key",			Key			],
// 	[ "Keycap",			Keycap		],
// 	[ "PCB",			PCB			],
// 	[ "Plate",			Plate		],
// 	[ "Switch",			Switch		],
// 	[ "Trackball",		Trackball	],
// ] );

// function Dimensions ( ) = Dimensions;

use <androphage_assembly.scad>

* androphage_assembly ( );

// "Enum" of fingers/columns.
function finger_inner ( ) = 0;
function finger_index ( ) = 1;
function finger_middle ( ) = 2;
function finger_ring ( ) = 3;
function finger_pinky ( ) = 4;
function finger_outer ( ) = 5;

// function finger () = object (
// 	inner	= 0,
// 	index	= 1,
// 	middle	= 2,
// 	ring	= 3,
// 	pinky	= 4,
// 	outer	= 5,
// );

/*******************************************************************************\
|									Case Frame									|
\*******************************************************************************/

/* [Case Frame] */
_CaseFrame_thickness = 3; //[1:5]

function CaseFrame_thickness ( ) = _CaseFrame_thickness;

// CaseFrame = object ( [
// 	[ "thickness",	_CaseFrame_thickness	],
// ] );

/*******************************************************************************\
|								Center Block									|
\*******************************************************************************/

/* [Center Block] */
// Width of the center block
_CenterBlock_width = 25; //[1:50]
function CenterBlock_width ( ) = _CenterBlock_width;

// Thickness of the center wall
_CenterBlock_wallThickness = 2; //[1:50]
function CenterBlock_wallThickness ( ) = _CenterBlock_wallThickness;

function CenterBlock_height ( ) = (
		Plate_Bottom_thickness
	+	Plate_Bottom_clearance
	+	PCB_thickness
	+	Key_height
);

// CenterBlock = object ( [
// 	[ "width",			CenterBlock_width			],
// 	[ "wallThickness",	CenterBlock_wallThickness	],
// 	[ "height",			CenterBlock_height			],
// ] );

/* [Colors] */
// Primary color for the keyboard components.
_Color_primary = [ 0.20, 0.20, 0.20, 1.00 ]; //[0.0:0.01:1.0]

function Color_primary ( ) = _Color_primary;

// Secondary color for the keyboard components.
_Color_secondary = [ 0.50, 0.30, 0.80, 1.00 ];  //[0.0:0.01:1.0]
function Color_secondary ( ) = _Color_secondary;

function Color_clear ( ) = [ 1.0, 1.0, 1.0, 0.2 ];
function Color_cut ( ) = [ 1.0, 1.0, 0.0, 0.2 ];


// function Color () = object ( [
// 	[ "primary",	Color_primary	],
// 	[ "secondary",	Color_secondary	],
// 	[ "clear",		[ 1.0, 1.0, 1.0, 0.2 ] ],
// 	[ "cut",		[ 1.0, 1.0, 0.0, 0.2 ] ],
// ] );

/*******************************************************************************\
|									Columns										|
\*******************************************************************************/

/* [Column Key Counts] */
// Number of keys in the inner index finger column.
_Column_inner_count		= 3;	//[1:4]
// Number of keys in the index finger column.
_Column_index_count		= 4;	//[1:5]
// Number of keys in the middle finger column.
_Column_middle_count	= 4;	//[1:5]
// Number of keys in the ring finger column.
_Column_ring_count		= 4;	//[1:5]
// Number of keys in the pinky finger column.
_Column_pinky_count		= 3;	//[1:5]
// Number of keys in the outer pinky finger column.
_Column_outer_count		= 0;	//[0:5]

_Column_counts_init = [
	_Column_inner_count,
	_Column_index_count,
	_Column_middle_count,
	_Column_ring_count,
	_Column_pinky_count,
	_Column_outer_count,
];

function Column_count ( ) = len ( [
	for (i = [last (Column_counts_init) : -1 : 0])
		if ( i != 0 )
			i
] );

function Column_last ( ) = Column_count - 1;

function Column_counts ( ) = [ for (i = [0:Column_last]) Column_counts_init[i] ];

/* [Column Offsets] */
// Distance that keys in the inner index finger column are offset depthward.
_Column_inner_offset	= 1;	//[1:0.125:2]
// Distance that keys in the index finger column are offset depthward.
_Column_index_offset		= 0;	//[-1:0.125:2]
// Distance that keys in the middle finger column are offset depthward.
_Column_middle_offset	= 0.5;	//[-1:0.125:2]
// Distance that keys in the ring finger column are offset depthward.
_Column_ring_offset		= 0;	//[-1:0.125:2]
// Distance that keys in the pinky finger column are offset depthward.
_Column_pinky_offset	= 0.5;	//[-1:0.125:2]
// Distance that keys in the outer pinky finger column are offset depthward.
_Column_outer_offset	= 0.5;	//[-1:0.125:2]

_Column_offsets_init = [
	_Column_inner_offset,
	_Column_index_offset,
	_Column_middle_offset,
	_Column_ring_offset,
	_Column_pinky_offset,
	_Column_outer_offset,
];

function Column_offsets ( )	= [ for (i = [0:Column_last]) Column_offsets_init[i] ];

// Column = object ( [
// 	[ "count",		Column_count	],
// 	[ "counts",		Column_counts	],
// 	[ "last", 		Column_last		],
// 	[ "offsets",	Column_offsets	],
// ] );

/*******************************************************************************\
|									Halves										|
\*******************************************************************************/

/* [Halves] */
// Halves Angles
_Halves_angles	= [0, 5, 15];	//[-45:45]
function Halves_angles ( ) = _Halves_angles;

// Halves = object ( [
// 	[ "angles", Halves_angles ],
// ] );

/*******************************************************************************\
|									Hinge										|
\*******************************************************************************/

/* [Hinge] */
// Hinge Length
_Hinge_length	= 90;	//[50:1:200]
function Hinge_length ( ) = _Hinge_length;

// Hinge = object ( [
// 	[ "length",		Hinge_length	],
// ] );

/*******************************************************************************\
|									Keys										|
\*******************************************************************************/

/* [Keys] */
// Space between keycaps.
_Key_clearance = 0.5; //[0:0.1:1]
function Key_clearance ( ) = _Key_clearance;

// Test clearance between keycaps and case.
_Key_testClearance	= false;
function Key_testClearance ( ) = _Key_testClearance;

function Key_MXspacing ( ) = ( Switch_type ( ) == "mx" ) ? true : false;

function Key_spacing ( ) = Key_MXspacing ( ) ? [19, 19] : [18, 17];

function Key_height ( ) = (
	Switch_height_lower ( )
	+ Switch_height_upper ( )
	+ Keycap_height ( )
);

// Key = object ( [
// 	[ "clearance",		Key_clearance		],
// 	[ "height", 		Key_height			],
// 	[ "MXspacing",		Key_MXspacing		],
// 	[ "spacing",		Key_spacing			],
// 	[ "testClearance",	Key_testClearance	],
// ] );

/*******************************************************************************\
|									Keycaps										|
\*******************************************************************************/

// Keycap profile
_Keycap_type = "lamé"; //[ "cherry", "dsa", "lamé", "mbk", ]
function Keycap_type ( ) = _Keycap_type;

function Keycap_height ( ) = dictionary (
	[
		[ "cherry",	11	],
		[ "dsa",	8	],
		[ "lamé",	6.5	],
		[ "mbk",	2.6	],
	],
	Keycap_type ( )
 );

// Keycap = object ( [
// 	[ "height",	keycapHeight[Keycap_type]	],
// 	[ "type",	Keycap_type					],
// ] );

/*******************************************************************************\
|									PCBs										|
\*******************************************************************************/

/* [PCB] */
_PCB_thickness = 1.6;	//[1:0.2:2]
function PCB_thickness ( ) = _PCB_thickness;

function PCB_position ( ) = [
	0,
	0,
	Plate_Bottom_clearance + Switch.height.legs
];

// PCB = object ( [
// 	[ "thickness",	PCB_thickness	],
// 	[ "position",	PCB_position	],
// ] );

/*******************************************************************************\
|									Plates										|
\*******************************************************************************/

/* [Bottom Plate] */

// Thickness of the bottom plate.
_BottomPlate_thickness = 1.6;	//[1:0.2:2]
function BottomPlate_thickness ( ) = _BottomPlate_thickness;

// Clearance between the bottom plate and the PCB.
_BottomPlate_clearance = 2; //[1:10]
function BottomPlate_clearance ( ) = _BottomPlate_clearance;

function BottomPlate_edge ( ) = Plate_Switch_edge + CaseFrame_thickness;

// Plate_Bottom = object ( [
// 	[ "edge",		Plate_Bottom_edge		],
// 	[ "thickness",	Plate_Bottom_thickness	],
// 	[ "clearance",	Plate_Bottom_clearance	],
// ] );

/* [Switch Plate] */

// Distance from keys to edge of switch plate.
_SwitchPlate_edge		= 2; //[1:5]
function SwitchPlate_edge ( ) = _SwitchPlate_edge;

// Specify whether a switch plate will be used.
_SwitchPlate_present	= true;
function SwitchPlate_present ( ) = _SwitchPlate_present;


function SwitchPlate_thickness ( ) = Key_MXspacing ( ) ? 1.6 : 1.2;

function SwitchPlate_position ( ) = [
	0,
	0,
	(
		BottomPlate_clearance
		+ Switch_height_legs ( )
		+ Switch_height_lower ( )
	)
];

// Plate_Switch = object ( [
// 	[ "edge",		Plate_Switch_edge		],
// 	[ "present",	Plate_Switch_present	],
// 	[ "thickness",	Plate_Switch_thickness	],
// 	[ "position",	Plate_Switch_position	],
// ] );

/* [Top Plate] */

// Top plate thickness.
_TopPlate_thickness = 1.6; //[1.0:0.2:2.0]
function TopPlate_thickness ( ) = _TopPlate_thickness;

function TopPlate_edge ( ) = SwitchPlate_edge ( ) + CaseFrame_thickness ( );

function Plate_Top_position ( ) = [
	0,
	0,
	(
		BottomPlate_thickness ( )
		+ BottomPlate_clearance ( )
		+ PCB_thickness ( )
		+ Key_height ( )
	)
];

// Plate_Top = object ( [
// 	[ "edge",		Plate_Top_edge		],
// 	[ "thickness",	Plate_Top_thickness	],
// 	[ "position",	Plate_Top_position	],
// ] );

/* [Plates Common] */

// Radius of the arc at the front of the keyboard.
_Plate_centerArcRadius = 20;	//[10:50]
function Plate_centerArcRadius ( ) = _Plate_centerArcRadius;

// Radius of the arc at the back of the keyboard.
_Plate_backArcRadius = 120;	//[50:200]
function Plate_centerArcRadius ( ) = _Plate_centerArcRadius;

// Radius of the arc at the front outer corner of the keyboard.
_Plate_outerArcRadius = 20;	//[10:50]
function Plate_outerArcRadius ( ) = _Plate_outerArcRadius;

function Plate_frontArcRadius ( ) = ( Cluster_radius ( ) - 0.5 ) * Key_spacing().y;

// Plate = object ( [
// 	[ "Bottom",				Plate_Bottom			],
// 	[ "Switch",				Plate_Switch			],
// 	[ "Top",				Plate_Top				],
// 	[ "backArcRadius",		Plate_backArcRadius		],
// 	[ "centerArcRadius",	Plate_centerArcRadius	],
// 	[ "frontArcRadius",		Plate_frontArcRadius	],
// 	[ "outerArcRadius",		Plate_outerArcRadius	],
// ] );

/*******************************************************************************\
|									Switches									|
\*******************************************************************************/

/* [Switches] */
// Radius for corners of switch openings in the switch plate.
_Switch_radius = 0.5;	//[0:0.1:1]
function Switch_radius ( ) = _Switch_radius;

// Spacing between keys.
_Switch_type = "choc"; //[choc, mx]
function Switch_type ( ) = _Switch_type;

function Switch_size ( ) = Key_testClearance ? [
	Key_spacing.x - Key_clearance,
	Key_spacing.y - Key_clearance
] : [ 14, 14 ];

function Switch_height_total ( ) = (Switch_type ( ) == "mx") ? 14.9 : 11.0;
function Switch_height_upper ( ) = (Switch_type ( ) == "mx") ? 6.6 : 5.8;
function Switch_height_lower ( ) = (Switch_type ( ) == "mx") ? 5.0 : 2.2;
function Switch_height_legs ( ) = (Switch_type ( ) == "mx") ? 3.3 : 3.0;

// function Switch_height ( ) = dictionary ( [
// 	[ "total",	(Switch_type == "mx") ? 14.9 : 11.0	],
// 	[ "upper",	(Switch_type == "mx") ? 6.6 : 5.8	], // Excludes MX stem.
// 	[ "lower",	(Switch_type == "mx") ? 5.0 : 2.2	],
// 	[ "legs",	(Switch_type == "mx") ? 3.3 : 3.0	],
// ] );

// Switch = object ( [
// 	[ "height",	Switch_height	],
// 	[ "radius",	Switch_radius	],
// 	[ "size",	Switch_size		],
// 	[ "type",	Switch_type		],
// ] );


/*******************************************************************************\
|								Thumb Cluster									|
\*******************************************************************************/

/* [Thumb Cluster] */

// Angle between adjacent thumb keys.
_Cluster_angle		= 10; //[0:1:30]
function Cluster_angle ( ) = _Cluster_angle;

// Number of keys in the inner two thumb columns.
_Cluster_columnCounts	= [1, 2, 1];	//[1:2]
function Cluster_columnCounts ( ) = _Cluster_columnCounts;

// Offset distance of the inner two thumb columns.
_Cluster_columnOffsets	= [0, 0, 0];	//[0:0.125:1]
function Cluster_columnOffsets ( ) = _Cluster_columnOffsets;

// This drives the spacing between the thumb keys.
_Cluster_radius	= 6.5; //[0:0.25:10]
function Cluster_radius ( ) = _Cluster_radius;

function Cluster_radius_mm ( ) = Cluster_radius ( ) * Key_spacing().y;

// Cluster = object ( [
// 	[	"angle",			Cluster_angle			],
// 	[	"columnCounts",		Cluster_columnCounts	],
// 	[	"columnOffsets",	Cluster_columnOffsets	],
// 	[	"radius",			Cluster_radius			],
// 	[	"radiusmm",			Cluster_radiusmm		],
// ] );

/*******************************************************************************\
|									Trackball									|
\*******************************************************************************/

/* [Trackball] */
// Trackball diameter
_Trackball_diameter = 35;	//[25:1:50]
function Trackball_diameter ( ) = _Trackball_diameter;

// Trackball position
_Trackball_position_y = 60;	//[0:200]
_Trackball_position_z = (
	BottomPlate_thickness ( )
	+ BottomPlate_clearance ( )
	+ PCB_thickness ( )
	+ Key_height ( )
);
function Trackball_position ( ) = [
	0,
	Trackball_position_y,
	Trackball_position_z
];

// Trackball clearance
_Trackball_clearance = 1;	//[0:0.1:2]
function Trackball_clearance ( ) = _Trackball_clearance;

/* [Trackball Sensor] */
// Trackball sensor PCB size.
_Trackball_Sensor_PCBsize = [ 16, 25 ]; //[0:30]
function Trackball_Sensor_PCBsize ( ) = _Trackball_Sensor_PCBsize;

// Trackball sensor IC size.
_Trackball_Sensor_size = [ 10.9, 16.2, 1.65 ];
function Trackball_Sensor_size ( ) = _Trackball_Sensor_size;

// Trackball sensor lens size.
_Trackball_Sensor_lensSize = [ 8.6, 16.96, 3.4 ];
function Trackball_Sensor_lensSize ( ) = _Trackball_Sensor_lensSize;

// Distance between trackball sensor lens and trackball.
_Trackball_Sensor_clearance = 2.4;
function Trackball_Sensor_clearance ( ) = _Trackball_Sensor_clearance;

// Diameter of the opening in the trackball case.
_Trackball_Sensor_holeSize = 8;
function Trackball_Sensor_holeSize ( ) = _Trackball_Sensor_holeSize;

// Angle of the trackball sensor from horizontal.
_Trackball_Sensor_angle = 60; //[30:5:90]
function Trackball_Sensor_angle ( ) = _Trackball_Sensor_angle;

// Trackball sensor optical center coordinates.
function Trackball_Sensor_opticalCenter ( ) = [
	7.85,
	15.32,
	(
		-Trackball_Sensor_lensSize.z
		- Trackball_Sensor_clearance
	)
];

/* [Trackball BTU] */
// Trackball BTU main diameter
_Trackball_BTU_D1	= 7.5;
function Trackball_BTU_D1 ( ) = _Trackball_BTU_D1;

// Trackball BTU upper ring diameter
_Trackball_BTU_D		= 9;
function Trackball_BTU_D ( ) = _Trackball_BTU_D;

// Trackball BTU main height
_Trackball_BTU_L		= 4;
function Trackball_BTU_L ( ) = _Trackball_BTU_L;

// Trackball BTU upper ring height
_Trackball_BTU_H		= 1;
function Trackball_BTU_H ( ) = _Trackball_BTU_H;

// Trackball BTU ball height
_Trackball_BTU_L1	= 1.1;
function Trackball_BTU_L1 ( ) = _Trackball_BTU_L1;

// Trackball BTU ball diameter
_Trackball_BTU_d		= 4;
function Trackball_BTU_d ( ) = _Trackball_BTU_d;

// Trackball_Sensor = object ( [
// 	[ "PCBsize",		concat ( Trackball_Sensor_PCBsize, PCB_thickness )	],
// 	[ "size",			Trackball_Sensor_size			],
// 	[ "lensSize",		Trackball_Sensor_lensSize		],
// 	[ "clearance",		Trackball_Sensor_clearance		],
// 	[ "holeSize",		Trackball_Sensor_holeSize		],
// 	[ "angle",			Trackball_Sensor_angle			],
// 	[ "opticalCenter",	Trackball_Sensor_opticalCenter	],
// ] );

// Trackball_BTU = object ( [
// 	[ "D1",	Trackball_BTU_D1	],
// 	[ "D",	Trackball_BTU_D		],
// 	[ "L",	Trackball_BTU_L		],
// 	[ "H",	Trackball_BTU_H		],
// 	[ "L1",	Trackball_BTU_L1	],
// 	[ "d",	Trackball_BTU_d		],
// ] );

// Trackball = object ( [
// 	[ "clearance",	Trackball_clearance	],
// 	[ "diameter",	Trackball_diameter	],
// 	[
// 		"position",
// 		[
// 			0,
// 			Trackball_position_y,
// 			(
// 				Plate.Bottom.thickness
// 				+ Plate.Bottom.clearance
// 				+ PCB.thickness
// 				+ Key.height
// 			)
// 		]
// 	],
// 	[ "Sensor",		Trackball_Sensor	],
// 	[ "BTU",		Trackball_BTU		],
// ] );