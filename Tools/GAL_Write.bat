@echo off
Rem Batch Job to ease writing of GAL20v8 chips
Rem 
Rem GAL20v8 Programmer is implemented on an Arduino UNO
Rem refer to https://github.com/ole00/afterburner/tree/version_4_legacy
Rem
Rem For GAL20v8 use programming voltage of just over 12v
Rem
REM 
REM p1=jed file to write
set port=COM8
Rem ----------------------------------------------------------------------
Rem this sets folder to this batch file's parent (including traing \)
set folder=%~dp0%
set exec=%folder%GAL_Programmer\afterburner_w64_040.exe
title=%exec%
Rem
if not .%1==. goto ok
echo Program GLA20v8 using afterburner 
echo Usage:
echo Burn {FileName} [Port]
echo FileName is the name of the jed file, without the .jed
echo Port is the com port that the uno is attached to, default is %port%
echo
echo For more details about the programmer used please
echo refer to https://github.com/ole00/afterburner/tree/version_4_legacy
goto exit

:ok
set file=%1.JED
if not .%2==. set port=%2

@echo About to burn %file% via %port% ...
@echo Please nsure that power is on an press enter to continue.
pause 
rem erase the chip
rem afterburner_w64_040.exe e -v -t GAL20V8 -d %port%
rem program the gal
%exec%  e w -v -t GAL20V8 -d %port% -f %file%
%exec%  r -v -t GAL20V8 -d %port% -f %1.res
@echo Done!
@echo Switch off power before removing.

:exit