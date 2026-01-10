/*******************************************************************************\
|						Kailh Choc V1 and V2 switch models.						|
|							Copyright 2026 Felix Kuehling 						|
|																				|
|	This program is free software: you can redistribute it and/or modify		|
|	it under the terms of the GNU General Public License as published by		|
|	the Free Software Foundation, either version 3 of the License, or			|
|	(at your option) any later version.											|
|	This program is distributed in the hope that it will be useful,				|
|	but WITHOUT ANY WARRANTY; without even the implied warranty of				|
|	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the				|
|	GNU General Public License for more details.								|
|	You should have received a copy of the GNU General Public License			|
|	along with this program.  If not, see <https://www.gnu.org/licenses/>.		|
|																				|
\*******************************************************************************/

travel = 3.3 * (0.5 * sin ( 360 * $t) + 0.5);
$color_scheme = 6;
$choc_version = 1;

choc_switch();
//choc_switch_v1 ( bottom_color, top_color, stem_color );

module choc_switch_v1(bottom_color, top_color, stem_color,travel=travel) {
    color(bottom_color) render(convexity = 4) difference() {
        union() {
            linear_extrude(height = 0.701, scale = 1.05) {
                offset(r = 1.0/1.05) square(11.8/1.05, center = true);
            }
            translate([0, 0, 0.7]) linear_extrude(height = 1.51) {
                offset(r = 1.0) square(11.8, center = true);
            }
            translate([0, 0, 2.2]) linear_extrude(height = 0.8) {
                offset(r = 1.6) square(11.8, center = true);
            }
            translate([0, 0, -2]) cylinder(h = 2.01, d = 3.2);
            translate([0, 0, -2.65]) cylinder(h = 0.66, d1 = 2.8, d2 = 3.2);
            translate([-5.5, 0, -2   ]) cylinder(h = 2.01, d = 1.8);
            translate([-5.5, 0, -2.65]) cylinder(h = 0.66, d1 = 1.4, d2 = 1.8);
            translate([ 5.5, 0, -2   ]) cylinder(h = 2.01, d = 1.8);
            translate([ 5.5, 0, -2.65]) cylinder(h = 0.66, d1 = 1.4, d2 = 1.8);
        }
        translate([0, 0, 6.9]) cube(12.65, center = true);
        translate([0, 4.7, 0]) cube([5.3, 3.25, 2], center = true);
        translate([7.4, 0, 2.5]) cube([1, 10.8, 1], center = true);
        translate([-7.4, 0, 2.5]) cube([1, 10.8, 1], center = true);
    }
    color("gold") translate([0, -5.9, -1]) rotate([90, 0, 0])
    linear_extrude(height = 0.2, center = true) {
        offset(r = 0.5) square([0.01, 3], center = true);
    }
    color("silver") translate([-5, -3.8, -1]) rotate([90, 0, 0])
    linear_extrude(height = 0.2, center = true) {
        offset(r = 0.5) square([0.01, 3], center = true);
    }
    color(stem_color) translate([0, 0, 5+1.01-travel]) render(convexity = 4) difference() {
        union() {
            cube([10.2, 4.5, 4], center = true);
            translate([0, -2.74, 0]) cube([3, 1.02, 4], center = true);
        }
        translate([-2.85, 0, 0.51]) cube([1.2, 3, 3], center = true);
        translate([ 2.85, 0, 0.51]) cube([1.2, 3, 3], center = true);
        translate([0, -2.76, -0.5]) cube([2, 1.02, 4], center = true);
    }
    color(top_color, 0.3) render(convexity = 4) difference() {
        union() {
            translate([0, 0, 2.99])
            linear_extrude(height = 0.51) {
                offset(r = 1.0) square([11.6, 11.8], center = true);
            }
            translate([0, 0, 3.499])
            linear_extrude(height = 1.501, scale = 0.9) {
                offset(r = 1.0) square([11.6, 11.8], center = true);
            }
            translate([0, 0, 4.99])
            linear_extrude(height = 0.51, convexity = 2, scale = 0.96) {
                offset(r = 0.4) polygon([
                [-5.7, -2.85], [-5.7,  2.85], [ 5.7,  2.85], [ 5.7, -2.85],
                [ 2.0, -2.85], [ 2.0, -1.85], [-2.0, -1.85], [-2.0, -2.85]
                ]);
            }
        }
        translate([0, 0, 2.98])
        linear_extrude(height = 1.52, scale = 0.9) {
            square(12.65, center = true);
        }
        translate([0, 0, 5]) cube([10.22, 4.52, 2], center = true);
        translate([0, -2.74, 5]) cube([3.02, 1.04, 2], center = true);
    }
}

module choc_switch_v2(bottom_color, top_color, stem_color, travel=travel) {
    color(bottom_color) render(convexity = 4) difference() {
        union() {
            linear_extrude(height = 0.701, scale = 1.05) {
                offset(r = 1.0/1.05) square(11.95/1.05, center = true);
            }
            translate([0, 0, 0.7]) linear_extrude(height = 1.51) {
                offset(r = 1.0) square(11.95, center = true);
            }
            translate([0, 0, 2.2]) linear_extrude(height = 0.8) {
                offset(r = 1.5) square(12.0, center = true);
            }
            translate([0, 0, -2]) cylinder(h = 2.01, d = 4.8);
            translate([0, 0, -2.65]) cylinder(h = 0.66, d1 = 2.8, d2 = 4.8);
        }
        translate([0, 0, 6.9]) cube(12.8, center = true);
        translate([0, 4.7, 0]) cube([5.3, 3.25, 2], center = true);
        translate([7.475, 0, 2.5]) cube([1, 10.8, 1], center = true);
        translate([-7.475, 0, 2.5]) cube([1, 10.8, 1], center = true);
    }
    color("gold") translate([0, -5.9, -1]) rotate([90, 0, 0])
    linear_extrude(height = 0.2, center = true) {
        offset(r = 0.5) square([0.01, 3], center = true);
    }
    color("silver") translate([-5, -3.8, -1]) rotate([90, 0, 0])
    linear_extrude(height = 0.2, center = true) {
        offset(r = 0.5) square([0.01, 3], center = true);
    }
    color("silver") translate([5, 5.15, -1]) rotate([90, 0, 0])
    linear_extrude(height = 0.2, center = true) {
        offset(r = 0.5) square([0.01, 3], center = true);
    }
    color(stem_color) translate([0, 0, 5.3+3.3-2-travel]) render(convexity = 4)
    union() {
        difference() {
            cylinder(h=4, d=6.5, center=true);
            translate([0, 0, 0.4]) cylinder(h=4, d=5.6, center=true);
        }
        cube([4, 1.1, 4], center=true);
        cube([1.3, 4, 4], center=true);
    }
    color(top_color, 0.3) render(convexity = 4) difference() {
        union() {
            translate([0, 0, 2.99])
            linear_extrude(height = 0.81) {
                offset(r = 1.0) square(11.95, center = true);
            }
            translate([0, 0, 3.799])
            linear_extrude(height = 1.501, scale = 0.9) {
                offset(r = 1.0) square(11.95, center = true);
            }
        }
        translate([0, 0, 2.98])
        linear_extrude(height = 1.82, scale = 0.9) {
            square(12.8, center = true);
        }
        translate([0, 0, 5]) cylinder(h=2, d=6.6, center=true);
    }
}

module choc_switch(travel=travel) {
    bottom_color =
        $color_scheme == 1 ? "mediumblue" :
        $color_scheme == 2 ? "dimgrey" :
        $color_scheme == 3 ? "red" :
        $color_scheme == 4 ? "lightgrey" :
        $color_scheme == 5 ? "#9ef" :
        $color_scheme == 6 ? "#333" :
        $color_scheme == 7 ? "#333" :
        $color_scheme == 8 ? "#333" :
        $color_scheme == 9 ? "#333" :
        $color_scheme ==10 ? "darkblue" :
                             "dimgrey";
    top_color =
        $color_scheme == 1 ? "white" :
        $color_scheme == 2 ? "white" :
        $color_scheme == 3 ? "white" :
        $color_scheme == 4 ? "white" :
        $color_scheme == 5 ? "white" :
        $color_scheme == 6 ? "#333" :
        $color_scheme == 7 ? "#383034" :
        $color_scheme == 8 ? "#383034" :
        $color_scheme == 9 ? "#412" :
        $color_scheme ==10 ? "deepskyblue" :
                             "white";
    stem_color =
        $color_scheme == 1 ? "deepskyblue" :
        $color_scheme == 2 ? "sienna" :
        $color_scheme == 3 ? "white" :
        $color_scheme == 4 ? "lightpink" :
        $color_scheme == 5 ? "#9ff" :
        $color_scheme == 6 ? "darkorange" :
        $color_scheme == 7 ? "lightgreen" :
        $color_scheme == 8 ? "#222" :
        $color_scheme == 9 ? "lightsalmon" :
        $color_scheme ==10 ? "red" :
                             "red";

    if ($choc_version == 2)
        choc_switch_v2(bottom_color, top_color, stem_color, travel=travel);
    else
        choc_switch_v1(bottom_color, top_color, stem_color, travel=travel);
}

// Expanded switch-top for cutting away from key-cap bottom
module switch_top(margin = 0.1) {
    size       = $choc_version == 2 ? [11.95, 11.95] : [11.6, 11.8];
    max_travel = $choc_version == 2 ? 3.3 : 3;
    insertion = ($choc_version == 2 ? $droop : $droop - 0.5) + margin;
    $fn = 20;

    translate([0, 0, insertion - 10])
        linear_extrude(height = 8.5) {
            offset(r = 1.0 + margin) square(size, center = true);
        }
    translate([0, 0, insertion - 1.501])
        linear_extrude(height = 1.501, scale = 0.9) {
            offset(r = 1.0 + margin) square(size, center = true);
        }
}