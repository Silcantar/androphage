/*******************************************************************************\
|						Deprecated, combined with androphage.scad				|
|					Create parameter objects for Androphage keyboard.			|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

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