/*******************************************************************************\
|				Calculate derived parameters for Androphage keyboard.			|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

/*******************************************************************************\
|								Prerequisites									|
\*******************************************************************************/

Cluster_innerThumbKeyAngle = len ( Cluster_columnCounts ) * Cluster_angle;

Key_mxSpacing = ( Switch_type == "mx" ) ? true : false;
Key_spacing = Key_mxSpacing ? [19, 19] : [18, 17];

Keycap_height = (
    ( Keycap_profile == "cherry"	) ? 11	:
    ( Keycap_profile == "dsa"		) ? 8	:
    ( Keycap_profile == "lamé"		) ? 6.5	: //6.5
    ( Keycap_profile == "mbk"		) ? 2.6	: 11
);

Switch_height_total = (Switch_type == "mx") ? 14.9 : 11.0;
Switch_height_upper = (Switch_type == "mx") ? 6.6 : 5.8;
Switch_height_lower = (Switch_type == "mx") ? 5.0 : 2.2;
Switch_height_legs = (Switch_type == "mx") ? 3.3 : 3.0;

Key_height = (
    Switch_height_lower
    + Switch_height_upper
    + Keycap_height
);

PCB_position = [
    0,//CenterBlock_wallThickness,
    0,
    BottomPlate_thickness + BottomPlate_clearance
];

TopPlate_edge = SwitchPlate_edge + Frame_lipDepth;

/*******************************************************************************\
|									Battery										|
\*******************************************************************************/

Battery_color = Color_steel;

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
    for (i = [ len ( _Column_counts_init ) - 1 : -1 : 0 ] )
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

/*******************************************************************************\
|										Desk									|
\*******************************************************************************/

Desk_color = Color_clear;

/*******************************************************************************\
|									Fasteners									|
\*******************************************************************************/

Screw_color = Color_steel;

Screw_centerX = TopPlate_edge - Screw_diameter;

Insert_color = Color_brass;

/*******************************************************************************\
|										Frame									|
\*******************************************************************************/

Frame_color = Color_primary;

Frame_height = ( CenterBlock_height + TopPlate_thickness ) * cos ( Halves_angles.y );

Frame_size = [ Frame_thickness, Frame_height ];

/*******************************************************************************\
|									Hinge										|
\*******************************************************************************/

Hinge_color = Color_steel;

Hinge_scale = (Hinge_unit == "inch" ) ? INCH : 1 ;

Hinge_Back_length = (
    + Hinge_length
    - Trackball_position_y
    - Trackball_diameter / 2
    - Trackball_clearance
    + TopPlate_edge
);

Hinge_Back_position = [
    0,
    Hinge_length - Hinge_Back_length / 2 + TopPlate_edge,
    CenterBlock_height + Hinge_diameter / 2 - Hinge_leafThickness * cos ( Halves_angles.y )
];

Hinge_Front_length = Trackball_position_y - Trackball_diameter / 2 - Trackball_clearance + TopPlate_edge;

Hinge_Front_position = [
    0,
    Hinge_Front_length / 2 - TopPlate_edge,
    CenterBlock_height + Hinge_diameter / 2 - Hinge_leafThickness * cos ( Halves_angles.y )
];

/*******************************************************************************\
|									Keycaps										|
\*******************************************************************************/

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
    Cluster_fiveThumbKeys ? [ thumb, 0, Color_primary ] : [ tilted, 1, Color_primary ],
    Cluster_fiveThumbKeys ? [ tilted, 1, Color_primary ] : [ normal, 1, Color_primary ],
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

/*******************************************************************************\
|									LEDs										|
\*******************************************************************************/

LED_position = [
    Key_spacing.x - ( LED_count - 1 ) * LED_holeSpacing.x / 2,
    Key_spacing.y / 2 - LED_position_y,
    0
];

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

/*******************************************************************************\
|										MCU										|
\*******************************************************************************/

MCU_pcbColor = Color_black;

/*******************************************************************************\
|									Plates										|
\*******************************************************************************/

/* [Bottom Plate] */

BottomPlate_color = Color_primary;

BottomPlate_edge = SwitchPlate_edge + Frame_lipDepth;

/* [Switch Plate] */

SwitchPlate_color = Color_secondary;

SwitchPlate_thickness = Key_mxSpacing ? 1.6 : 1.2;

SwitchPlate_position = PCB_position + [
    0,
    0,
    PCB_thickness + Switch_height_lower - SwitchPlate_thickness
];

/* [Top Plate] */

TopPlate_color = Color_primary;

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

/* [Plates Common] */

Plate_backEdgeAngle = atan ( ( 2 * Key_spacing.x ) / Key_spacing.y );

Plate_backEdgeLength = (
    1.25 * sqrt (
        ( 2 * Key_spacing.x ) ^ 2
        + Key_spacing.y ^ 2
    )
    + sin ( Plate_backEdgeAngle ) * SwitchPlate_edge
);

Plate_backArcAngle = 180 - (
    - 2 * Cluster_innerThumbKeyAngle
    - Halves_angles.z
    + Plate_backEdgeAngle
    + 180
);

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

Plate_outerEdgeLength = (
      3 * Key_spacing.y
    + ( 1 + cos ( Plate_backEdgeAngle ) ) * SwitchPlate_edge
);

/*******************************************************************************\
|									Switches									|
\*******************************************************************************/

Switch_size = Keycap_testClearance ? [
    Key_spacing.x - Keycap_clearance,
    Key_spacing.y - Keycap_clearance
] : [ 14, 14 ];

// Variables used by choc_switch.scad.
$choc_version = ( Switch_type == switch_chocv1 ) ? 1 : 2;

$color_scheme = Switch_colorScheme;

Switch_position_z = PCB_position.z + PCB_thickness;

/*******************************************************************************\
|								Thumb Cluster									|
\*******************************************************************************/

Cluster_radius_mm = Cluster_radius * Key_spacing.y;

/*******************************************************************************\
|									Trackball									|
\*******************************************************************************/

/* [Trackball BTU] */

Trackball_BTU_color = Color_steel;

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

/*******************************************************************************\
|								Postrequisites									|
\*******************************************************************************/

l = "l"; // Linear extrude
m = "m"; // Mitered corner
r = "r"; // Rotate extrude (revolve)

Frame_path = [
//		Type,	Height / Radius,							Angle,											Profile Number
    [	l,		Frame_extraLength,							0,												0,	], //0
    [	r,		-Plate_backArcRadius,						43 - Plate_backArcAngle,						0,	], //1
    [	r,		0,											43,												0,	], //2
    [	l,		Plate_backEdgeLength,						0,												0,	], //3
    [	r,		0,											Plate_backEdgeAngle,							0,	], //4
    [	l,		Plate_outerEdgeLength,						0,												0,	], //5
    [	r,		0,											90,												0,	], //6
    [	r,		-Plate_outerArcRadius,						2 * Plate_outerArcAngle,						0,	], //7
    [	r,		0,											2 * Plate_outerArcAngle,						0,	], //8
    [	l,		2 * Key_spacing.x + Frame_notchDepth,		0,												0,	], //9
    [	l,		Key_spacing.x / 2 - Frame_notchDepth,		0,												1,	], //10
    [	r,		-Plate_frontArcRadius + SwitchPlate_edge,	Cluster_innerThumbKeyAngle,						1,	], //11
    [	l,		Key_spacing.x / 2 - Frame_notchDepth,		0,												1,	], //12
    [	l,		SwitchPlate_edge + Frame_notchDepth,		0,												0,	], //13
    [	r,		0,											90,												0,	], //14
    [	l,		SwitchPlate_edge,							0,												0,	], //15
    [	r,		-Plate_centerArcRadius + SwitchPlate_edge,	Cluster_innerThumbKeyAngle + Halves_angles.z,	0,	], //16
    [	l,		Frame_extraLength + 1,						0,												0,	], //17
];