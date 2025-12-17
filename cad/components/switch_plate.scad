// Switch plate for Androphage keyboard.
// Copyright 2025 Joshua Lucas

module switch_hole(width = switch_width) {
	square(width, center = true);
}

module place_finger_switches () {
	for (i = [0:len(column_offsets)-1], j = [0:column_counts[i]-1]) {
		translate([(i - 1) * key_spacing_x, (column_offsets[i] + j) * key_spacing_y]) {
			switch_hole ();
		};
	}
}

module place_thumb_switches () {
	for (i = [0:len(thumbColumn_counts) -1 ]) {
		translate ([0, -thumbCluster_radius * key_spacing_y, 0]) {
			rotate ((i + 1) * thumbCluster_angle) {
				translate ([0, thumbCluster_radius * key_spacing_y, 0]) {
					for (j = [0:thumbColumn_counts[i] - 1]) {
						translate ([0, j * key_spacing_y, 0]) {
							switch_hole ();
						}
					}
				}
			}
		}
	}
}

module plate_sketch () {
	x1 = (len(column_counts) - 1.5) * key_spacing_x + switch_plate_edge;

	innerThumbKey_angle = len(thumbColumn_counts) * thumbCluster_angle;

	innerThumbKey = [
		-(thumbCluster_radius * key_spacing_y) * sin(innerThumbKey_angle),
		(thumbCluster_radius * key_spacing_y) * (cos(innerThumbKey_angle) - 1)
	];

	key_diagonal = sqrt((key_spacing_x / 2 + switch_plate_edge) ^ 2 + (key_spacing_y / 2 + switch_plate_edge) ^ 2);

	lowerInnerPoint = [
		innerThumbKey.x - key_diagonal * sin(45 + innerThumbKey_angle),
		innerThumbKey.y + key_diagonal * cos(45 + innerThumbKey_angle)
	];

	points = [
		[
			0,
			-key_spacing_y / 2 - switch_plate_edge
		],
		[
			x1,
			-key_spacing_y / 2 - switch_plate_edge
		],
		[
			x1,
			column_counts[pinky] * key_spacing_y + switch_plate_edge
		],
		[
			(middle - 1) * key_spacing_x,
			column_counts[middle] * key_spacing_y + switch_plate_edge + 0.5 * switch_plate_edge
		],
		[
			lowerInnerPoint.x + hinge_length * sin(halves_angle),
			lowerInnerPoint.y + hinge_length * cos(halves_angle)
		],
		lowerInnerPoint,
		[
			lowerInnerPoint.x + (key_spacing_y + 2 * switch_plate_edge) * sin(innerThumbKey_angle),
			lowerInnerPoint.y - (key_spacing_y + 2 * switch_plate_edge) * cos(innerThumbKey_angle)
		],
		[
			innerThumbKey.x + (key_spacing_y / 2 + switch_plate_edge) * sin(innerThumbKey_angle),
			innerThumbKey.y - (key_spacing_y / 2 + switch_plate_edge) * (cos(innerThumbKey_angle))
		],
	];

	difference () {
		polygon (points);
		translate ([0, -thumbCluster_radius * key_spacing_y, 0]) {
			circle ((thumbCluster_radius-0.5) * key_spacing_y - switch_plate_edge);
		}
	}
}

module switch_plate (thickness = switch_plate_thickness) {
	linear_extrude (height = thickness) {
		difference () {
			plate_sketch();

			place_finger_switches();

			place_thumb_switches();
		};
	}
}