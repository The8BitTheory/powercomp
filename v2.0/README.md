# powercomp v2.0 – GUI-Fassung ohne VDC-BASIC

Portierung von `powercomp-v1.3.bas` auf das Framework [c128-vdc-gui](https://github.com/The8BitTheory/c128-vdc-gui) (Textmodus, BASIC-Anbindung `GUIT`/`GUILIB`). VDC-BASIC (`VDCBASIC2D.0AC6`) wird nicht mehr gebraucht.

## Dateien

| Datei | Inhalt |
|---|---|
| `powercomp-v2.0.bas` | Programm: Logik aus v1.3 unverändert, Oberfläche über `G…`-Befehle |
| `powercomp.gui` | Oberflächenbeschreibung (Hauptformular mit Menü, Tabelle, Dialoge Laden / Speichern unter / Fortschritt) |
| `build.sh` | baut `powercomp-v2.0.d81` mit dem Framework (`GUI=~/git/c128-vdc-gui ./build.sh`) |

## Was aus v1.3 wohin gewandert ist

| Bereich in v1.3 | Zeilen | jetzt |
|---|---|---|
| Start: `BLOAD VDCBASIC…`, `RST3`, `VMF`, `WINDOW`, Zeichensatz-Patching (`RGW`, `VMW`), Startbox | 13–14, 29800ff, 29900ff, 63900ff | `bload "guilib",b1 / "guit",b0 : sys 7168`, `gvload "gui.chr"`, `gload`, `gshow` |
| Bildschirmaufbau (Rahmen, Beschriftungen), Offscreen-Kopie des Schirms (`VMC`, `VTR`, `RTV`, Datei `SCREEN`) | 900–979, 1600–1710 | entfällt; steht in `powercomp.gui`, das Framework sichert Dialoge selbst (Save-Under) |
| Eingabefelder: Tippen, DEL, Cursor, Laufbalken, `CHAR`, `RGW`-Cursor, Dirty-Flag | 284–303, 520–590, 703–790 | `TextField`-Controls; BASIC wertet nur das Change-Event aus |
| Tabelle (`PRINT USING`, 18 Zeilen) | 800–890 | 18 × (Label, TextField, TextField, Label); `gsettext`/`gcaption` in Massenform |
| Menüs (`MN$`, `MS%`, `VMF`-Highlights, Tastenbehandlung 55000ff, 61000ff, 63000ff) | 55000–55350, 61000–63139 | `MenuBar` im `.gui`; Events über `ON H GOSUB` |
| Dateidialog (Verzeichnis, Scrollen, R/D-Tasten) | 1100, 9700–10360, 56000ff | Dialog mit `ListBox` (`gadd`), Buttons Load/Delete/Rename |
| Fortschrittsfenster | 1120–1146, 60000ff | Dialog mit `ProgressBar` (`gshow 3`, `gset 1,16,wert`) |
| Scoreboard auf dem 40-Zeichen-Schirm | 1900–1999 | unverändert (`graphic 0`, `print using`), danach zurück in die GUI |

Unverändert übernommen sind die Datenhaltung, Sortierung, Dateiformat, CSV-, Printfox- und Automation-Export (nur ohne `CHAR`/`WINDOW`-Ausgaben, Meldungen laufen über `gcaption`).

## Bauen und starten

Voraussetzungen: ein Checkout von c128-vdc-gui, cc65 (`ca65`, `ld65`) und Python 3.

```
GUI=~/git/c128-vdc-gui ./build.sh
```

Das Image `powercomp-v2.0.d81` enthält `BOOT`, `GUILIB`, `GUIT`, `GUI.CHR`, `POWERCOMP`, `POWERCOMP.GUT`. Auf einem C128 im 80-Zeichen-Modus: `RUN"BOOT"`, danach `RUN"POWERCOMP"`.

Wettbewerbsdateien (z. B. `olympia2024`) liegen auf einer eigenen Diskette (`competitions.d81`); mit Laden (C=+L oder File → Load) wird das Verzeichnis des aktuellen Laufwerks gelistet.

## Bedienung

Wie v1.3 (Hinweis: Laden, Sortieren, Speichern und Export wurden im Emulator noch nicht vollständig durchgetestet): Cursor hoch/runter in Tabelle und Disziplinen, F2 Wettbewerbsname, F4 Disziplinen, F8 Eintrag löschen, C=+1…6 Disziplin springen, C=+S/A/L/N/X Speichern/Speichern unter/Laden/Neu/Beenden, C=+E CSV, C=+G Printfox, C=+P Scoreboard, C=+M Automation, CTRL+F/O/G Menüs, zusätzlich Maus (1351). ALT allein öffnet die Menüleiste; ALT+Buchstabe-Hotkeys gehen im BASIC-Betrieb nicht.
