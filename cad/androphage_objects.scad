/*****************************************************************************\
|								Create parameter objects for Androphage keyboard.							|
|													Copyright 2025 Joshua Lucas 												|
\*****************************************************************************/

/*				Keys				*/

Key_MXspacing = (Switch_type == "MX") ? true : false;
Key_spacing = [Key_MXspacing ? 19 : 18, Key_MXspacing ? 19 : 17, 0];

Key = object ( [
	[	"clearance",			Key_clearance			],
	[	"MXspacing",			Key_MXspacing			],
	[	"spacing",				Key_spacing				],
	[	"testClearance",	Key_testClearance	],
] );

/*				Switches				*/

Switch_size = [
	Key_testClearance ? Key_spacing.x - Key_clearance : 14,
	Key_testClearance ? Key_spacing.y - Key_clearance: 14,
];

Switch = object ( [
	[	"radius",	Switch_radius	],
	[	"size",		Switch_size		],
	[	"type",		Switch_type		],
] );

/*				Thumb Cluster				*/

Cluster_radiusmm = Cluster_radius * Key_spacing.y;

Cluster = object ( [
	[	"angle",					Cluster_angle					],
	[	"columnCounts",		Cluster_columnCounts	],
	[	"columnOffsets",	Cluster_columnOffsets	],
	[	"radius",					Cluster_radius				],
	[	"radiusmm",				Cluster_radiusmm			],
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
	[ "count",		Column_count		],
	[ "counts",		Column_counts		],
	[ "last", 		Column_last			],
	[ "offsets",	Column_offsets	],
] );

/*				Bottom Plate				*/

BottomPlate_edge = SwitchPlate_edge + CaseFrame_thickness;

BottomPlate = object ( [
	[ "edge",				BottomPlate_edge			],
	[ "thickness",	BottomPlate_thickness	],
] );

/*				Switch Plate				*/

SwitchPlate_thickness = Key_MXspacing ? 1.6 : 1.2;

SwitchPlate = object ( [
	[	"edge",				SwitchPlate_edge			],
	[	"thickness", SwitchPlate_thickness	],
] );

/*				Top Plate				*/

TopPlate_edge			= SwitchPlate_edge + CaseFrame_thickness;

TopPlate = object ( [
	[ "edge",				TopPlate_edge				],
	[ "thickness",	TopPlate_thickness	],
] );

/*				Case Frame				*/

CaseFrame = object ( [
	[ "thickness",	CaseFrame_thickness	],
] );

Hinge = object ( [
	[ "angle",		Hinge_angle		],
	[ "length",		Hinge_length	],
] );