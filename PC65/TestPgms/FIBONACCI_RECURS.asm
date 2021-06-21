;    1: PROGRAM Fibonacci (output);
	.stk 1024
	.cod 512
STATIC_LINK .equ +5
RETURN_VALUE .equ -3
HIGH_RETURN_VALUE .equ -1
_start
	tsx.w		; Preserve original stack pointer
	lds.w #_stk_top	; Initialize program stack pointer
	stz _bss_start
	ldx.w #_bss_start
	ldy.w #_bss_start+1
	lda.w #_stk_top
	sec
	sbc.w #_bss_start
	mov #10
	jmp _pc65_main
;    2: 
;    3: CONST
;    4:     max = 23;
;    5: 
;    6: VAR
;    7:     i, j : INTEGER;
;    8:     fn   : ARRAY[0..max] OF INTEGER;
;    9:     
;   10: FUNCTION FIB(n : INTEGER) : INTEGER;
;   11:     BEGIN
n_006 .equ +7
fib_005 .sub
	phx.w
	tsx.w
	adj #-4
;   12:         IF fn[n] = 0 THEN
	psh.w #fn_004
	lda.w n_006,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli.s
	lda.w 0,I++
	pha.w
	lda #0
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_009
	lda #0
L_009
	cmp.w #1
	beq L_007
	jmp L_008
L_007
;   13:             fn[n] := FIB(n-1) + fn[n-2];
	psh.w #fn_004
	lda.w n_006,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w n_006,X
	pha.w
	lda #1
	xma.w 1,S
	sec
	sbc.w 1,S
	adj #2
	pha.w
	lda.w STATIC_LINK,X
	pha.w
	jsr fib_005
	adj #4
	pha.w
	psh.w #fn_004
	lda.w n_006,X
	pha.w
	lda #2
	xma.w 1,S
	sec
	sbc.w 1,S
	adj #2
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli.s
	lda.w 0,I++
	clc
	adc.w 1,S
	adj #2
	pli.s
	sta.w 0,I++
L_008
;   14:         FIB := fn[n];
	psh.w #fn_004
	lda.w n_006,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli.s
	lda.w 0,I++
	sta.w RETURN_VALUE,X
;   15:     END;
	lda.w RETURN_VALUE,X
	txs.w
	plx.w
	rts
	.end fib_005
;   16:     
;   17: BEGIN
_pc65_main .sub
	phx.w
	tsx.w
;   18:     fn[0] := 1;
	psh.w #fn_004
	lda #0
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #1
	pli.s
	sta.w 0,I++
;   19:     fn[1] := 1;
	psh.w #fn_004
	lda #1
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #1
	pli.s
	sta.w 0,I++
;   20:     FOR i := 2 to max DO fn[i] := 0;
	lda #2
	sta.w i_002
L_010
	lda #23
	cmp.w i_002
	bge L_011
	jmp L_012
L_011
	psh.w #fn_004
	lda.w i_002
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #0
	pli.s
	sta.w 0,I++
	inc.w i_002
	jmp L_010
L_012
	dec.w i_002
;   21: 
;   22: {     FOR i := 0 to max DO BEGIN
;   23:         j := FIB(i);
;   24:         write('Fib[');
;   25:         write(i:2);
;   26:         write('] = ');
;   27:         write(j:5);
;   28:         writeln
;   29:     END
;   30:  }
;   31:     i := max;
	lda #23
	sta.w i_002
;   32:     j := FIB(22);
	lda #22
	pha.w
	phx.w
	jsr fib_005
	adj #4
	sta.w j_003
;   33:     write('Fib[');
	psh.w #S_013
	psh.w #0
	psh.w #4
	jsr _swrite
	adj #6
;   34:     write(i:2);
	lda.w i_002
	pha.w
	lda #2
	pha.w
	jsr _iwrite
	adj #4
;   35:     write('] = ');
	psh.w #S_014
	psh.w #0
	psh.w #4
	jsr _swrite
	adj #6
;   36:     write(j:5);
	lda.w j_003
	pha.w
	lda #5
	pha.w
	jsr _iwrite
	adj #4
;   37:     writeln
;   38:  
;   39:  END.
	jsr _writeln
	plx.w
	rts
	.end _pc65_main

	.dat

S_014 .str "] = "
S_013 .str "Fib["
_bss_start .byt 0
i_002 .wrd 0
j_003 .wrd 0
fn_004 .byt 0[48]
_bss_end .byt 0
_stk .byt 0[1023]
_stk_top .byt -1

	.end
