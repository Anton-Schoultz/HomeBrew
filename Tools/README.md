# Tools
A collection of the tools used for this project.

## GAL Programmer
The GAL programmer is bassed on this project by Bruce Abbott
https://github.com/ole00/afterburner/tree/version_4_legacy

## WinCUPL
This is used to program the GAL20v8 chips.

## Logic Analyser
Here I made use of the excellent PulseView Program,
using a Raspberry Pi Pico as the data capture device.

## EE Programmer
Simple DIY EEPROM programer for PQ 52B33 8k x 8 EEPROM (Using Arduino Nano)

## KiCAD
Schematic and PCB editor.

## IC Label Creator
This useful utility (from https://github.com/klemens-u/ic-label-creator) lets you print out IC-Labels.
You can define your own ICs and add them to the chips.js file.
I made some code changes so that it will print narrower to fit on top of the IC nicely,
also some changes to allow you to select your own border colour for the IC label.
I added IC pinouts for R65C02 (Cpu), 52B33 (8k EEPROM) ...