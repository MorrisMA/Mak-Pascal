;    1: PROGRAM eratosthenes(output);
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
	mov #15
	jmp _pc65_main
;    2: 
;    3: CONST
;    4:     max = 1000;
;    5: 
;    6: VAR
;    7:     sieve : ARRAY [1..max] OF BOOLEAN;
;    8:     i, j, limit, prime, factor : INTEGER;
;    9: 
;   10: BEGIN
_pc65_main .sub
	phx.w
	tsx.w
;   11:     limit := max DIV 2;
	lda.w #1000
	pha.w
	lda #2
	pha.w
	jsr _idiv
	adj #4
	sta.w limit_005
;   12:     sieve[1] := FALSE;
	psh.w #sieve_002
	lda #1
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #0
	pli.s
	sta.w 0,I++
;   13: 
;   14:     FOR i := 2 TO max DO
	lda #2
	sta.w i_003
L_008
	lda.w #1000
	cmp.w i_003
	bge L_009
	jmp L_010
L_009
;   15:         sieve[i] := TRUE;
	psh.w #sieve_002
	lda.w i_003
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #1
	pli.s
	sta.w 0,I++
	inc.w i_003
	jmp L_008
L_010
	dec.w i_003
;   16: 
;   17:     prime := 1;
	lda #1
	sta.w prime_006
;   18: 
;   19:     REPEAT
L_011
;   20:         prime := prime + 1;
	lda.w prime_006
	pha.w
	lda #1
	clc
	adc.w 1,S
	adj #2
	sta.w prime_006
;   21:         WHILE NOT sieve[prime] DO
L_013
	psh.w #sieve_002
	lda.w prime_006
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli.s
	lda.w 0,I++
	eor #1
	cmp.w #1
	beq L_014
	jmp L_015
L_014
;   22:             prime := prime + 1;
	lda.w prime_006
	pha.w
	lda #1
	clc
	adc.w 1,S
	adj #2
	sta.w prime_006
	jmp L_013
L_015
;   23: 
;   24:         factor := 2*prime;
	lda #2
	pha.w
	lda.w prime_006
	pha.w
	jsr _imul
	adj #4
	sta.w factor_007
;   25: 
;   26:         WHILE factor <= max DO BEGIN
L_016
	lda.w factor_007
	pha.w
	lda.w #1000
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	ble L_019
	lda #0
L_019
	cmp.w #1
	beq L_017
	jmp L_018
L_017
;   27:             sieve[factor] := FALSE;
	psh.w #sieve_002
	lda.w factor_007
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #0
	pli.s
	sta.w 0,I++
;   28:             factor := factor + prime;
	lda.w factor_007
	pha.w
	lda.w prime_006
	clc
	adc.w 1,S
	adj #2
	sta.w factor_007
;   29:         END
;   30:     UNTIL prime > limit;
	jmp L_016
L_018
	lda.w prime_006
	pha.w
	lda.w limit_005
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	bgt L_020
	lda #0
L_020
	cmp.w #1
	beq L_012
	jmp L_011
L_012
;   31: 
;   32:     writeln('Sieve of Eratosthenes');
	psh.w #S_021
	psh.w #0
	psh.w #21
	jsr _swrite
	adj #6
	jsr _writeln
;   33:     writeln;
	jsr _writeln
;   34: 
;   35:     i := 1;
	lda #1
	sta.w i_003
;   36:     REPEAT
L_022
;   37:         FOR j := 0 TO 19 DO BEGIN
	lda #0
	sta.w j_004
L_024
	lda #19
	cmp.w j_004
	bge L_025
	jmp L_026
L_025
;   38:             prime := i + j;
	lda.w i_003
	pha.w
	lda.w j_004
	clc
	adc.w 1,S
	adj #2
	sta.w prime_006
;   39:             IF sieve[prime] THEN
	psh.w #sieve_002
	lda.w prime_006
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli.s
	lda.w 0,I++
	cmp.w #1
	beq L_027
	jmp L_028
L_027
;   40:                 write(prime:3)
	lda.w prime_006
	pha.w
	lda #3
	pha.w
	jsr _iwrite
	adj #4
;   41:             ELSE
	jmp L_029
L_028
;   42:                 write('   ');
	psh.w #S_030
	psh.w #0
	psh.w #3
	jsr _swrite
	adj #6
L_029
;   43:         END;
	inc.w j_004
	jmp L_024
L_026
	dec.w j_004
;   44:         writeln;
	jsr _writeln
;   45:         i := i + 20
	lda.w i_003
	pha.w
	lda #20
;   46:     UNTIL i > max
	clc
	adc.w 1,S
	adj #2
	sta.w i_003
	lda.w i_003
	pha.w
;   47: END.
	lda.w #1000
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	bgt L_031
	lda #0
L_031
	cmp.w #1
	beq L_023
	jmp L_022
L_023
	plx.w
	rts
	.end _pc65_main

	.dat

S_030 .str "   "
S_021 .str "Sieve of Eratosthenes"
_bss_start .byt 1
sieve_002 .byt 2000
i_003 .wrd 1
j_004 .wrd 1
limit_005 .wrd 1
prime_006 .wrd 1
factor_007 .wrd 1
_bss_end .byt 1
_stk .byt 1023
_stk_top .byt 1

	.end
