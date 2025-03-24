 		PR_RD_MEM() 		; divert GetChr to ChrRd
 		ZSET(ZRd,Str1234-1)
 		jsr 	GetChr 		; get first char into CHRGOT
 		jsr 	NumParse
 		HEX_DUMP(NUM_A)		; 1234
		jsr	NumPushA


 		ZSET(ZRd,StrNeg123-1)
 		jsr 	GetChr 		; get first char into CHRGOT
 		jsr 	NumParse
 		HEX_DUMP(NUM_A)		; -123

		jsr	NumPopB

		jsr PrNL
 		HEX_DUMP(NUM_A)		; -123	FF7B00
 		HEX_DUMP(NUM_B)		; 1234  00D204
		jsr PrNL


;		jsr	NumAdd		; 1234 + (-123) = 1111
;		jsr	NumSub		; 1234 - (-123) = 1357

;		jsr	NumMul		; 1234 * (-12) = -14 808
;		jsr	NumDiv		; 1234 / (-12) = -102  r 10
		jsr	NumMod		; 1234 / (-12) = -102  r 10


 		HEX_DUMP(NUM_A)
 		HEX_DUMP(NUM_TMP)

		PR_ZSUP_ON()
 		jsr 	NumPrint

