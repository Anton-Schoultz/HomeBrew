echo off
echo p1=%1, p2=%2, p3=%3, p4=%4, p5=%5
rem p0=Full Path of bat file
rem .. passed from tool configuration
rem p1=path	(%P)
rem p2=name	(%N)
rem p3=ext	(%E)
rem p4=full path(%F)
rem p5=target type
rem
set tgt=z80
if .%5==. goto notgt
set tgt=%5
:notgt
rem echo tgt=%tgt%
D:
cd %1
rem uz80as [OPTION]...  ASM_FILE [OBJ_FILE [LST_FILE [EXP_FILE]]]
set optn= --target=%tgt% %4 %1_Binary.bin %1_Listing.lst %1_Export.asm
echo D:\GitHub\HomeBrew\Tools\Assembler\uz80as.exe %optn%
D:\GitHub\HomeBrew\Tools\Assembler\uz80as.exe %optn%
set srecdir="C:\Program Files\srecord\bin\"
%srecdir%srec_cat %1_Binary.bin -Binary -offset 0x1000 -output %1_IntHex.hex -Intel -line-length=64 -Data_Only -Address-Length=2
%srecdir%srec_cat %1_Binary.bin -Binary -o %1_HexDump.txt -HEX_Dump

rem /Function String = "%^([0-9a-z_]+^)[ ^t]+"
rem	
rem -------------------------------------------------------------------------------------------- uz80as assembler help info
rem     https://github.com/jorgicor/uz80as     https://jorgicor.niobe.org/uz80as
rem
rem     Usage: uz80as.exe [OPTION]... ASM_FILE [OBJ_FILE [LST_FILE]]
rem     
rem     Assemble ASM_FILE into OBJ_FILE and generate the listing LST_FILE.
rem     If not specified, OBJ_FILE is ASM_FILE with the extension changed to .obj.
rem     If not specified, LST_FILE is ASM_FILE with the extension changed to .lst.
rem     
rem     Options:
rem       -h, --help           Display this help and exit.
rem       -v, --version        Output version information and exit.
rem       -l, --license        Display the license text and exit.
rem       -d, --define=MACRO   Define a macro.
rem       -f, --fill=n         Fill memory with value n.
rem       -q, --quiet          Do not generate the listing file.
rem       -x, --extended       Enable extended instruction syntax.
rem       -u, --undocumented   Enable undocumented instructions.
rem       -t, --target=NAME    Select the target micro. z80 is the default.
rem       -e, --list-targets   List the targets supported.
rem   
rem
rem     Targets: z80 hd64180 gbcpu dp2200 dp2200ii i4004 i4040 i8008 i8021 i8022 i8041 i8048 i8051 i8080 i8085 
rem     mos6502 r6501 g65sc02 r65c02 r65c29 w65c02s mc6800 mc6801 m68hc11
rem  
rem     Examples:
rem       uz80as p.asm                     Assemble p.asm into p.obj
rem       uz80as p.asm p.bin               Assemble p.asm into p.bin
rem       uz80as -d"MUL(a,b) (a*b)" p.asm  Define the macro MUL and assemble p.asm
rem     
rem     Report bugs to: <jorge.giner@hotmail.com>.
rem     Home page: <https://jorgicor.niobe.org/uz80as>.
rem     Currently, uz80as can assemble for these microprocessors:
rem     
rem     Z80 family
rem         Zilog Z80
rem         Hitachi HD64180
rem         Sharp LR35902 (Nintendo Gameboy CPU)
rem     6500 family
rem         MOS Technology 6502
rem         California Micro Devices G65SC02
rem         Rockwell R6501, R65C02, R65C29
rem         Western Design Center W65C02S
rem     Datapoint 2200 (versions I & II)
rem     Intel 4004, 4040, 8008, 8021, 8022, 8041, 8048, 8051, 8080, 8085
rem     Motorola 6800, 6801, 68HC11
rem     RCA 1802
rem
rem     TARGETS:
rem         z80           Zilog Z80
rem         hd64180       Hitachi HD64180
rem         gbcpu         Sharp LR35902 (Nintendo Gameboy CPU)
rem         dp2200        Datapoint 2200 Version I
rem         dp2200ii      Datapoint 2200 Version II
rem         i4004         Intel 4004
rem         i4040         Intel 4040
rem         i8008         Intel 8008
rem         i8021         Intel 8021
rem         i8022         Intel 8022
rem         i8041         Intel 8041
rem         i8048         Intel 8048
rem         i8051         Intel 8051
rem         i8080         Intel 8080
rem         i8085         Intel 8085
rem         mos6502       MOS Technology 6502
rem         r6501         Rockwell R6501
rem         g65sc02       California Micro Devices G65SC02
rem         r65c02        Rockwell R65C02
rem         r65c29        Rockwell R65C29, R65C00/21
rem         w65c02s       Western Design Center W65C02S
rem         mc6800        Motorola 6800
rem         mc6801        Motorola 6801
rem         m68hc11       Motorola 68HC11

REM Tool Config
REM	D:\GitHub\BasicInAsm\assembler\_Assemble.bat %P %N %E %F
REM
REM --------------------------------------------------------------------------------------- ULTA EDIT INFO
REM	%F	Active file's full path and name (short version)
REM		Example: D:\work\DEVPRO~1\CYCLEO~1\SOMEFI~1.C
REM	%f	Active file's full path and name (long version). Make sure to encapsulate in quotes if the file path or name might contain spaces.
REM		Example: D:\work\Dev Projects\Cycle One\some file.c
REM	%P	Active file's full path (short version)
REM		Example: D:\work\DEVPRO~1\CYCLEO~1\
REM	%p	Active file's full path (long version). Make sure to encapsulate in quotes if the file path might contain spaces.
REM		Example: D:\work\Dev Projects\Cycle One\
REM	%N	Active file's name only (short version)
REM		Example: SOMEFI~1
REM	%n	Active file's name only (long version). Make sure to encapsulate in quotes if the name might contain spaces.
REM		Example: some file
REM	%E	Active file's extension only (short version)
REM		Example: .C
REM	%e	Active file's extension only (long version). Make sure to encapsulate in quotes if the extension might contain spaces.
REM		Example: .c
REM	%R	Active project's full path and name (short version), similar to %F above.
REM	%r	Active project's full path and name (long version), similar to %f above. Make sure to encapsulate in quotes if the path or name might contain spaces.
REM	%RP	Active project's full path (short version), similar to %P above.
REM	%rp	Active project's full path (long version), similar to %p above. Make sure to encapsulate in quotes if the project path might contain spaces.
REM	%RN	Active project's name (short version), similar to %N above.
REM	%rn	Active project's full path (long version), similar to %n above. Make sure to encapsulate in quotes if the project path might contain spaces.
REM	%modify%	Using this placeholder will allow you to specify any arbitrary command line argument(s) (in its place) in a dialog prompt when the command is run.
REM	%sel%	Selected text. Make sure to encapsulate in quotes if the selection might contain spaces.
REM	%Env:	An existing environment variable. The environment variable must immediately follow "%Env:". Note that this placeholder does not require the closing percent sign "%".
REM	Example: %Env:TEMP would be replaced with C:\Users\[USERNAME]\AppData\Local\Temp
REM	%line%	Current line number in active file (based on first line number of 1)
REM	%col%	Current column number in active file (based on first column number of 1)
rem
rem UltraEdit Tool Config
rem
rem CommandLine:	D:\GitHub\BasicInAsm\assembler\_Assemble.bat %P %N %E %F
rem WorkingFolder: 	D:\GitHub\BasicInAsm\assembler
rem MenuItemName:	uz80as

echo DONE