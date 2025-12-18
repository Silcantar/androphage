// Switch plate for Androphage keyboard.
// Copyright 2025 Joshua Lucas

module switch_hole(width = Switch.width, height = Switch.height) {
	square([width, height], center = true);
}

module place_finger_switches () {
	for (i = [0:Columns.last], j = [0:Columns.counts[i]-1]) {
		translate([(i - 1) * Key.spacing.x, (Columns.offsets[i] + j) * Key.spacing.y]) {
			switch_hole ();
		};
	}
}

module place_thumb_switches () {
	for (i = [0:len(Cluster.counts) -1 ]) {
		translate ([0, - Cluster.radius_mm, 0]) {
			rotate ((i + 1) * Cluster.angle) {
				translate ([0, Cluster.radius_mm, 0]) {
					for (j = [0:Cluster.counts[i] - 1]) {
						translate ([0, j * Key.spacing.y, 0]) {
							switch_hole ();
						}
					}
				}
			}
		}
	}
}

module plate_sketch () {
	x1 = (len(Columns.counts) - 1.5) * Key.spacing.x + SwitchPlate.edge;

	itk_angle = len(Cluster.counts) * Cluster.angle;
	InnerThumbKey = object( [
		["angle", itk_angle],
		["coords", [
			-Cluster.radius_mm * sin(itk_angle),
			Cluster.radius_mm * (cos(itk_angle) - 1)
		] ],
	] );

	key_diagonal = sqrt((Key.spacing.x / 2 + SwitchPlate.edge) ^ 2 + (Key.spacing.y / 2 + SwitchPlate.edge) ^ 2);

	lowerInnerPoint = [
		InnerThumbKey.coords.x - key_diagonal * sin(45 + InnerThumbKey.angle),
		InnerThumbKey.coords.y + key_diagonal * cos(45 + InnerThumbKey.angle)
	];

	point0 = 			[ 0, 																-Key.spacing.y * (0.5 - min(Columns.offsets)) - SwitchPlate.edge																	];
	point1 = point0 + 	[ (len(Columns.counts) - 1.5) * Key.spacing.x + SwitchPlate.edge,	0																										];
	point2 = point1 + 	[ 0, 																(Columns.counts[Columns.pinky] + Columns.offsets[Columns.pinky]) * Key.spacing.y + 2 * SwitchPlate.edge	];
	point3 = 			[ (Columns.middle - 1) * Key.spacing.x,								Columns.counts[Columns.middle] * Key.spacing.x + SwitchPlate.edge + 0.5 * SwitchPlate.edge				];

	points = [
		// 0: Bottom center
		point0,
		// [
		// 	0,
		// 	-Key.spacing.y / 2 - SwitchPlate.edge
		// ],
		// 1: Bottom right
		point1,
		// [
		// 	x1,
		// 	-Key.spacing.y / 2 - SwitchPlate.edge
		// ],
		// 2: Top right
		point2,
		// [
		// 	x1,
		// 	Columns.counts[Columns.pinky] * Key.spacing.y + SwitchPlate.edge
		// ],
		// 3: Top center
		point3,
		// [
		// 	(Columns.middle - 1) * Key.spacing.x,
		// 	Columns.counts[Columns.middle] * Key.spacing.x + SwitchPlate.edge + 0.5 * SwitchPlate.edge
		// ],
		// 4: Top left
		[
			lowerInnerPoint.x + Hinge.length * sin(Hinge.angle),
			lowerInnerPoint.y + Hinge.length * cos(Hinge.angle)
		],
		// 5: Bottom left (above thumb cluster)
		lowerInnerPoint,
		// Bottom left (below thumb cluster)
		[
			lowerInnerPoint.x + (Key.spacing.y + 2 * SwitchPlate.edge) * sin(InnerThumbKey.angle),
			lowerInnerPoint.y - (Key.spacing.y + 2 * SwitchPlate.edge) * cos(InnerThumbKey.angle)
		],
		// Bottom center-left
		[
			InnerThumbKey.coords.x + (Key.spacing.y / 2 + SwitchPlate.edge) * sin(InnerThumbKey.angle),
			InnerThumbKey.coords.y - (Key.spacing.y / 2 + SwitchPlate.edge) * (cos(InnerThumbKey.angle))
		],
	];

	difference () {
		polygon (points);
		translate ([0, -Cluster.radius_mm + Key.spacing.y * min(Columns.offsets), 0]) {
			circle ((Cluster.radius-0.5) * Key.spacing.y - SwitchPlate.edge);
		}
	}
}

module switch_plate (thickness = SwitchPlate.thickness) {
	linear_extrude (height = thickness) {
		difference () {
			plate_sketch();

			place_finger_switches();

			place_thumb_switches();
		};
	}
}