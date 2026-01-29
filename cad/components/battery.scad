/*******************************************************************************\
|							Battery for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas							|
\*******************************************************************************/

// Test
if ( is_undef ( ANDROPHAGE_MAIN ) ) {
    battery = object(color="silver", size=[15,20,3]);
    battery ( battery );
}

module battery ( battery ) {
    color ( battery.color ) {
        cube ( battery.size - [ battery.size.z, 0, 0 ], center = true );

        for ( i = [ -1, 1 ] ) {
            translate ( [ i * ( battery.size.x - battery.size.z ) / 2, 0, 0 ] ) {
                rotate ( [ 90, 0, 0 ] ) {
                    cylinder ( d = battery.size.z, h = battery.size.y, center = true );
                }
            }
        }
    }
}