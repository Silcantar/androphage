#!/usr/bin/env bash

$VikKicadPath = "https://raw.githubusercontent.com/sadekbaroudi/vik/refs/heads/master/kicad"
$KleebPath = "https://raw.githubusercontent.com/crides/kleeb/refs/heads/master"

# Set up Python environment
python -m venv .venv
source .venv/bin/activate
pip install -e .

# Create library folders if they do not already exist.
mkdir "./pcb/bottom_plate/footprints"
mkdir "./pcb/bottom_plate/symbols"
mkdir "./pcb/matrix_plate/footprints"
mkdir "./pcb/matrix_plate/symbols"

# Update VIK symbols and footprints.
echo "Updating VIK symbols and footprints."
wget "$VikKicadPath/vik.kicad_sym" \
    -O "./pcb/bottom_plate/symbols/vik.kicad_sym"
wget "$VikKicadPath/vik.kicad_sym" \
    -O "./pcb/matrix_plate/symbols/vik.kicad_sym"
wget "$VikKicadPath/vik.pretty/vik-keyboard-connector-horizontal.kicad_mod" \
    -O "./pcb/bottom_plate/footprints/vik-keyboard-connector-horizontal.kicad_mod"
wget "$VikKicadPath/vik.pretty/vik-module-connector-horizontal.kicad_mod" \
    -O "./pcb/matrix_plate/footprints/vik-module-connector-horizontal.kicad_mod"

# Update Kleeb symbols and footprints.
echo "Updating Kleeb symbols and footprints."
wget "$KleebPath/mcu.kicad_sym" \
    -O "./pcb/bottom_plate/symbols/mcu.kicad_sym"
wget "$KleebPath/mcu.pretty/holyiot-18010-no-underside.kicad_mod" \
    -O "./pcb/bottom_plate/footprints/holyiot-18010-no-underside.kicad_mod"

# Update key-switches symbols and footprints.
echo "Updating key-switches footprints."
wget "https://raw.githubusercontent.com/Silcantar/key-switches/refs/heads/lopro-hybrids/SW_GLP_Kailh_Choc_V1V2_HotSwap_PTH.kicad_mod" \
    -O "./pcb/matrix_plate/footprints/SW_GLP_Kailh_Choc_V1V2_HotSwap_PTH.kicad_mod"