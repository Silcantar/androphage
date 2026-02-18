#!/bin/bash

cat \
 components/battery.scad \
 components/btu.scad \
 components/center_block.scad \
 components/frame.scad \
 components/hinge.scad \
 components/key_placement.scad \
 components/keys.scad \
 components/magnetic_connector.scad \
 components/mcu.scad \
 components/plates.scad \
 components/trackball_sensor.scad \
 components/trackball.scad \
 keycaps/keycap_nolib_compiled.scad \
 library/animation.scad \
 library/choc_switch.scad \
 library/fillet.scad \
 library/gateron_ks33.scad \
 library/globals.scad \
 library/math.scad \
 library/path.scad \
 library/piano_hinge.scad \
 library/rainbow.scad \
 library/screw_globals.scad \
 library/screw.scad \
 library/shapes.scad \
 library/test.scad \
 library/utility.scad \
 androphage.scad \
 assembly.scad \
 color.scad \
 derives.scad \
 globals.scad \
| grep -v '^include' | grep -v '^use' > ./androphage_compiled.scad
echo "androphage_compiled.scad written."