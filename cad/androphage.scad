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

function last (vector) = len(vector) - 1;

/* [Hidden] */
$fa = 1;
$fs = 0.1;

// "Enum" of fingers/columns.
function finger () = object (
	inner	= 0,
	index	= 1,
	middle	= 2,
	ring	= 3,
	pinky	= 4,
	outer	= 5,
);

/* [Switches] */
// Radius for corners of switch openings in the switch plate.
Switch_radius = 0.5;	//[0:0.1:1]
// Spacing between keys.
Switch_type = "choc"; //[choc, mx]

/* [Keys] */
// Space between keycaps.
Key_clearance = 0.5; //[0:0.1:1]
//Key_height = 16; //[10:30]

Keycap_type = "lamé"; //[ "cherry", "dsa", "lamé", "mbk", ]

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
Plate_Switch_edge		= 2; //[1:5]
Plate_Switch_present	= true;

Plate_Bottom_thickness = 1.6;	//[1:0.2:2]
Plate_Bottom_clearance = 2; //[1:10]

// Radius of the arc at the front of the keyboard.
Plate_centerArcRadius = 20;	//[10:50]
// Radius of the arc at the back of the keyboard.
Plate_backArcRadius = 120;	//[50:200]
// Radius of the arc at the front outer corner of the keyboard.
Plate_outerArcRadius = 20;	//[10:50]

/* [PCB] */
PCB_thickness = 1.6;	//[1:0.2:2]

/* [Case Frame] */
CaseFrame_thickness = 3; //[1:5]

/* [Center Block] */
CenterBlock_width = 25; //[1:50]

/* [Hinge] */
// Hinge Length
Hinge_length	= 90;	//[50:1:200]

// Halves Angles
Halves_angles	= [0, 5, 15];	//[-45:45]

/* [Trackball] */
// Trackball diameter
Trackball_diameter = 35;	//[25:1:50]
// Trackball position
Trackball_position_y = 60;	//[0:200]
// Trackball clearance
Trackball_clearance = 1;	//[0:0.1:2]

/* [Trackball Sensor] */
// Trackball sensor PCB size
Trackball_Sensor_PCBsize = [ 16, 25 ]; //[0:30]
Trackball_Sensor_size = [ 10.9, 16.2, 1.65 ];
Trackball_Sensor_lensSize = [ 8.6, 16.96, 3.4 ];
Trackball_Sensor_clearance = 2.4;
Trackball_Sensor_holeSize = 8;
// Trackball sensor angle
Trackball_Sensor_angle = 60; //[30:5:90]
// Trackball sensor optical center coords
Trackball_Sensor_opticalCenter = [
	7.85,
	15.32,
	-Trackball_Sensor_lensSize.z
		- Trackball_Sensor_clearance
];

/* [Trackball BTU] */
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

/* [Colors] */
Color_primary = [ 0.20, 0.20, 0.20, 1.00 ]; //[0.0:0.01:1.0]
Color_secondary = [ 0.50, 0.30, 0.80, 1.00 ];  //[0.0:0.01:1.0]

function Color () = object ( [
	[ "primary",	Color_primary	],
	[ "secondary",	Color_secondary	],
	[ "clear",		[ 1.0, 1.0, 1.0, 0.2 ] ],
	[ "cut",		[ 1.0, 1.0, 0.0, 0.2 ] ],
] );

/*				Switches				*/

Switch_size = [
	Key_testClearance ? Key_spacing.x - Key_clearance : 14,
	Key_testClearance ? Key_spacing.y - Key_clearance : 14,
];

Switch_height = object ( [
	[ "total",	(Switch_type == "mx") ? 14.9 : 11.0	],
	[ "upper",	(Switch_type == "mx") ? 6.6 : 5.8	], // Excludes MX stem.
	[ "lower",	(Switch_type == "mx") ? 5.0 : 2.2	],
	[ "legs",	(Switch_type == "mx") ? 3.3 : 3.0	],
] );

Switch = object ( [
	[ "height",	Switch_height	],
	[ "radius",	Switch_radius	],
	[ "size",	Switch_size		],
	[ "type",	Switch_type		],
] );

/*				Keycaps				*/

keycapHeight = object ( [
	[ "cherry",	11	],
	[ "dsa",	8	],
	[ "lamé",	6.5	],
	[ "mbk",	2.6	],
] );

Keycap = object ( [
	[ "height",	keycapHeight[Keycap_type]	],
	[ "type",	Keycap_type					],
] );

/*				Keys				*/

Key_MXspacing = (Switch_type == "mx") ? true : false;
Key_spacing = [Key_MXspacing ? 19 : 18, Key_MXspacing ? 19 : 17 ];
Key_height = (
	Switch.height.lower
	+ Switch.height.upper
	+ Keycap.height
);

Key = object ( [
	[ "clearance",		Key_clearance		],
	[ "height", 		Key_height			],
	[ "MXspacing",		Key_MXspacing		],
	[ "spacing",		Key_spacing			],
	[ "testClearance",	Key_testClearance	],
] );

/*				Thumb Cluster				*/

Cluster_radiusmm = Cluster_radius * Key_spacing.y;

Cluster = object ( [
	[	"angle",			Cluster_angle			],
	[	"columnCounts",		Cluster_columnCounts	],
	[	"columnOffsets",	Cluster_columnOffsets	],
	[	"radius",			Cluster_radius			],
	[	"radiusmm",			Cluster_radiusmm		],
] );

/*				Columns				*/

Column_counts_init = [
	Column_inner_count,
	Column_index_count,
	Column_middle_count,
	Column_ring_count,
	Column_pinky_count,
	Column_outer_count,
];

Column_count	= len ( [
	for (i = [last (Column_counts_init) : -1 : 0])
		if ( i != 0 )
			i
] );
Column_last		= Column_count - 1;

Column_counts	= [ for (i = [0:Column_last]) Column_counts_init[i] ];

Column_offsets_init = [
	Column_inner_offset,
	Column_index_offset,
	Column_middle_offset,
	Column_ring_offset,
	Column_pinky_offset,
	Column_outer_offset,
];

Column_offsets	= [ for (i = [0:Column_last]) Column_offsets_init[i] ];

Column = object ( [
	[ "count",		Column_count	],
	[ "counts",		Column_counts	],
	[ "last", 		Column_last		],
	[ "offsets",	Column_offsets	],
] );

/*				PCB				*/
PCB_position = [
	0,
	0,
	Plate_Bottom_clearance + Switch.height.legs
];

PCB = object ( [
	[ "thickness",	PCB_thickness	],
	[ "position",	PCB_position	],
] );

/*				Bottom Plate				*/

Plate_Bottom_edge = Plate_Switch_edge + CaseFrame_thickness;

Plate_Bottom = object ( [
	[ "edge",		Plate_Bottom_edge		],
	[ "thickness",	Plate_Bottom_thickness	],
	[ "clearance",	Plate_Bottom_clearance	],
] );

/*				Switch Plate				*/

Plate_Switch_thickness = Key_MXspacing ? 1.6 : 1.2;

Plate_Switch_position = [
	0,
	0,
	(
		Plate_Bottom_clearance
		+ Switch.height.legs
		+ Switch.height.lower
	)
];

Plate_Switch = object ( [
	[ "edge",		Plate_Switch_edge		],
	[ "present",	Plate_Switch_present	],
	[ "thickness",	Plate_Switch_thickness	],
	[ "position",	Plate_Switch_position	],
] );

/*				Top Plate				*/

Plate_Top_edge = Plate_Switch_edge + CaseFrame_thickness;

Plate_Top_position = [
	0,
	0,
	(
		Plate_Bottom_thickness
		+ Plate_Bottom_clearance
		+ PCB_thickness
		+ Key_height
	)
];

Plate_Top = object ( [
	[ "edge",		Plate_Top_edge		],
	[ "thickness",	Plate_Top_thickness	],
	[ "position",	Plate_Top_position	],
] );

Plate_frontArcRadius = ( Cluster_radius - 0.5 ) * Key_spacing.y;

Plate = object ( [
	[ "Bottom",				Plate_Bottom			],
	[ "Switch",				Plate_Switch			],
	[ "Top",				Plate_Top				],
	[ "backArcRadius",		Plate_backArcRadius		],
	[ "centerArcRadius",	Plate_centerArcRadius	],
	[ "frontArcRadius",		Plate_frontArcRadius	],
	[ "outerArcRadius",		Plate_outerArcRadius	],
] );

/*				Case Frame				*/

CaseFrame = object ( [
	[ "thickness",	CaseFrame_thickness	],
] );

CenterBlock = object ( [
	[ "width",	CenterBlock_width	],
] );

Halves = object ( [
	[ "angles", Halves_angles ],
] );

Hinge = object ( [
	[ "length",		Hinge_length	],
] );

Trackball_Sensor = object ( [
	[ "PCBsize",		concat ( Trackball_Sensor_PCBsize, PCB_thickness )	],
	[ "size",			Trackball_Sensor_size			],
	[ "lensSize",		Trackball_Sensor_lensSize		],
	[ "clearance",		Trackball_Sensor_clearance		],
	[ "holeSize",		Trackball_Sensor_holeSize		],
	[ "angle",			Trackball_Sensor_angle			],
	[ "opticalCenter",	Trackball_Sensor_opticalCenter	],
] );

Trackball_BTU = object ( [
	[ "D1",	Trackball_BTU_D1	],
	[ "D",	Trackball_BTU_D		],
	[ "L",	Trackball_BTU_L		],
	[ "H",	Trackball_BTU_H		],
	[ "L1",	Trackball_BTU_L1	],
	[ "d",	Trackball_BTU_d		],
] );

Trackball = object ( [
	[ "clearance",	Trackball_clearance	],
	[ "diameter",	Trackball_diameter	],
	[
		"position",
		[
			0,
			Trackball_position_y,
			(
				Plate.Bottom.thickness
				+ Plate.Bottom.clearance
				+ PCB.thickness
				+ Key.height
			)
		]
	],
	[ "Sensor",		Trackball_Sensor	],
	[ "BTU",		Trackball_BTU		],
] );

Dimensions = object ( [
	[ "CaseFrame",		CaseFrame	],
	[ "CenterBlock",	CenterBlock	],
	[ "Cluster",		Cluster		],
	[ "Column",			Column		],
	[ "Halves",			Halves		],
	[ "Hinge",			Hinge		],
	[ "Key",			Key			],
	[ "Keycap",			Keycap		],
	[ "PCB",			PCB			],
	[ "Plate",			Plate		],
	[ "Switch",			Switch		],
	[ "Trackball",		Trackball	],
] );

function Dimensions ( ) = Dimensions;

use <androphage_assembly.scad>

androphage_assembly ( );