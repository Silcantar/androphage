/*******************************************************************************\
|						Switch plate for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

include <../androphage_globals.scad>

use <plates_common.scad>

use <center_block.scad>

switch_plate ( zpos = SwitchPlate_position.z );

module switch_plate (
    clearance	= CenterBlock_wallThickness,
    edge		= SwitchPlate_edge,
    PCB			= false,
    thickness	= SwitchPlate_thickness,
    zpos		= 10
) {
    linear_extrude ( height = thickness ) {
        _switch_plate_sketch (
            clearance	= clearance,
            edge		= edge,
            PCB			= PCB,
            zpos		= zpos
        );
    }
}

module _switch_plate_sketch (
    clearance,
    edge,
    PCB,
    zpos
) {
    offset ( r = SwitchPlate_radius )
    offset ( r = -SwitchPlate_radius ) {
        difference () {
            plate_sketch (
                clearance	= clearance,
                edge		= edge,
                zpos		= zpos
            );

            // Subtract key cutouts.
            if ( !PCB ) {
                place_switches();
            }

            place_screws ( thickness = 0 ) {
                _screw_boss_cutout ();
            }

            translate ( trackball_point ( zpos ) ) {
                rotate ( [ 0, 0, -Halves_angles.z] )
                    offset (r = SwitchPlate_radius)
                    offset (r = -SwitchPlate_radius)
                    square ( [ 45, Trackball_diameter ], center = true );
            }
        }
    }
}

module _screw_boss_cutout () {
    _screw_boss_diameter = Insert_holeDiameter + 2 * Insert_wallThickness;
    circle ( d = _screw_boss_diameter );
    translate ( [ -_screw_boss_diameter / 2, 0, 0 ] ) {
        square ( _screw_boss_diameter, center = true );
    }
}