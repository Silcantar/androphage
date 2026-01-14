/*******************************************************************************\
|						Library for modeling a Piano Hinge.						|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

piano_hinge ( length = sin ( 360 * $t ) * 100 + 100, angle = 135 * sin ( 360 * $t ) - 45 );

module piano_hinge (
	length, 
	angle			= 0,
	center			= true,
	clearance		= 0.1,
	diameter		= 4, 
	knuckleLength	= 10,
	leafThickness	= 1,
	leafWidth		= 10,
	pinDiameter		= 2
) {
	color ( "LightGreen" ) {
		_piano_hinge_pin ( 
			length		= length, 
			clearance	= clearance,
			pinDiameter	= pinDiameter 
		);
	}

	leaf_colors = [ "LightBlue", "Orange" ];
	for ( side = [ 0, 1 ] ) {
		rotate ( ( 2 * side - 1 ) * angle / 2 ) {
			color ( leaf_colors[side] ) {
				_piano_hinge_leaf (
					center			= center,
					clearance		= clearance,
					diameter		= diameter, 
					knuckleLength	= knuckleLength,
					leafThickness	= leafThickness,
					leafWidth		= leafWidth,
					length 			= length, 
					pinDiameter		= pinDiameter,
					side			= side
				);
			}
		}
	}
}

module _piano_hinge_leaf ( 
	center,
	clearance,
	diameter,
	knuckleLength,
	leafThickness,
	leafWidth,
	length,
	pinDiameter,
	side
) {
	// Knuckles
	difference () {
		union () {
			cylinder ( d = diameter, h = length, center = true );

			// Leaf
			translate ( [ ( 2 * side - 1 ) * leafWidth / 2, ( diameter - leafThickness ) / 2, 0 ] ) {
				cube ( [ leafWidth, leafThickness, length ], center = true );
			}
		}

		// Pin hole
		translate ( [ 0, 0, -clearance ] ) {
			cylinder ( d = pinDiameter, h = length + 2 * clearance, center = true );
		}

		knuckle_count = floor ( length / knuckleLength / 2 );
		for ( i = [ 0 : knuckle_count ], j = [ 1, -1 ] ) {
			translate ( [ 0, 0, j * ( 2 * i + side ) * knuckleLength + ( center ? 0 : knuckleLength / 2 ) ] ) {
				cube ( [ diameter, diameter, knuckleLength ] + clearance * [ 2, 2, 2 ], center = true );
			}
		}
	}
}

module _piano_hinge_pin (
	clearance,
	length,
	pinDiameter
) {
	cylinder ( d = pinDiameter - 2 * clearance, h = length, center = true );
}