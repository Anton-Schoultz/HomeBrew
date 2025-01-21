@echo off
Rem Batch Job to ease reading EEPROM
Rem 
Rem EE Programmer is implemented on an Arduino UNO
Rem EEProgrammer folder
REM 
REM p1=jed file to write
set port=COM12
set baud=115200
Rem
Rem ----------------------------------------------------------------------
Rem this sets folder to this batch file's parent (including trailing \)
set folder=%~dp0%
set jar=%folder%EEProgrammer\out\artifacts\EEProgrammer_jar\EEPRogrammer.jar
title=%jar%
Rem ----------------------------------------------------------------------
Rem
if not .%1==. goto ok
echo Read EEPROM
echo Usage:
echo EE_Read {FileName} [Port]
echo FileName is the name of the output file (without .hex extension)
echo Port is the com port that the uno is attached to, default is %port%
echo
goto exit
:ok
set file=%1.hex
if not .%2==. set port=%2
java -jar %jar% -B:%baud% -C:%port% -R:%file% -S:8
@echo Done!
@echo Switch off power before removing.
:exit
rem
rem ?               Display this help");
rem -B:####         Set the baud rate eg -B:9600 (default is "+BAUD_RATE+" ) 
rem -C:# / COMx     Specify comport for programmer - eg -C:5 or -C:COM5 
rem -W:filename     Write iHex file to eeprom. eg -W:MyData.hex 
rem -R:filename     Read eeprom to iHex file.  eg -R:ChipData.hex 
rem -D:filename     Dump eeprom to text based hex file.  eg -D:ChipData.txt 
rem -L:filename     Load binary file into the eeprom 
rem -S:#            Size of eeprom in K (default is 8) 
rem -E              erase the chip 
