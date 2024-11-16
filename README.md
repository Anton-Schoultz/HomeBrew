# HomeBrew
My attempt at rolling-my-own 80's home computer.

Aiming for a 6502 (specifically R65C02) based system,
ideally with video output.

# Tools
Here I have collected the various tools that I needed.
<br>See the README.md in the tools folder for more info.

## EE Programmer
Used to program the EEPROM that I use, the PQ 52B33, which is an 8K rom. 
Programmed via an arduino circuit, using java code on the pc side.

## GAL Programmer
Used to program the GAL20V8s that I use (available and affordable here).
<br>Bassed on the Afterburner project by Bruce Abbott.
<br>I added some convenience batch jobs GAL_Write.bat and GAL_Read.bat.

## Logic Analyser
Here I made use of the excellent PulseView Program,
using a Raspberry Pi Pico as the data capture device.

## WinCUPL
This outdated program from ATMEL is used to compile the fuse info for
programming the GAL20V8 chips.
