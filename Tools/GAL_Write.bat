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
set port=COM9
Rem ----------------------------------------------------------------------
Rem this sets folder to this batch file's parent (including traing \)
set folder=%~dp0%
rem set exec=%folder%GAL_Programmer\afterburner_w64_040.exe
set exec=D:\GitHub\HomeBrew\Tools\afterburner-master\releases\v_0_6_0\afterburner_w64.exe
title=%exec%
Rem
if not .%1==. goto ok
echo Program GLA20v8 using afterburner 
echo Usage:
echo GAL_Write {FileName} [Port]
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
@echo Please ensure that power is on an press enter to continue.
pause 
rem erase the chip
rem afterburner_w64_040.exe e -v -t GAL20V8 -d %port%

rem %exec%  e w -v -t GAL20V8 -d %port% -f %file%

rem %exec%  r -v -t GAL20V8 -d %port% -f %1.res

rem reads fuse map from file and writes it to the GAL chip. Does the fuse map verification at the end.
%exec%  wv -f %file% -d %port% -t GAL20V8


@echo Done!
@echo Switch off power before removing.

:exit