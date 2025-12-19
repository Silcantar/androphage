/*****************************************************************************\
|												Assembly of Androphage keyboard.											|
|													Copyright 2025 Joshua Lucas 												|
\*****************************************************************************/

use <components/bottom_plate.scad>

use <components/case_frame.scad>

use <components/center_block.scad>

use <components/magnetic_connector.scad>

use <components/switch_plate.scad>

use <components/top_plate.scad>

use <components/trackball_sensor.scad>

switch_plate ( Cluster, Column, Hinge, Key, Switch, SwitchPlate );

translate ([0, 0, -10]) {
	rotate ([0, -5, 0]) {
		color ("green", 1.0) {
			bottom_plate ( BottomPlate, Column, Cluster, Hinge, Key );
		}
	}
}