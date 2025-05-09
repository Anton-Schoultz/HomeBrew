<html><body>
<h1>BASIC 	KEYWORDS</H1>
<dl 		COMPACT>
<dt> 		ABS(##)<DD>RETURN absolute value of numeric expression ##
<dt> 		ASC($$)<DD>RETURN numeric value of the first character of String $$
<dt> 		CHR$(##)<DD>RETURN string with a character for the given value
<dt> 		CLEAR<DD>CLEAR variables
<dt> 		CLS<DD>CLEAR Screen
<dt> 		DEEK(##)<DD>RETURN the contents of memory word at address
<dt> 		dim 	a$(##size) [,b$(##size)]*<dd>Dimension Strings
<dt> 		DOKE 	##Address,##word<dd>Poke word of data to the address
<dt> 		for 	#V = ##From TO ##Limit [STEP ##Step]<dd>Start of FOR/NEXT Loop
<dt> 		FRE(##)<DD>RETURN number of bytes available in free memory
<dt> 		STR$(##Value)<DD>RETURN string representation of the value
<dt> 		GOSUB 	#expr<dd>Call subroutine at LineNo
<dt> 		GOTO 	#NumExpr<dd>Goto LineNo
<dt> 		IF 	?? THEN {Statment}<dd>Execute statement if condition ?? is true
<dt> 		DO 	string comparison
<dt> 		INPUT 	("prompt"|,|NumVar|StrVar)*<dd>Input values with optional prompts
<dt> 		LEFT$($$,##)<DD>KEEP left most chars of string [Head]
<dt> 		LEN($$)<DD>RETURN the length of the string expression
<dt> 		let 	{var}={expr}<dd>Assign value to a variable
<dt> 		LIST 	[##From] [- [##To]]<dd>List program (optional range of lines)
<dt> 		LIST 	lines in range LST_BEG to LST_END
<dt> 		LOAD<DD>LOAD program
<dt> 		LOWER($$)<DD>CONVERT string to Lower case
<dt> 		LTRIM($$)<DD>TRIM leading spaces from string
<dt> 		MID$($$,##From,##Len)<DD>RETURN substring of Len chars from position From
<dt> 		NEW<DD>CLEAR program and data
<dt> 		NEXT 	{Var}<dd>End of FOR/NEXT loop
<dt> 		PEEK(##Address)<DD>RETURN the byte at address
<dt> 		POKE 	##Address,##value<dd>Poke byte of data to the address
<dt> 		PRINT 	(##|$$| |,)*<dd>Print sequence of values
<dt> 		rem 	{comment}<dd>Program remarks/comments
<dt> 		RETURN<DD>RETURN control to after the GOSUB
<dt> 		RIGHT$($$,##N)<DD>KEEP right most N chars of string [Tail]
<dt> 		RND(##Max)<DD>RETURN random number 0..(##Max-)
<dt> 		RTRIM$($$)<DD>TRIM trailing spaces from string
<dt> 		run 	[#LineNo]<dd>Execute the program, optionally from line number
<dt> 		SAVE<DD>SAVE program
<dt> 		SGN(##Value)<DD>RETURN sign of the value as  -1, 0 or 1
<dt> 		SQR(##Val)<DD>RETURN the Square of Val
<dt> 		STOP<DD>STOP executing the program
<dt> 		TRIM$($$)<DD>TRIM leading and trailing spaces from the string
<dt> 		UPPER$($$)<DD>CONVERT string to upper case
<dt> 		VAL($$)<DD>EVALUATE the string and return it's numeric value
</dl>
<br>$$=String 	EXPRESSION
<br>##=Numeric 	EXPRESSION
<br>#=Numeric 	LITERAL
<br>$=String 	LITERAL (Quoted string)
<br>??=Relational/Conditional EXPRESSION
</body>
</html>
