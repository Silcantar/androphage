/*******************************************************************************\
|				Calculate derived parameters for Androphage keyboard.			|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

use <library/choc_switch.scad>

/*******************************************************************************\
|								Prerequisites									|
\*******************************************************************************/

Cluster_innerThumbKeyAngle = ( len ( Cluster_columnCounts ) - 1 ) * Cluster_angle;

// Key_mxSpacing = ( Switch_type == switch_mx ) ? true : false;

Key_spacing = (
    ( Key_spacingType == "choc" ) ? [ 18, 17 ] :
    ( Key_spacingType == "mx" ) ? [ 19, 19 ] :
    Key_customSpacing
);
// Key_spacing = Key_mxSpacing ? [19, 19] : [18, 17];

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
|								Thumb Cluster									|
\*******************************************************************************/

Cluster_radius_mm = Cluster_radius * Key_spacing.y;

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
    for ( i = [ len ( _Column_counts_init ) - 1 : -1 : 0 ] )
        if ( _Column_counts_init[i] != 0 )
            i
] );

Column_last = Column_count - 1;

echo ( Column_last );

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

_Column_splay_init = [
	Column_inner_splay,
	Column_index_splay,
	Column_middle_splay,
	Column_ring_splay,
	Column_pinky_splay,
	Column_outer_splay
];

Column_splay = [ for ( i = [ 0 : Column_last ] ) _Column_splay_init [ i ] ];

Column_cutouts = [ 0, 1, 0, 0, 0 ];

// Column_connectors = [
//     [ Key_spacing.x, 90 + Cluster_angle ],
//     [ 0, 0 ],
//     [ 0, 0 ],
//     [ 0, 0 ],
//     [ 0, 0 ],
// ];

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

Frame_height = (
    CenterBlock_height
) * cos ( Halves_angles.y );

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

Hinge_zpos = (
    CenterBlock_height
    + Hinge_diameter / 2
    - Hinge_leafThickness// * cos ( Halves_angles.y )
);

Hinge_Back_position = [
    0,
    Hinge_length - Hinge_Back_length / 2 + TopPlate_edge,
    Hinge_zpos
];

Hinge_Front_length = (
    Trackball_position_y
    - Trackball_diameter / 2
    - Trackball_clearance
    + TopPlate_edge
);

Hinge_Front_position = [
    0,
    Hinge_Front_length / 2 - TopPlate_edge,
    Hinge_zpos
];

/*******************************************************************************\
|									Keycaps										|
\*******************************************************************************/

// Keycap_path = "klp_lame_keycaps/STL/Choc Stem + Choc Size/Choc_Stem_Choc_Size_";

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
    // + PCB_position.z
    // + Switch_height_lower
    + Switch_height_upper
    - Switch_travel
);

Keycap_position = [ 0, 0, Keycap_position_z ];

/*******************************************************************************\
|									LEDs										|
\*******************************************************************************/

LED_position = [
    Key_spacing.x - ( LED_count - 1 ) * LED_holeSpacing.x / 2,
    Key_spacing.y / 2 + LED_position_y,
    0
];

/*******************************************************************************\
|								Magnetic Connector								|
\*******************************************************************************/

MagCon_color = Color_primary;

MagCon_pcbSize = [ PCB_thickness, 36.5, 10 ];

MagCon_pcbPosition = [ MagCon_size.x + MagCon_pcbSize.x / 2, 0, 0 ];

// Position of the connector relative to the Center Block.
MagCon_position		= [
    0,
    27.5,
    (
        + BottomPlate_thickness
        + BottomPlate_clearance
        + PCB_thickness
        + ( SwitchPlate_present ? Switch_height_lower : 0 )
        + 1
    )
];

/*******************************************************************************\
|										MCU										|
\*******************************************************************************/

MCU_pcbColor = Color_black;

/*******************************************************************************\
|									LEDs										|
\*******************************************************************************/

OLED_position = [
    Key_spacing.x,
    Key_spacing.y / 2 + OLED_position_y,
    0
];

/*******************************************************************************\
|										PCB										|
\*******************************************************************************/

// Distance from keys to edge of PCB.
PCB_edge = SwitchPlate_edge;

/*******************************************************************************\
|									Plates										|
\*******************************************************************************/

/* [Bottom Plate] */

BottomPlate_color = Color_primary;

BottomPlate_edge = SwitchPlate_edge + Frame_lipDepth;

/* [Switch Plate] */

SwitchPlate_color = Color_secondary;

SwitchPlate_thickness = ( Switch_type == switch_mx ) ? 1.6 : 1.2;

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
        - TopPlate_thickness
    )
];

/* [Plates Common] */

Plate_backEdge = (
    [ 0, -( Column_counts[middle] + 0.5 ) * Key_spacing.y - SwitchPlate_edge ] * rot2d ( Column_splay[middle], affine = false )
    + [ ( Column_last - middle ) * Key_spacing.x, ( Column_offsets[Column_last] - Column_offsets[middle] ) * Key_spacing.y ]
    + [ 0, ( Column_counts[Column_last] + 0.5 ) * Key_spacing.y + SwitchPlate_edge ] * rot2d ( Column_splay[Column_last], affine = false )
);

// echo ( Plate_backEdge );

Plate_backEdgeAngle = (
    90 + atan ( Plate_backEdge.y / Plate_backEdge.x )
    + Column_splay[Column_last]
);

echo ( Plate_backEdgeAngle );

Plate_backEdgeLength = norm ( Plate_backEdge ) + ( Key_spacing.x / 2 + SwitchPlate_edge ) / sin ( Plate_backEdgeAngle);

Plate_backArcAngle = 180 - (
    Halves_angles.z
    + Column_splay[Column_last]
    + Plate_backEdgeAngle
    + Plate_backCornerAngle
);

echo (Plate_backArcAngle);

Plate_frontArcRadius = ( Cluster_radius - 0.5 ) * Key_spacing.y;

Plate_outerArcChord = [
    Key_spacing.x / 2,
    Column_offsets[Column_last] * Key_spacing.y
];

Plate_outerArcAngle = 2 * atan ( Plate_outerArcChord.y / Plate_outerArcChord.x );

// Radius of the arc at the front outer corner of the keyboard.
Plate_outerArcRadius = Plate_outerArcChord.x * norm ( Plate_outerArcChord ) / Plate_outerArcChord.y;//norm ( Plate_outerArcChord ) / 2 / sin ( Plate_outerArcAngle );

// Fillet radius for the outside corners of the plates.
Plate_outerRadius = Frame_lipDepth;

Plate_outerEdgeLength = (
      ( Column_counts[Column_last] ) * Key_spacing.y
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

$color_scheme = choc_color_name_to_number ( Switch_chocColor );

Switch_position_z = PCB_position.z + PCB_thickness;

/*******************************************************************************\
|									Trackball									|
\*******************************************************************************/

/* [Trackball BTU] */

Trackball_BTU_color = Color_steel;

/* [Trackball Sensor] */

Trackball_Sensor_color = Color_black;

Trackball_Sensor_lensColor = Color_clear;

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

Frame_path = [
//		Type,	Height / Radius,							Angle,											Profile Number
    [	l,		Frame_extraLength + Hinge_offset,			0,												0,	], //0
    [	r,		-Plate_backArcRadius,                   	Plate_backArcAngle,		                        0,	], //1
    [	r,		0,                 							Plate_backCornerAngle,							0,	], //2
    [	l,		Plate_backEdgeLength,						0,												0,	], //3
    [	r,		0,											Plate_backEdgeAngle,							0,	], //4
    [	l,		Plate_outerEdgeLength,						0,												0,	], //5
    [	r,		0,											90 - Column_splay[Column_last],					0,	], //6
    [   l,      ( Column_last - pinky ) * Key_spacing.x,    0,                                              0,  ], //7
    [	r,		-Plate_outerArcRadius,						Plate_outerArcAngle,	    					0,	], //8
    [	r,		0,											Plate_outerArcAngle,    						0,	], //9
    [	l,		2 * Key_spacing.x + Frame_notchDepth,		0,												0,	], //10
    [	l,		Key_spacing.x / 2 - Frame_notchDepth,		0,												1,	], //11
    [	r,		-Plate_frontArcRadius + SwitchPlate_edge,	Cluster_innerThumbKeyAngle,						1,	], //12
    [	l,		Key_spacing.x / 2 - Frame_notchDepth,		0,												1,	], //13
    [	l,		SwitchPlate_edge + Frame_notchDepth,		0,												0,	], //14
    [	r,		0,											90,												0,	], //15
    [	l,		SwitchPlate_edge,							0,												0,	], //16
    [	r,		-Plate_centerArcRadius + SwitchPlate_edge,	Cluster_innerThumbKeyAngle + Halves_angles.z,	0,	], //17
    [	l,		Frame_extraLength + Hinge_offset + 1,		0,												0,	], //18
];