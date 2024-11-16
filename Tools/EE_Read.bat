@echo off
Rem Batch Job to ease reading EEPROM
Rem 
Rem EE Programmer is implemented on an Arduino UNO
Rem EEProgrammer folder
REM 
REM p1=jed file to write
set port=COM12
set baud=57600
Rem
if not .%1==. goto ok
echo Read EEPROM
echo Usage:
echo EE_Read {FileName} [Port]
echo FileName is the name of the output file (without extension)
echo Port is the com port that the uno is attached to, default is %port%
echo
goto exit

:ok
set file=%1.hex
if not .%2==. set port=%2

java -jar EEProgrammer.jar -B:%baud% -C:%port% -R:%file% -S:8

@echo Done!
@echo Switch off power before removing.

:exit