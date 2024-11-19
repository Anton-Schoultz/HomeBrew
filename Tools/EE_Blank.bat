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
Rem ----------------------------------------------------------------------
Rem this sets folder to this batch file's parent (including traing \)
set folder=%~dp0%
set jar=%folder%EEProgrammer\out\artifacts\EEProgrammer_jar\EEPRogrammer.jar
title=%jar%
Rem ----------------------------------------------------------------------
Rem
echo Read EEPROM
echo Usage:
echo EE_Blank [Port]
echo Port is the com port that the uno is attached to, default is %port%
echo
if not .%1==. set port=%1
java -jar %jar% -B:%baud% -C:%port% -V
@echo Done!
@echo Switch off power before removing.

:exit