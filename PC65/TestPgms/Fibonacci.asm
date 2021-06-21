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
;    7:     FN1, FN2 : INTEGER;
;    8:     tmp, i   : INTEGER;
;    9:     
;   10: BEGIN
_pc65_main .sub
	phx.w
	tsx.w
;   11:     FN1 := 1;
	lda #1
	sta.w fn1_002
;   12:     FN2 := 0;
	lda #0
	sta.w fn2_003
;   13:     
;   14:     FOR i := 2 to max DO BEGIN
	lda #2
	sta.w i_005
L_006
	lda #23
	cmp.w i_005
	bge L_007
	jmp L_008
L_007
;   15:         tmp := FN1 + FN2;
	lda.w fn1_002
	pha.w
	lda.w fn2_003
	clc
	adc.w 1,S
	adj #2
	sta.w tmp_004
;   16:         FN2 := FN1;
	lda.w fn1_002
	sta.w fn2_003
;   17:         FN1 := tmp;
	lda.w tmp_004
	sta.w fn1_002
;   18:     END;
	inc.w i_005
	jmp L_006
L_008
	dec.w i_005
;   19:     write('Fib[');
	psh.w #S_009
	psh.w #0
	psh.w #4
	jsr _swrite
	adj #6
;   20:     write(i:2);
	lda.w i_005
	pha.w
	lda #2
	pha.w
	jsr _iwrite
	adj #4
;   21:     write('] = ');
	psh.w #S_010
	psh.w #0
	psh.w #4
	jsr _swrite
	adj #6
;   22:     write(FN1:5);
	lda.w fn1_002
	pha.w
	lda #5
	pha.w
	jsr _iwrite
	adj #4
;   23:     writeln;
	jsr _writeln
;   24: END.
	plx.w
	rts
	.end _pc65_main

	.dat

S_010 .str "] = "
S_009 .str "Fib["
_bss_start .byt 0
fn1_002 .wrd 0
fn2_003 .wrd 0
tmp_004 .wrd 0
i_005 .wrd 0
_bss_end .byt 0
_stk .byt 0[1023]
_stk_top .byt -1

	.end
