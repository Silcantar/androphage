mx_spacing = false;

key_spacing_x	= mx_spacing ? 19 : 18;
key_spacing_y	= mx_spacing ? 19 : 17;

switch_width	= 14;

top_plate_thickness	= 1.6;
switch_plate_thickness = mx_spacing ? 1.6 : 1.2;

thumbCluster_angle  = 10;
thumbCluster_radius = 6.75;

// Finger column enum.
inner	= 0;
index	= 1;
middle	= 2;
ring	= 3;
pinky	= 4;

column_offsets	= [1, 0, 0.5, 0, 0.5];	// Inner, Index, Middle, Ring, Pinky.
column_counts	= [3, 4, 4, 4, 3];		// Ditto.
thumbColumn_counts = [1, 2, 1];

halves_angle	= 15;

plate_depth		= key_spacing_y * max(column_counts);
plate_width		= key_spacing_x * len(column_counts);

switch_plate_edge	= 5;

hinge_length	= 70;