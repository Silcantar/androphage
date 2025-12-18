// Length Unit: mm
// Angle Unit: degree

function last (vector) = len(vector) - 1;

/* [Hidden] */
$fa = 1;

/* [Keys] */
// Spacing between keys.
Key_Spacing = "Choc"; //[Choc, MX]
mx_spacing = (Key_Spacing == "MX") ? true : false;

Key = object ( [
	["mx_spacing",	mx_spacing],
	["spacing",		[mx_spacing ? 19 : 18, mx_spacing ? 19 : 17, 0]],
] );

// Test clearance between keycaps and case.
Test_clearance	= false;

/* [Hidden] */
keycap_clearance = 0.5;
Switch = object ( [
	["height",		Test_clearance ? Key.spacing.y - keycap_clearance : 14],
	["width",		Test_clearance ? Key.spacing.x - keycap_clearance: 14],
] );

/* [Plates] */
// Top plate thickness.
Top_plate_thickness = 1.6; //[1.0:0.2:2.0]
TopPlate = object ( [
	["thickness",	Top_plate_thickness],
] );

// Distance from keys to edge of switch plate.
Switch_plate_edge	= 2; //[1:5]
SwitchPlate = object ( [
	["thickness",	Key.mx_spacing ? 1.6 : 1.2],
	["edge",		Switch_plate_edge],
] );

/* [Thumb Cluster] */

// This drives the spacing between the thumb keys.
Thumb_cluster_radius = 6.5; //[0:0.25:10]
// Angle between adjacent thumb keys.
Thumb_cluster_angle	= 10; //[0:1:30]
// Number of keys in the inner two thumb columns.
Thumb_column_counts		= [2, 1];	//[1:2]
// Offset distance of the inner two thumb columns.
Thumb_column_offsets	= [0, 0];	//[0:0.125:1]

Cluster = object ( [
	["angle",		Thumb_cluster_angle],
	["radius",		Thumb_cluster_radius],
	["radius_mm",	Thumb_cluster_radius * Key.spacing.y],
	["counts",		concat([1], Thumb_column_counts)],
	["offsets",		concat([0], Thumb_column_offsets)],
] );

/* [Column Key Counts] */
Inner_count		= 3;	//[1:4]
Index_count		= 4;	//[1:5]
Middle_count	= 4;	//[1:5]
Ring_count		= 4;	//[1:5]
Pinky_count		= 3;	//[1:5]
Outer_count		= 0;	//[0:5]

/* [Column Offsets] */
Inner_offset	= 1;	//[1:0.125:2]
Index_offset	= 0;	//[-1:0.125:2]
Middle_offset	= 0.5;	//[-1:0.125:2]
Ring_offset		= 0;	//[-1:0.125:2]
Pinky_offset	= 0.5;	//[-1:0.125:2]
Outer_offset	= 0.5;	//[-1:0.125:2]

// Finger/column parameters.
Columns = object ( [
	["count",	(Outer_count == 0) ? 5 : 6],
	["last",	(Outer_count == 0) ? 4 : 5],

	// "Enum" of fingers/columns.
	["inner",	0],
	["index",	1],
	["middle",	2],
	["ring",	3],
	["pinky",	4],
	["outer",	5],

	["counts", (Outer_count == 0 ? [
		Inner_count,
		Index_count,
		Middle_count,
		Ring_count,
		Pinky_count,
	] : [
		Inner_count,
		Index_count,
		Middle_count,
		Ring_count,
		Pinky_count,
		Outer_count,
	])],

	["offsets", (Outer_count == 0) ? [
		Inner_offset,
		Index_offset,
		Middle_offset,
		Ring_offset,
		Pinky_offset,
	] : [
		Inner_offset,
		Index_offset,
		Middle_offset,
		Ring_offset,
		Pinky_offset,
		Outer_offset,
	]],
] );

/* [Hinge] */
// Hinge Length
Length	= 70;	//[50:1:100]
// Hinge Angle (double this for the angle between the halves)
Angle	= 15;	//[0:1:45]

Hinge = object ( [
	["length",	Length],
	["angle",		Angle],
] );

/* [Hidden] */
plate_depth		= Key.spacing.y * max(Columns.counts);
plate_width		= Key.spacing.x * Columns.count;

include <components/plates.scad>

switch_plate();