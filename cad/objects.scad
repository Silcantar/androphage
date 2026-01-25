/*******************************************************************************\
|			Calculate derived parameters and map all parameters to objects.		|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

/*******************************************************************************\
|									Battery										|
\*******************************************************************************/

Battery_color = Color_steel;

Battery = object ( [
	[ "color",		Battery_color	],
	[ "size",		Battery_size	],
	[ "visible",	Battery_visible	],
] );

/*******************************************************************************\
|									Case Frame									|
\*******************************************************************************/

Frame_color = Color_primary;

Frame_height = ( CenterBlock_height + TopPlate_thickness ) * cos ( Halves_angles.y );

Frame_size = [ Frame_thickness, Frame_height ];

// Frame_position = [ 0, 0, 0 ];

Frame = object ( [
	[ "color",			Frame_color			],
	[ "chordAngle",		Frame_chordAngle	],
	[ "filletRadius",	Frame_filletRadius	],
	[ "height",			Frame_height		],
	[ "lipDepth",		Frame_lipDepth		],
	[ "mainRadius",		Frame_mainRadius	],
	[ "notchDepth",		Frame_notchDepth	],
	[ "size",			Frame_size			],
	[ "thickness",		Frame_thickness		],
	[ "visible",		Frame_visible		],
] );

/*******************************************************************************\
|								Center Block									|
\*******************************************************************************/

CenterBlock_color = Color_secondary;

CenterBlock_height = (
		BottomPlate_thickness
	+	BottomPlate_clearance
	+	PCB_thickness
	+	Key_height
);

CenterBlock = object ( [
	[ "color",			CenterBlock_color			],
	[ "height",			CenterBlock_height			],
	[ "ribSize",		CenterBlock_ribSize			],
	[ "screwCount",		CenterBlock_screwCount		],
	[ "wallThickness",	CenterBlock_wallThickness	],
	[ "width",			CenterBlock_width			],
] );

/*******************************************************************************\
|									Columns										|
\*******************************************************************************/

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

Column_connectors = [
	[ Key_spacing.x, 90 + Cluster_angle ],
	[ 0, 0 ],
	[ 0, 0 ],
	[ 0, 0 ],
	[ 0, 0 ],
];

Column_inner = object ( [
	[ "count",	Column_inner_count	],
	[ "offset",	Column_inner_offset	],
] );

Column_index = object ( [
	[ "count",	Column_index_count	],
	[ "offset",	Column_index_offset	],
] );

Column_middle = object ( [
	[ "count",	Column_middle_count		],
	[ "offset",	Column_middle_offset	],
] );

Column_ring = object ( [
	[ "count",	Column_ring_count	],
	[ "offset",	Column_ring_offset	],
] );

Column_pinky = object ( [
	[ "count",	Column_pinky_count	],
	[ "offset",	Column_pinky_offset	],
] );

Column_outer = object ( [
	[ "count",	Column_outer_count	],
	[ "offset",	Column_outer_offset	],
] );

Columns = object ( [
	[ "inner",	Column_inner	],
	[ "index",	Column_index	],
	[ "middle",	Column_middle	],
	[ "ring",	Column_ring		],
	[ "pinky",	Column_pinky	],
	[ "outer",	Column_outer	],
] );

/*******************************************************************************\
|										Desk									|
\*******************************************************************************/

Desk_color = Color_clear;

Desk = object ( [
	[ "color",		Desk_color		],
	[ "position",	Desk_position	],
	[ "size",		Desk_size		],
] );

/*******************************************************************************\
|									Fasteners									|
\*******************************************************************************/

Screw_color = Color_steel;

Screw = object ( [
	[ "color",			Screw_color			],
	[ "diameter",		Screw_diameter		],
	[ "headAngle",		Screw_headAngle		],
	[ "headDiameter",	Screw_headDiameter	],
	[ "minorDiameter",	Screw_minorDiameter	],
	[ "offset",			Screw_offset		],
] );

CenterScrews_x = TopPlate_edge - Screw_diameter;

Insert_color = Color_brass;

Insert = object ( [
	[ "color",			Insert_color			],
	[ "diameter",		Insert_diameter			],
	[ "height",			Insert_height			],
	[ "holeDiameter",	Insert_holeDiameter		],
	[ "holeDepth",		Insert_holeDepth		],
	[ "wallThickness",	Insert_wallThickness	],
] );

/*******************************************************************************\
|									Halves										|
\*******************************************************************************/

/* [Halves] */
// Halves Angles
Halves_angles	= [0, 7, 15];	//[-45:45]

Halves_clearance = 1;

Halves = object ( [
	[ "angles",		Halves_angles		],
	[ "clearance",	Halves_clearance	],
] );

/*******************************************************************************\
|									Hinge										|
\*******************************************************************************/

Hinge_color = Color_steel;

Hinge_scale = (Hinge_unit == "inch" ) ? INCH : 1 ;

Hinge_Back_length = (
	+ Hinge_size.y
	- Trackball_position.y
	- Trackball_diameter / 2
	- Trackball_clearance
	+ TopPlate_edge
);

Hinge_Back_position = [
	0,
	Hinge_size.y - BackHinge_length / 2 + TopPlate_edge,
	CenterBlock_height + Hinge_diameter / 2 - Hinge_size.z * cos ( Halves_angles.y )
];

Hinge_Back = object ( [
	[ "length",		Hinge_Back_length	],
	[ "position",	Hinge_Back_position	],
] );

Hinge_Front_length = Trackball_position.y - Trackball_diameter / 2 - Trackball_clearance + TopPlate_edge;

Hinge_Front_position = [
	0,
	Hinge_Front_length / 2 - TopPlate_edge,
	CenterBlock_height + Hinge_diameter / 2 - Hinge_size.z * cos ( Halves_angles.y )
];

Hinge_Front = object ( [
	[ "length",		Hinge_Front_length		],
	[ "position",	Hinge_Front_position	],
] );

Hinge = object ( [
	[ "Back",			Hinge_Back							],
	[ "Front",			Hinge_Front							],
	[ "color",			Hinge_color							],
	[ "diameter",		Hinge_diameter * Hinge_scale		],
	[ "knuckleDepth",	Hinge_knuckleDepth * Hinge_scale	],
	[ "pinDiameter",	Hinge_pinDiameter * Hinge_scale		],
	[ "leafThickness",	Hinge_leafThickness * Hinge_scale	],
	[ "leafWidth",		Hinge_leafWidth * Hinge_scale		],
] );

/*******************************************************************************\
|									Keys										|
\*******************************************************************************/

Key_MXspacing = ( Switch_type == "mx" ) ? true : false;
Key_spacing = Key_MXspacing ? [19, 19] : [18, 17];

/*******************************************************************************\
|									Keycaps										|
\*******************************************************************************/

Key_height = (
	Switch_height_lower
	+ Switch_height_upper
	+ Keycap_height
);

Keycap_height = (
	( Keycap_type == "cherry"	) ? 11	:
	( Keycap_type == "dsa"		) ? 8	:
	( Keycap_type == "lamé"		) ? 6.5	: //6.5
	( Keycap_type == "mbk"		) ? 2.6	: 11
);

Keycap_path = "klp_lame_keycaps/STL/Choc Stem + Choc Size/Choc_Stem_Choc_Size_";

normal	= Keycap_saddle ? "Saddle"			: "Normal";
tilted	= Keycap_saddle ? "Saddle_Tilted"	: "Normal_Tilted";
homing	= Keycap_saddle ? "Saddle_Homing"	: "Normal_Homing";
thumb	= Keycap_saddle ? "Saddle"			: "Thumb";

Keycap_styles = [
	// [ Style, Rotated?, Color ]
	// Inner Column, back -> front
	[ tilted, 1, Color_primary ],
	[ normal, 0, Color_secondary ],
	[ tilted, 0, Color_primary ],
	// Index Column
	// This key can go to the index or thumb:
	Keycap_fiveThumbKeys ? [ thumb, 0, Color_primary ] : [ tilted, 1, Color_primary ],
	Keycap_fiveThumbKeys ? [ tilted, 1, Color_primary ] : [ normal, 1, Color_primary ],
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

Keycap_position_z = (
	+ PCB_position.z
	+ Switch_height_lower
	+ Switch_height_upper
	- Switch_travel
);

Keycap_position = [ 0, 0, Keycap_position_z ];

Keycap = object ( [
	[ "clearance", 		Keycap_clearance		],
	[ "height",			Keycap_height			],
	[ "path",			Keycap_path				],
	[ "position",		Keycap_position			],
	[ "profile",		Keycap_profile			],
	[ "styles",			Keycap_styles			],
	[ "testClearance",	Keycap_testClearance	],
] );

/*******************************************************************************\
|									LEDs										|
\*******************************************************************************/

LED_position = [
	Key_spacing.x - ( LED_count - 1 ) * LED_holeSpacing.x / 2,
	Key_spacing.y / 2 - LED_position_y,
	0
];

LED = object ( [
	[ "present",		LED_present		],
	[ "count",			LED_count		],
	[ "holeShape",		LED_holeShape	],
	[ "holeSize",		LED_holeSize	],
	[ "holeSpacing",	LED_holeSpacing	],
	[ "position",		LED_position	],
] );

/*******************************************************************************\
|								Magnetic Connector								|
\*******************************************************************************/

MagCon_color = Color_primary;

MagCon_pcbPosition = [ MagCon_size.x + MagCon_pcbSize.x / 2, 0, 1 ];

// Position of the connector relative to the Center Block.
MagCon_position		= [
	0,
	19.5,
	(
		+ BottomPlate_thickness
		+ BottomPlate_clearance
		+ PCB_thickness
		+ ( SwitchPlate_present ? Switch_height_lower : 0 )
		+ 5
	)
];

MagCon = object ( [
	[ "color",			MagCon_color		],
	[ "lip",			MagCon_lip			],
	[ "lipOffset",		MagCon_lipOffset	],
	[ "pcbSize",		MagCon_pcbSize		],
	[ "pcbPosition",	MagCon_pcbPosition	],
	[ "position",		MagCon_position		],
] );

/*******************************************************************************\
|										MCU										|
\*******************************************************************************/

MCU_pcbColor = Color_black;

MCU = object ( [
	[ "chipSize",		MCU_chipSize	],
	[ "pcbColor",		MCU_pcbColor	],
	[ "radius",			MCU_radius		],
	[ "size",			MCU_size		],
	[ "usbOverhang",	MCU_usbOverhang	],
	[ "usbRadius",		MCU_usbRadius	],
	[ "usbSize",		MCU_usbSize		],
] );

/*******************************************************************************\
|										PCBs									|
\*******************************************************************************/

PCB_position = [
	0,//CenterBlock_wallThickness,
	0,
	BottomPlate_thickness + BottomPlate_clearance
];

PCB = object ( [
	[ "color",		PCB_color		],
	[ "edge",		PCB_edge		],
	[ "position",	PCB_position	],
	[ "thickness",	PCB_thickness	],
] );

/*******************************************************************************\
|									Plates										|
\*******************************************************************************/

/* [Bottom Plate] */

BottomPlate_color = Color_primary;

BottomPlate_edge = SwitchPlate_edge + Frame_lipDepth;

Plate_Bottom = object ( [
	[ "clearance",	BottomPlate_clearance	],
	[ "color",		BottomPlate_color		],
	[ "edge",		BottomPlate_edge		],
	[ "thickness",	BottomPlate_thickness	],
] );

/* [Switch Plate] */

SwitchPlate_color = Color_secondary;

SwitchPlate_position = PCB_position + [
	0,
	0,
	PCB_thickness + Switch_height_lower - SwitchPlate_thickness
];

SwitchPlate_thickness = Key_MXspacing ? 1.6 : 1.2;

Plate_Switch = object ( [
	[ "clearance",	SwitchPlate_clearance	],
	[ "color",		SwitchPlate_color		],
	[ "edge",		SwitchPlate_edge		],
	[ "position",	SwitchPlate_position	],
	[ "present",	SwitchPlate_present		],
	[ "radius",		SwitchPlate_radius		],
	[ "thickness",	SwitchPlate_thickness	],
] );

/* [Top Plate] */

TopPlate_color = Color_primary;

TopPlate_edge = SwitchPlate_edge + Frame_lipDepth;

TopPlate_position = [
	0,
	0,
	(
		+ BottomPlate_thickness
		+ BottomPlate_clearance
		+ PCB_thickness
		+ Key_height
	) * cos ( Halves_angles.y )
];

Plate_Top = object ( [
	[ "color",			TopPlate_color			],
	[ "edge",			TopPlate_edge			],
	[ "innerRadius",	TopPlate_innerRadius	],
	[ "position",		TopPlate_position		],
	[ "thickness",		TopPlate_thickness		],
] );

/* [Plates Common] */

Plate_frontArcRadius = ( Cluster_radius - 0.5 ) * Key_spacing.y;

Plate_outerArcChord = [
	Key_spacing.x + SwitchPlate_edge,
	Key_spacing.y / 2
];

Plate_outerArcAngle = atan ( Plate_outerArcChord.y / Plate_outerArcChord.x );

// Radius of the arc at the front outer corner of the keyboard.
Plate_outerArcRadius = norm ( Plate_outerArcChord ) / 2 / sin ( Plate_outerArcAngle );

// Fillet radius for the outside corners of the plates.
Plate_outerRadius = Frame_lipDepth;

Plate = object ( [
	[ "Bottom",				Plate_Bottom			],
	[ "Switch",				Plate_Switch			],
	[ "Top",				Plate_Top				],
	[ "backArcRadius",		Plate_backArcRadius		],
	[ "centerArcRadius",	Plate_centerArcRadius	],
	[ "frontArcRadius",		Plate_frontArcRadius	],
	[ "outerArcAngle",		Plate_outerArcAngle		],
	[ "outerArcChord",		Plate_outerArcChord		],
	[ "outerArcRadius",		Plate_outerArcRadius	],
	[ "outerRadius",		Plate_outerRadius		],
] );

/*******************************************************************************\
|									Switches									|
\*******************************************************************************/

Switch_size = Key_testClearance ? [
	Key_spacing.x - Key_clearance,
	Key_spacing.y - Key_clearance
] : [ 14, 14 ];

Switch_travel = 0;
Switch_maxTravel = 3.3;

// Variables used by choc_switch.scad.
$choc_version = ( Switch_type == switch_chocv1 ) ? 1 : 2;

$color_scheme = Switch_colorScheme;

Switch_height_total = (Switch_type == "mx") ? 14.9 : 11.0;
Switch_height_upper = (Switch_type == "mx") ? 6.6 : 5.8;
Switch_height_lower = (Switch_type == "mx") ? 5.0 : 2.2;
Switch_height_legs = (Switch_type == "mx") ? 3.3 : 3.0;

Switch_height = object ( [
	[ "total",	Switch_height_total	],
	[ "upper",	Switch_height_upper	],
	[ "lower",	Switch_height_lower ],
	[ "legs",	Switch_height_legs	],
] );

Switch_position_z = PCB_position.z + PCB_thickness;

Switch = object ( [
	[ "height",		Switch_height		],
	[ "maxTravel",	Switch_maxTravel	],
	[ "radius",		Switch_radius		],
	[ "size",		Switch_size			],
	[ "travel",		Switch_travel		],
	[ "type",		Switch_type			],
] );

/*******************************************************************************\
|								Thumb Cluster									|
\*******************************************************************************/

Cluster_radius_mm = Cluster_radius * Key_spacing.y;

Cluster = object ( [
	[ "angle",			Cluster_angle			],
	[ "columnCounts",	Cluster_columnCounts	],
	[ "columnOffsets",	Cluster_ColumnOffsets	],
	[ "radius",			Cluster_radius			],
	[ "radius_mm",		Cluster_radius_mm		],
	[ "cutouts",		Cluster_cutouts			],
] );

/*******************************************************************************\
|									Trackball									|
\*******************************************************************************/

/* [Trackball BTU] */

Trackball_BTU_color = Color_steel;

Trackball_BTU = object ( [
	[ "color",	Trackball_BTU_color	],
	[ "d",		Trackball_BTU_d		],
	[ "D1",		Trackball_BTU_D1	],
	[ "D",		Trackball_BTU_D		],
	[ "H",		Trackball_BTU_H		],
	[ "L",		Trackball_BTU_L		],
	[ "L1",		Trackball_BTU_L1	],
] );

/* [Trackball Sensor] */

Trackball_Sensor_color = Color_black;

Trackball_Sensor_pcbSize = concat ( 
	Trackball_Sensor_pcbSize_xy, 
	[ PCB_thickness ] 
);

// Trackball sensor optical center coordinates.
Trackball_Sensor_opticalCenter = [
	7.85,
	15.32,
	(
		-Trackball_Sensor_lensSize.z
		- Trackball_Sensor_clearance
	)
];

Trackball_Sensor = object ( [
	[ "angle",				Trackball_Sensor_angle				],
	[ "clearance",			Trackball_Sensor_clearance			],
	[ "color",				Trackball_Sensor_color				],
	[ "holeSize",			Trackball_Sensor_holeSize			],
	[ "holderHeight",		Trackball_Sensor_holderHeight		],
	[ "holderThickness",	Trackball_Sensor_holderThickness	],
	[ "lensSize",			Trackball_Sensor_lensSize			],
	[ "pcbSize",			Trackball_Sensor_pcbSize			],
	[ "size",				Trackball_Sensor_size				],
] );

/* [Trackball] */

Trackball_color = Color_secondary;

Trackball_position_z = (
	+ TopPlate_position.z
	+ TopPlate_thickness * cos ( Halves_angles.z )
);

Trackball_position = [
	0,
	Trackball_position_y,
	Trackball_position_z
];

Trackball_= object ( [
	[ "BTU",		Trackball_BTU		],
	[ "Sensor",		Trackball_Sensor	],
	[ "clearance",	Trackball_clearance	],
	[ "color",		Trackball_color		],
	[ "diameter",	Trackball_diameter	],
	[ "position",	Trackball_position	],
] );