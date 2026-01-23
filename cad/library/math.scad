// Vector Math.
function product ( v, i = 0, r = 1 ) = ( i < len ( v ) ) ? product ( v, i + 1, r * v[i] ) : r;

function sum ( v, i = 0, r = 0 ) = ( i < len ( v ) ) ? sum ( v, i + 1, r + v[i] ) : r;

// Element-wise vector multiplication.
function v_mul ( v1, v2 ) = [
	for ( i = [ 0 : min ( last(v1), last(v2) ) ] ) (
		v1[i] * v2[i]
	)
];

// Rotation Matrices.
// 2d rotation matrix.
function rot2d ( angle ) = [
	[ cos(angle),	-sin(angle)	],
	[ sin(angle),	cos(angle)	],
];

// 3d rotation matrix.
function rot3d ( angles ) = let (
	a = angles.z,
	b = angles.y,
	c = angles.x
) [
	[
		cos(a) * cos(b),
		cos(a) * sin(b) * sin(c) - sin(a) * cos(c),
		cos(a) * sin(b) * cos(c) - sin(a) * sin(c),
	],
	[
		sin(a) * cos(b),
		sin(a) * sin(b) * sin(c) + cos(a) * cos(c),
		sin(a) * sin(b) * cos(c) - cos(a) * sin(c),
	],
	[
		-sin(b),
		cos(b) * sin(c),
		cos(b) * cos(c),
	],
];

// Convert a 3x3 rotation matrix to a 4x4 affine matrix.
function to_affine ( m ) = concat ( [ for ( row = m ) concat ( row, [ 0 ] ) ], [[ 0, 0, 0, 1 ]] );

// 3d translation matrix.
function trans ( v ) = [
	[	1,	0,	0,	v.x	],
	[	0,	1,	0,	v.y	],
	[	0,	0,	1,	v.z	],
	[	0,	0,	0,	1	]
];

// Identity matrix of dimension <dim>.
function id ( dim ) = [ for ( i = [ 1 : dim ] ) [ for ( j = [ 1 : dim ] ) ( i == j ) ? 1 : 0 ] ];