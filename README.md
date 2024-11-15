# HomeBrew
My attempt at rolling-my-own 80's home computer.

Aiming for a 6502 (specifically R65C02) based system,
ideally with video output.

# Tools
Here I have collected the various tools that I needed.
<br>See the README.md in the tools folder for more info.

## GAL Programmer
I've set this up for the GAL20V8 that I use (available and affordable here)
<br>It is a slightly older version of the Afterburner project by Bruce Abbott.
<br>Arduino project: <code>Tools\afterburner042\afterburner042.ino</code>
<br>with the corresponding windows program: <code>Tools\afterburner_w64_040.exe</code>
<br>I added some convenience batch jobs GAL_Write.bat and GAL_Read.bat.

## EE Programmer
Simple DIY EEPROM programer for PQ 52B33 8k x 8 EEPROM (Using Arduino Nano)
<br>See the program comments at the top of 
<code>Tools\EEProgrammer\arduino\EEProgrammer\EEProgrammer.ino</code>

The PC code is written in java, InteliJ project is at 
<code>Tools\EEProgrammer\EEProgrammer.iml</code>
<br>This build the jar file, which is then coppied into the tools folder.
<br>I added some convenience batch jobs EE_Write.bat and EE_Read.bat.