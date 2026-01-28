/*******************************************************************************\
|				Map all Androphage keyboard parameters to objects.				|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

Battery = object ( [
    [ "color",		Battery_color	],
    [ "size",		Battery_size	],
    [ "visible",	Battery_visible	],
] );

/*******************************************************************************\
|								Center Block									|
\*******************************************************************************/

CenterBlock = object ( [
    [ "color",			CenterBlock_color			],
    [ "height",			CenterBlock_height			],
    [ "ribSize",		CenterBlock_ribSize			],
    [ "screwCount",		CenterBlock_screwCount		],
    [ "wallThickness",	CenterBlock_wallThickness	],
] );

/*******************************************************************************\
|								Thumb Cluster									|
\*******************************************************************************/

Cluster = object ( [
    [ "angle",			Cluster_angle			],
    [ "columnCounts",	Cluster_columnCounts	],
    [ "columnOffsets",	Cluster_columnOffsets	],
    [ "cutout",         Cluster_cutout          ],
    [ "cutouts",		Cluster_cutouts			],
    [ "fiveThumbKeys",  Cluster_fiveThumbKeys   ],
    [ "innerThumbKeyAngle", Cluster_innerThumbKeyAngle ],
    [ "radius",			Cluster_radius			],
    [ "radius_mm",		Cluster_radius_mm		],
] );

/*******************************************************************************\
|									Columns										|
\*******************************************************************************/

Column_Inner = object ( [
    [ "count",	Column_inner_count	],
    [ "offset",	Column_inner_offset	],
] );

Column_Index = object ( [
    [ "count",	Column_index_count	],
    [ "offset",	Column_index_offset	],
] );

Column_Middle = object ( [
    [ "count",	Column_middle_count		],
    [ "offset",	Column_middle_offset	],
] );

Column_Ring = object ( [
    [ "count",	Column_ring_count	],
    [ "offset",	Column_ring_offset	],
] );

Column_Pinky = object ( [
    [ "count",	Column_pinky_count	],
    [ "offset",	Column_pinky_offset	],
] );

Column_Outer = object ( [
    [ "count",	Column_outer_count	],
    [ "offset",	Column_outer_offset	],
] );

Column = object ( [
    [ "Inner",		Column_Inner		],
    [ "Index",		Column_Index		],
    [ "Middle",		Column_Middle		],
    [ "Ring",		Column_Ring			],
    [ "Pinky",		Column_Pinky		],
    [ "Outer",		Column_Outer		],
    [ "last",		Column_last			],
    [ "connectors",	Column_connectors	],
    [ "count",		Column_count		],
    [ "counts",		Column_counts		],
    [ "cutouts",	Column_cutouts		],
    [ "offsets",	Column_offsets		],
] );

/*******************************************************************************\
|										Desk									|
\*******************************************************************************/

Desk = object ( [
    [ "color",		Desk_color		],
    [ "position",	Desk_position	],
    [ "size",		Desk_size		],
] );

/*******************************************************************************\
|									Fasteners									|
\*******************************************************************************/

Screw = object ( [
    [ "centerX",		Screw_centerX		],
    [ "color",			Screw_color			],
    [ "diameter",		Screw_diameter		],
    [ "headAngle",		Screw_headAngle		],
    [ "headDiameter",	Screw_headDiameter	],
    [ "minorDiameter",	Screw_minorDiameter	],
    [ "offset",			Screw_offset		],
] );

Insert = object ( [
    [ "color",			Insert_color			],
    [ "diameter",		Insert_diameter			],
    [ "height",			Insert_height			],
    [ "holeDiameter",	Insert_holeDiameter		],
    [ "holeDepth",		Insert_holeDepth		],
    [ "wallThickness",	Insert_wallThickness	],
] );

/*******************************************************************************\
|										Frame									|
\*******************************************************************************/

Frame = object ( [
    [ "color",			Frame_color			],
    [ "chordAngle",		Frame_chordAngle	],
    [ "extraLength",	Frame_extraLength	],
    [ "filletRadius",	Frame_filletRadius	],
    [ "height",			Frame_height		],
    [ "lipDepth",		Frame_lipDepth		],
    [ "mainRadius",		Frame_mainRadius	],
    [ "notchDepth",		Frame_notchDepth	],
    [ "path",			Frame_path			],
    [ "size",			Frame_size			],
    [ "thickness",		Frame_thickness		],
    [ "visible",		Frame_visible		],
] );

/*******************************************************************************\
|									Halves										|
\*******************************************************************************/

Halves = object ( [
    [ "angles",		Halves_angles		],
    [ "clearance",	Halves_clearance	],
] );

/*******************************************************************************\
|									Hinge										|
\*******************************************************************************/

Hinge_Back = object ( [
    [ "length",		Hinge_Back_length	],
    [ "position",	Hinge_Back_position	],
] );

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

Key = object ( [
    [ "height",		Key_height		],
    [ "mxSpacing",	Key_mxSpacing	],
    [ "spacing",	Key_spacing		],
] );

/*******************************************************************************\
|									Keycaps										|
\*******************************************************************************/

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

MagCon = object ( [
    [ "color",			MagCon_color		],
    [ "lip",			MagCon_lip			],
    [ "lipOffset",		MagCon_lipOffset	],
    [ "pcbSize",		MagCon_pcbSize		],
    [ "pcbPosition",	MagCon_pcbPosition	],
    [ "position",		MagCon_position		],
    [ "size",			MagCon_size			],
] );

/*******************************************************************************\
|										MCU										|
\*******************************************************************************/

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

PCB = object ( [
    [ "color",		PCB_color		],
    [ "edge",		PCB_edge		],
    [ "position",	PCB_position	],
    [ "thickness",	PCB_thickness	],
] );

/*******************************************************************************\
|									Plates										|
\*******************************************************************************/

Plate_Bottom = object ( [
    [ "clearance",	BottomPlate_clearance	],
    [ "color",		BottomPlate_color		],
    [ "edge",		BottomPlate_edge		],
    [ "thickness",	BottomPlate_thickness	],
] );

Plate_Switch = object ( [
    [ "clearance",	SwitchPlate_clearance	],
    [ "color",		SwitchPlate_color		],
    [ "edge",		SwitchPlate_edge		],
    [ "position",	SwitchPlate_position	],
    [ "present",	SwitchPlate_present		],
    [ "radius",		SwitchPlate_radius		],
    [ "thickness",	SwitchPlate_thickness	],
] );

Plate_Top = object ( [
    [ "color",			TopPlate_color			],
    [ "edge",			TopPlate_edge			],
    [ "innerRadius",	TopPlate_innerRadius	],
    [ "position",		TopPlate_position		],
    [ "thickness",		TopPlate_thickness		],
] );

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
|									Switch										|
\*******************************************************************************/

Switch_height = object ( [
    [ "total",	Switch_height_total	],
    [ "upper",	Switch_height_upper	],
    [ "lower",	Switch_height_lower ],
    [ "legs",	Switch_height_legs	],
] );

Switch = object ( [
    [ "height",		Switch_height		],
    [ "maxTravel",	Switch_maxTravel	],
    [ "radius",		Switch_radius		],
    [ "size",		Switch_size			],
    [ "travel",		Switch_travel		],
    [ "type",		Switch_type			],
] );

/*******************************************************************************\
|									Trackball									|
\*******************************************************************************/

Trackball_BTU = object ( [
    [ "color",	Trackball_BTU_color	],
    [ "d",		Trackball_BTU_d		],
    [ "D1",		Trackball_BTU_D1	],
    [ "D",		Trackball_BTU_D		],
    [ "H",		Trackball_BTU_H		],
    [ "L",		Trackball_BTU_L		],
    [ "L1",		Trackball_BTU_L1	],
] );

Trackball_Sensor = object ( [
    [ "angle",				Trackball_Sensor_angle				],
    [ "clearance",			Trackball_Sensor_clearance			],
    [ "color",				Trackball_Sensor_color				],
    [ "holeSize",			Trackball_Sensor_holeSize			],
    [ "holderHeight",		Trackball_Sensor_holderHeight		],
    [ "holderThickness",	Trackball_Sensor_holderThickness	],
    [ "lensColor",			Color.clear							],
    [ "lensSize",			Trackball_Sensor_lensSize			],
    [ "opticalCenter",		Trackball_Sensor_opticalCenter		],
    [ "pcbSize",			Trackball_Sensor_pcbSize			],
    [ "size",				Trackball_Sensor_size				],
] );

Trackball = object ( [
    [ "BTU",		Trackball_BTU		],
    [ "Sensor",		Trackball_Sensor	],
    [ "clearance",	Trackball_clearance	],
    [ "color",		Trackball_color		],
    [ "diameter",	Trackball_diameter	],
    [ "position",	Trackball_position	],
] );