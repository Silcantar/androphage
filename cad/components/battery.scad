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
    color ( Battery.color ) {
        cube ( Battery.size - [ Battery.size.z, 0, 0 ], center = true );

        for ( i = [ -1, 1 ] ) {
            translate ( [ i * ( Battery.size.x - Battery.size.z ) / 2, 0, 0 ] ) {
                rotate ( [ 90, 0, 0 ] ) {
                    cylinder ( d = Battery.size.z, h = Battery.size.y, center = true );
                }
            }
        }
    }
}