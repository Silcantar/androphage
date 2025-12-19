/*****************************************************************************\
|									Outline of plates for Androphage keyboard.									|
|													Copyright 2025 Joshua Lucas 												|
\*****************************************************************************/

include <../androphage_globals.scad>

module plate_sketch ( column, cluster, hinge, key ) {
	x1 = (len(column.counts) - 1.5) * key.spacing.x;

	itk_angle = len(cluster.columnCounts) * cluster.angle;
	InnerThumbKey = object( [
		["angle", itk_angle],
		["coords", [
			-cluster.radiusmm * sin(itk_angle),
			cluster.radiusmm * (cos(itk_angle) - 1)
		] ],
	] );

	key_diagonal = sqrt((key.spacing.x / 2) ^ 2 + (key.spacing.y / 2) ^ 2);

	lowerInnerPoint = [
		InnerThumbKey.coords.x - key_diagonal * sin(45 + InnerThumbKey.angle),
		InnerThumbKey.coords.y + key_diagonal * cos(45 + InnerThumbKey.angle)
	];

	point0 = 			[
		0,
		-key.spacing.y * (0.5 - min(column.offsets))
	];
	point1 = point0 + 	[ (len(column.counts) - 1.5) * key.spacing.x ,	0																										];
	point2 = point1 + 	[ 0, 																(column.counts[pinky] + column.offsets[pinky]) * key.spacing.y ];
	point3 = 			[ (middle - 1) * key.spacing.x,								column.counts[middle] * key.spacing.x ];

	points = [
		// 0: Bottom center
		point0,
		// [
		// 	0,
		// 	-Key_spacing.y / 2 - SwitchPlate_edge
		// ],
		// 1: Bottom right
		point1,
		// [
		// 	x1,
		// 	-Key_spacing.y / 2 - SwitchPlate_edge
		// ],
		// 2: Top right
		point2,
		// [
		// 	x1,
		// 	Column_counts[Column_pinky] * Key_spacing.y + SwitchPlate_edge
		// ],
		// 3: Top center
		point3,
		// [
		// 	(Column_middle - 1) * Key_spacing.x,
		// 	Column_counts[Column_middle] * Key_spacing.x + SwitchPlate_edge + 0.5 * SwitchPlate_edge
		// ],
		// 4: Top left
		[
			lowerInnerPoint.x + hinge.length * sin(hinge.angle),
			lowerInnerPoint.y + hinge.length * cos(hinge.angle)
		],
		// 5: Bottom left (above thumb cluster)
		lowerInnerPoint,
		// Bottom left (below thumb cluster)
		[
			lowerInnerPoint.x + (key.spacing.y) * sin(InnerThumbKey.angle),
			lowerInnerPoint.y - (key.spacing.y) * cos(InnerThumbKey.angle)
		],
		// Bottom center-left
		[
			InnerThumbKey.coords.x + (key.spacing.y / 2) * sin(InnerThumbKey.angle),
			InnerThumbKey.coords.y - (key.spacing.y / 2) * (cos(InnerThumbKey.angle))
		],
	];

	difference () {
		polygon (points);
		translate ([0, -cluster.radiusmm + key.spacing.y * min(column.offsets), 0]) {
			circle ((cluster.radius-0.5) * key.spacing.y);
		}
	}
}