$VikKicadPath = "https://github.com/sadekbaroudi/vik/blob/master/kicad"
$KleebPath = "https://github.com/crides/kleeb/blob/master"

git submodule init
git submodule update
python -m venv .venv
.venv/Scripts/activate.ps1
pip install -e .

wget "$VikKicadPath/vik.kicad_sym" -OutFile ".\pcb\bottom_plate\symbols\vik.kicad_sym"
wget "$VikKicadPath/vik.kicad_sym" -OutFile ".\pcb\matrix_plate\symbols\vik.kicad_sym"
wget "$VikKicadPath/vik.pretty/vik-keyboard-connector-horizontal.kicad_mod"         -OutFile ".\pcb\bottom_plate\footprints\vik-keyboard-connector-horizontal.kicad_mod"
wget "$VikKicadPath/vik.pretty/vik-module-connector-horizontal.kicad_mod"           -OutFile ".\pcb\matrix_plate\footprints\vik-module-connector-horizontal.kicad_mod"

wget "$KleebPath/mcu.kicad_sym"                                     -OutFile ".\pcb\bottom_plate\symbols\mcu.kicad_sym"
wget "$KleebPath/mcu.pretty/holyiot-18010-no-underside.kicad_mod"   -OutFile ".\pcb\bottom_plate\footprints\holyiot-18010-no-underside.kicad_mod"

wget "https://github.com/Silcantar/key-switches/blob/lopro-hybrids/SW_GLP_Kailh_Choc_V1V2_HotSwap_PTH.kicad_mod" -OutFile ".\pcb\matrix_plate\footprints\SW_GLP_Kailh_Choc_V1V2_HotSwap_PTH.kicad_mod"