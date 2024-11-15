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
Rem
if not .%1==. goto ok
echo Read GAL20v8 using afterburner 
echo Usage:
echo ReadGAL {FileName} [Port]
echo FileName is the name of the resulting fuse file (without extension)
echo Port is the com port that the uno is attached to, default is %port%
echo
echo For more details about the programmer used please
echo refer to https://github.com/ole00/afterburner/tree/version_4_legacy
goto exit

:ok
set file=%1.res
if not .%2==. set port=%2

@echo About to read GAL20V8 via %port% into %file% ...
@echo Please nsure that power is on an press enter to continue.
pause 
afterburner_w64_040.exe r -t GAL20V8 -d %port% > %file%

@echo Done!
@echo Switch off power before removing.

:exit