<html><body>
<h1>BASIC Keywords</h1>
<dl compact>
<dt>ABS(##)<dd>Return absolute value of numeric expression ##
<dt>ASC($$)<dd>Return numeric value of the first character of String $$
<dt>CHR$(##)<dd>Return string with a character for the given value
<dt>CLEAR<dd>Clear variables
<dt>CLS<dd>Clear Screen
<dt>DEEK(##)<dd>Return the contents of memory word at address
<dt>DIM  a$(##size) [,b$(##size)]*<dd>Dimension Strings
<dt>DOKE ##Address,##word<dd>Doke word of data to the address
<dt>FOR #V = ##From TO ##Limit [STEP ##Step]<dd>Start of FOR/NEXT Loop
<dt>FRE(##)<dd>Return number of bytes available in free memory
<dt>GOSUB #LineNo<dd>Call subroutine at LineNo
<dt>GOTO #LineNo<dd>Goto LineNo
<dt>IF ?? THEN {Statment}<dd>Execute statement if condition ?? is true
<dt>INPUT ("prompt"|,|NumVar|StrVar)*<dd>Input values with optional prompts
<dt>LEFT$($$,##)<dd>Keep left most chars of string [Head]
<dt>Len($$)<dd>Return the length of the string expression
<dt>LET {var}={expr}<dd>Assign value to a variable
<dt>LIST [##From] [- [##To]]<dd>List program (optional range of lines)
<dt>LOWER($$)<dd>Convert string to Lower case
<dt>LTRIM($$)<dd>Trim leading spaces from string
<dt>MID$($$,##From,##Len)<dd>Return substring of Len chars from position From
<dt>NEW<dd>Clear program and data
<dt>NEXT {Var}<dd>End of FOR/NEXT loop
<dt>PEEK(##Address)<dd>Return the byte at address
<dt>POKE {AddressExpr},{NumExpr}	Poke byte of data to the address
<dt>PRINT (##|$$| |,)*<dd>Print sequence of values
<dt>REM {comment}<dd>Program remarks/comments
<dt>RETURN<dd>Return control to after the GOSUB
<dt>RIGHT$($$,##N)<dd>Keep right most N chars of string [Tail]
<dt>RND(##Max)<dd>Return random number 0..(##Max-)
<dt>RTRIM$($$)<dd>Trim trailing spaces from string
<dt>RUN [#LineNo]<dd>Execute the program, optionally from line number
<dt>SGN(##Value)<dd>Return sign of the value as  -1, 0 or 1
<dt>SQR(##Val)<dd>Return the Square of Val
<dt>STOP<dd>Stop executing the program
<dt>STR$(##Value)<dd>Return string representation of the value
<dt>TRIM$($$)<dd>Trim leading and trailing spaces from the string
<dt>UPPER$($$)<dd>Convert string to upper case
<dt>VAL($$)<dd>Evaluate the string and return it's numeric value
</dl>
<br>$$=String Expression
<br>##=Numeric Expression
<br>#=Numeric literal
<br>$=String literal (Quoted string)
<br>??=Relational/Conditional expression
</body>
</html>
