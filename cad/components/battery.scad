/*******************************************************************************\
|							Battery for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas							|
\*******************************************************************************/

// Test
if ( is_undef ( ANDROPHAGE_MAIN ) ) {
    Battery = object(color="silver", size=[15,20,3]);
    battery();
}

module battery () {
    color ( Battery_color ) {
        cube ( Battery_size - [ Battery_size.z, 0, 0 ], center = true );

        for ( i = [ -1, 1 ] ) {
            translate ( [ i * ( Battery_size.x - Battery_size.z ) / 2, 0, 0 ] ) {
                rotate ( [ 90, 0, 0 ] ) {
                    cylinder ( d = Battery_size.z, h = Battery_size.y, center = true );
                }
            }
        }
    }
}