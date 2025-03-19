;---------------------------------------------------------------- CalcDivI
CalcDivI:; TOS = NXT / TOS	(16 bit signed integer)
			jsr CalcNext		; pop into NXT

; NXT / TOS => NXT, remainder in RES
			lda #0      ;Initialize RES to 0
			sta RES
			sta RES+1
			ldx #16     ;There are 16 bits in NXT
CalcDivL1   asl NXT    ;Shift hi bit of NXT into RES
			rol NXT+1  ;(vacating the lo bit, which will be used for the quotient)
			rol RES
			rol RES+1
			lda RES
			sec         ;Trial subtraction
			sbc TOS
			tay
			lda RES+1
			sbc TOS+1
			bcc CalcDivL2      ;Did subtraction succeed?
			sta RES+1   ;If yes, save it
			sty RES
			inc NXT    ;and record a 1 in the quotient
CalcDivL2   dex
			bne CalcDivL1
			;
			lda NXT
			ldx NXT+1
        	jmp CalcSetI		; AX -> TOS
;---------------------------------------------------------------- CalcModI
CalcModI:; TOS = NXT % TOS
			jsr	CalcDivI		; divide with remainder in res
			; fall through to get remained into TOS
;---------------------------------------------------------------- CalcRemI
CalcRemI:; Remainder of division into TOS (Call CalcDivI before this)
			lda RES
			ldx RES+1
			jmp	CalcSetI
