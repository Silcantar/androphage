/*******************************************************************************\
|								Androphage Colors								|
\*******************************************************************************/

/* [Colors] */
// Primary color for the keyboard components (Black).
Color_primary = [ 0.20, 0.20, 0.20 ]; //[0.0:0.01:1.0]

// Secondary color for the keyboard components (Purple).
Color_secondary = "MediumSlateBlue";//[ 0.50, 0.30, 0.80, 1.0 ];  //[0.0:0.01:1.0]

// Tertiary color for keyboard components (Copper).
Color_tertiary = [ 0.62, 0.36, 0.18 ];

Color_black = [ 0.20, 0.20, 0.20 ];

Color_brass = "Gold";

// Color for transparent plastic (Transparent white).
Color_clear = [ 1.0, 1.0, 1.0, 0.2 ];

// Color for displaying cutting bodies (Transparent yellow).
Color_cut = [ 1.0, 1.0, 0.0, 0.2 ];

Color_pcb = "DarkGreen";

Color_steel = [ 0.5, 0.5, 0.5 ];

Color = object ( [
    [ "0",			[ 0, 0, 0 ]		], // This is mostly here so we can access the following three by number.
    [ "primary",	Color_primary	], // Can be accessed as Color[1].
    [ "secondary",	Color_secondary	], // Can be accessed as Color[2].
    [ "tertiary",	Color_tertiary	], // Can be accessed as Color[3].
    [ "black",		Color_black		],
    [ "brass",		Color_brass		],
    [ "clear",		Color_clear		],
    [ "cut",		Color_cut		],
    [ "steel",		Color_steel		],
] );