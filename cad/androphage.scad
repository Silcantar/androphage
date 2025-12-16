// Length Unit: mm
// Angle Unit: degree

key_spacing_x   = 18;
key_spacing_y   = 17;

switch_width    = 14;

plate_thickness = 1.6;

thumbCluster_angle  = 10;
thumbCluster_radius = 6.75;

columns_count   = 5;
rows_count      = 4; // Pinky and inner index columns have one less.

column_offsets  = [0.5, 0, 0.5, 0, 1];
column_counts   = [3, 4, 4, 4, 3]; 

halves_angle    = 15;

plate_depth    = rows_count * key_spacing_y;
plate_width     = columns_count * key_spacing_x;

difference() {
    polygon(
        [
            [0, 0], 
            [0, plate_depth], 
            [plate_width, plate_depth],
            [plate_width + plate_depth * tan(halves_angle), 0]
        ]
    );
    
    for(i = [0:len(column_offsets)-1], j = [0:column_counts[i]-1]) {
        translate([i * key_spacing_x, (column_offsets[i] + j) * key_spacing_y]) {
            square(switch_width);
        };
    }
};