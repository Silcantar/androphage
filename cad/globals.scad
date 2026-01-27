/*******************************************************************************\
|					Global Declarations for Androphage keyboard.				|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

/*******************************************************************************\
|									Config										|
\*******************************************************************************/

// Rendering parameters.
$fa = $preview ? 10 : 1;
$fs = $preview ? 1	: 0.1;

// Test boolean.
$test = false;

/*******************************************************************************\
|									Constants									|
\*******************************************************************************/

// Very small amount.
eps = 0.01;

// Number of millimeters in an inch.
INCH = 25.4;

/*******************************************************************************\
|									Enums										|
\*******************************************************************************/

// Fingers/columns.
inner	= 0;
index	= 1;
middle	= 2;
ring	= 3;
pinky	= 4;
outer	= 5;

// Axes.
axis = [
    [ 1, 0, 0 ], // x
    [ 0, 1, 0 ], // y
    [ 0, 0, 1 ], // z
];

// Switch types.
switch_chocv1	= "chocv1";
switch_chocv2	= "chocv2";
switch_mx		= "mx";
switch_glp		= "glp"; // That's Gateron Low Profile (KS-33).

// Choc V1 color schemes.
switch_red		= 0;
switch_blue		= 1;
switch_brown	= 2;
switch_prored	= 3;
switch_pink		= 4;
switch_robin	= 5;
switch_sunset	= 6;
switch_twilight	= 7;
switch_nocturnal= 8;
switch_sunrise	= 9;
switch_bokeh	= 10;

// Path segments.
// use <library/path.scad>

// l = ET_L(); // Linear extrude
// m = ET_M(); // Mitered corner
// r = ET_R(); // Rotate extrude (revolve)