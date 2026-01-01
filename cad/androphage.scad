/*******************************************************************************\
|																				|
|						Parameters for Androphage keyboard.						|
|							Copyright 2026 Joshua Lucas 						|
|																				|
|	Length Unit:	millimeter													|
|	Angle Unit:		degree														|
|	x-axis name:	"width" 	/	"inner"	- "outer"							|
|	y-axis name:	"depth" 	/	"front"	- "back"							|
|	z-axis name:	"height"	/	"top"	- "bottom"							|
|																				|
\*******************************************************************************/

include <androphage_globals.scad>

/* [Switches] */
// Radius for corners of switch openings in the switch plate.
Switch_radius = 0.5;	//[0:0.1:1]
// Spacing between keys.
Switch_type = "choc"; //[choc, mx]

/* [Keys] */
// Space between keycaps.
Key_clearance = 0.5; //[0:0.1:1]
Key_height = 16; //[10:30]

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
Plate_Bottom_clearance = 5; //[1:10]

// Radius of the arc at the front of the keyboard.
Plate_frontArcRadius = 20;	//[10:50]
// Radius of the arc at the back of the keyboard.
Plate_backArcRadius = 120;	//[50:200]
// Radius of the arc at the front outer corner of the keyboard.
Plate_outerArcRadius = 20;	//[10:50]

/* [PCB] */
PCB_thickness = 1.6;	//[1:0.2:2]

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
Trackball_diameter = 35;	//[25:1:50]
// Trackball position
Trackball_position = 60;	//[0:200]
// Trackball clearance
Trackball_clearance = 1;	//[0:0.1:2]
// Trackball sensor size
Trackball_Sensor_Size = [ 22, 23.5, 10 ]; //[0:30]
// Trackball sensor angle
Trackball_Sensor_Angle = 60; //[30:5:90]

/* [Colors] */
Color_primary = [ 0.20, 0.20, 0.20, 1.00 ]; //[0.0:0.01:1.0]
Color_secondary = [ 0.50, 0.30, 0.80, 1.00 ];  //[0.0:0.01:1.0]

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
Key_spacing = [Key_MXspacing ? 19 : 18, Key_MXspacing ? 19 : 17, 0];

Key = object ( [
	[ "clearance",		Key_clearance		],
	[ "height",			Switch.height.upper + Keycap.height	],
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

PCB = object ( [
	[ "thickness",	PCB_thickness	],
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

Plate_Switch = object ( [
	[ "edge",		Plate_Switch_edge		],
	[ "present",	Plate_Switch_present	],
	[ "thickness",	Plate_Switch_thickness	],
] );

/*				Top Plate				*/

Plate_Top_edge = Plate_Switch_edge + CaseFrame_thickness;

Plate_Top = object ( [
	[ "edge",		Plate_Top_edge		],
	[ "thickness",	Plate_Top_thickness	],
] );

Plate = object ( [
	[ "Bottom",			Plate_Bottom			],
	[ "Switch",			Plate_Switch			],
	[ "Top",			Plate_Top				],
	[ "backArcRadius",	Plate_backArcRadius		],
	[ "frontArcRadius",	Plate_frontArcRadius	],
	[ "outerArcRadius",	Plate_outerArcRadius	],
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
	[ "size",	Trackball_Sensor_Size	],
	[ "angle",	Trackball_Sensor_Angle	],

] );

Trackball = object ( [
	[ "clearance",	Trackball_clearance	],
	[ "diameter",	Trackball_diameter	],
	[ "position",	Trackball_position	],
	[ "Sensor",		Trackball_Sensor	],
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

function Dimensions () = Dimensions;

include <androphage_assembly.scad>