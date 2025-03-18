echo off
echo p0=%0, p1=%1, p2=%2, p3=%3, p4=%4, p5=%5
rem p0=Full Path of bat file
rem .. passed from tool configuration
rem p1=path	(%P)
rem p2=name	(%N)
rem p3=ext	(%E)
rem p4=full path(%F)
rem
set FullFile=%4
rem 	java.exe -jar D:\GitHub\HomeBrew\Tools\Assembler\AsmHelper.jar %F
rem
D:
cd %1
java.exe -jar D:\GitHub\HomeBrew\Tools\Assembler\AsmHelper.jar %FullFile%
copy *.ref _Index.tmp > null
sort < _Index.tmp > _Index.txt
del _Index.tmp
rem
copy *.wrd _words.tmp > null
sort < _words.tmp > _Wordlist.txt
del _words.tmp
