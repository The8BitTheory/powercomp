#!/bin/sh
# Baut powercomp-v2.0.d81 (GUI-Fassung ohne VDC-BASIC) mit dem Framework c128-vdc-gui.
# Aufruf:  GUI=~/git/c128-vdc-gui ./build.sh      (Voraussetzung: cc65, python3 -- siehe Framework)
# Die Quellen (powercomp-v2.0.bas, powercomp.gui) werden in den Framework-Ordner apps/powercomp/ kopiert,
# dort per "make powercomp" uebersetzt; das fertige Image landet hier als powercomp-v2.0.d81.
set -e
GUI=${GUI:-$HOME/git/c128-vdc-gui}
HERE=$(cd "$(dirname "$0")" && pwd)
cp "$HERE/powercomp-v2.0.bas" "$GUI/apps/powercomp/powercomp.bas"
sed 's|THEME   "demo/vbdos.tht"|THEME   "../../demo/vbdos.tht"|' "$HERE/powercomp.gui" > "$GUI/apps/powercomp/powercomp.gui"
(cd "$GUI" && make powercomp)
cp "$GUI/apps/powercomp/powercomp.d81" "$HERE/powercomp-v2.0.d81"
echo "-> $HERE/powercomp-v2.0.d81"
