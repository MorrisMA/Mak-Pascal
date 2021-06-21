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
;    8:     
;    9: FUNCTION FIB(n : INTEGER) : INTEGER;
;   10:     VAR i, tmp, fn1, fn2 : INTEGER;
;   11:     
;   12:     BEGIN
n_005 .equ +7
i_006 .equ -5
tmp_007 .equ -7
fn1_008 .equ -9
fn2_009 .equ -11
fib_004 .sub
	phx.w
	tsx.w
	adj #-4
	adj #-8
;   13:         fn1 := 1;
	lda #1
	sta.w fn1_008,X
;   14:         fn2 := 0;
	lda #0
	sta.w fn2_009,X
;   15:         
;   16:         IF n < 1 THEN
	lda.w n_005,X
	pha.w
	lda #1
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	blt L_012
	lda #0
L_012
	cmp.w #1
	beq L_010
	jmp L_011
L_010
;   17:             FIB := fn2
;   18:         ELSE BEGIN
	lda.w fn2_009,X
	sta.w RETURN_VALUE,X
	jmp L_013
L_011
;   19:             i := 1;
	lda #1
	sta.w i_006,X
;   20:             REPEAT
L_014
;   21:                 tmp := fn1 + fn2;
	lda.w fn1_008,X
	pha.w
	lda.w fn2_009,X
	clc
	adc.w 1,S
	adj #2
	sta.w tmp_007,X
;   22:                 fn2 := fn1;
	lda.w fn1_008,X
	sta.w fn2_009,X
;   23:                 fn1 := tmp;
	lda.w tmp_007,X
	sta.w fn1_008,X
;   24:                 
;   25:                 i := i + 1
	lda.w i_006,X
	pha.w
	lda #1
;   26:             UNTIL (i >= n);
	clc
	adc.w 1,S
	adj #2
	sta.w i_006,X
	lda.w i_006,X
	pha.w
	lda.w n_005,X
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	bge L_016
	lda #0
L_016
	cmp.w #1
	beq L_015
	jmp L_014
L_015
;   27:             
;   28:             FIB := fn1
;   29:         END
	lda.w fn1_008,X
	sta.w RETURN_VALUE,X
;   30:     END;
L_013
	lda.w RETURN_VALUE,X
	txs.w
	plx.w
	rts
	.end fib_004
;   31:     
;   32: BEGIN
_pc65_main .sub
	phx.w
	tsx.w
;   33: {
;   34:     FOR i := 1 to max DO BEGIN
;   35:         j := FIB(i);
;   36:     END;
;   37: }
;   38:     i := max;
	lda #23
	sta.w i_002
;   39:     j := FIB(i);
	lda.w i_002
	pha.w
	phx.w
	jsr fib_004
	adj #4
	sta.w j_003
;   40:     write('Fib[');
	psh.w #S_017
	psh.w #0
	psh.w #4
	jsr _swrite
	adj #6
;   41:     write(i:2);
	lda.w i_002
	pha.w
	lda #2
	pha.w
	jsr _iwrite
	adj #4
;   42:     write('] = ');
	psh.w #S_018
	psh.w #0
	psh.w #4
	jsr _swrite
	adj #6
;   43:     write(j:5);
	lda.w j_003
	pha.w
	lda #5
	pha.w
	jsr _iwrite
	adj #4
;   44:     writeln
;   45: END.
	jsr _writeln
	plx.w
	rts
	.end _pc65_main

	.dat

S_018 .str "] = "
S_017 .str "Fib["
_bss_start .byt 0
i_002 .wrd 0
j_003 .wrd 0
_bss_end .byt 0
_stk .byt 0[1023]
_stk_top .byt -1

	.end
