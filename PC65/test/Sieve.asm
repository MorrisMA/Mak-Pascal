;    1: PROGRAM eratosthenes(output);
	.STACK  1024	;Set stack size

	.CODE	;place in CODE segment

STATIC_LINK			.EQ	+4	;--- base-relative STATIC_LINK			EQU	<WORD PTR [bp+4]>
RETURN_VALUE		.EQ	-4	;--- base-relativeRETURN_VALUE		EQU	<WORD PTR [bp-4]>
HIGH_RETURN_VALUE	.EQ	-2	;--- base-relative HIGH_RETURN_VALUE	EQU	<WORD PTR [bp-2]>

;    2: 
;    3: CONST
;    4:     max = 1000;
;    5: 
;    6: VAR
;    7:     sieve : ARRAY [1..max] OF BOOLEAN;
;    8:     i, j, limit, prime, factor : INTEGER;
;    9: 
;   10: BEGIN

_pc65_main	.PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
;   11:     limit := max DIV 2;
	lda.w #1000	;---	mov		ax,1000
	pha.w	;---	push	ax
	lda #2	;---	mov		ax,2
	pha.w	;---	mov		cx,ax
						;---	pop		ax
						;---	cwd	
	jsr _idiv	;---	idiv	cx
	adj #4	;pop ops/params
	sta.w limit_005	;---	mov		WORD PTR limit_005,ax
;   12:     sieve[1] := FALSE;
	psh.w #sieve_002	;---	lea		ax,WORD PTR sieve_002
						;---	push	ax
	lda #1	;---	mov		ax,1
	dec.w a	;---	sub		ax,1
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #0	;---	mov		ax,0
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;   13: 
;   14:     FOR i := 2 TO max DO
	lda #2	;---	mov		ax,2
	sta.w i_003	;---	mov		WORD PTR i_003,ax
L_008
	lda.w #1000	;---	mov		ax,1000
	cmp.w i_003	;---	cmp		WORD PTR i_003,ax
	bge L_009	;---	jle		L_009
	jmp L_010	;---	jmp		L_010
L_009
;   15:         sieve[i] := TRUE;
	psh.w #sieve_002	;---	lea		ax,WORD PTR sieve_002
						;---	push	ax
	lda.w i_003	;---	mov		ax,WORD PTR i_003
	dec.w a	;---	sub		ax,1
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #1	;---	mov		ax,1
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
	inc.w i_003	;---	inc		WORD PTR i_003
	jmp L_008	;---	jmp		L_008
L_010
	dec.w i_003	;---	dec		WORD PTR i_003
;   16: 
;   17:     prime := 1;
	lda #1	;---	mov		ax,1
	sta.w prime_006	;---	mov		WORD PTR prime_006,ax
;   18: 
;   19:     REPEAT
L_011
;   20:         prime := prime + 1;
	lda.w prime_006	;---	mov		ax,WORD PTR prime_006
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
	sta.w prime_006	;---	mov		WORD PTR prime_006,ax
;   21:         WHILE NOT sieve[prime] DO
L_013
	psh.w #sieve_002	;---	lea		ax,WORD PTR sieve_002
						;---	push	ax
	lda.w prime_006	;---	mov		ax,WORD PTR prime_006
	dec.w a	;---	sub		ax,1
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
						;---	pop		bx
	lda.w (0,S)	;---	mov		ax,WORD PTR [bx]
	adj #2	;pop ops/params
	eor #1	;---	xor		ax,1
	cmp.w #1	;---	cmp		ax,1
	beq L_014	;---	je		L_014
	jmp L_015	;---	jmp		L_015
L_014
;   22:             prime := prime + 1;
	lda.w prime_006	;---	mov		ax,WORD PTR prime_006
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
	sta.w prime_006	;---	mov		WORD PTR prime_006,ax
	jmp L_013	;---	jmp		L_013
L_015
;   23: 
;   24:         factor := 2*prime;
	lda #2	;---	mov		ax,2
	pha.w	;---	push	ax
	lda.w prime_006	;---	mov		ax,WORD PTR prime_006
	pha.w	;---	pop		dx
	jsr _imul	;---	imul	dx
	adj #4	;pop ops/params
	sta.w factor_007	;---	mov		WORD PTR factor_007,ax
;   25: 
;   26:         WHILE factor <= max DO BEGIN
L_016
	lda.w factor_007	;---	mov		ax,WORD PTR factor_007
	pha.w	;---	push	ax
	lda.w #1000	;---	mov		ax,1000
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	ble L_019	;---	jle		L_019
	lda #0	;---	sub		ax,ax
L_019
	cmp.w #1	;---	cmp		ax,1
	beq L_017	;---	je		L_017
	jmp L_018	;---	jmp		L_018
L_017
;   27:             sieve[factor] := FALSE;
	psh.w #sieve_002	;---	lea		ax,WORD PTR sieve_002
						;---	push	ax
	lda.w factor_007	;---	mov		ax,WORD PTR factor_007
	dec.w a	;---	sub		ax,1
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #0	;---	mov		ax,0
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;   28:             factor := factor + prime;
	lda.w factor_007	;---	mov		ax,WORD PTR factor_007
	pha.w	;---	push	ax
	lda.w prime_006	;---	mov		ax,WORD PTR prime_006
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
	sta.w factor_007	;---	mov		WORD PTR factor_007,ax
;   29:         END
;   30:     UNTIL prime > limit;
	jmp L_016	;---	jmp		L_016
L_018
	lda.w prime_006	;---	mov		ax,WORD PTR prime_006
	pha.w	;---	push	ax
	lda.w limit_005	;---	mov		ax,WORD PTR limit_005
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	bgt L_020	;---	jg		L_020
	lda #0	;---	sub		ax,ax
L_020
	cmp.w #1	;---	cmp		ax,1
	beq L_012	;---	je		L_012
	jmp L_011	;---	jmp		L_011
L_012
;   31: 
;   32:     writeln('Sieve of Eratosthenes');
	psh.w #S_021	;---	lea		ax,WORD PTR S_021
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #21	;---	mov		ax,21
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jsr _writeln	;---	call	_write_line
;   33:     writeln;
	jsr _writeln	;---	call	_write_line
;   34: 
;   35:     i := 1;
	lda #1	;---	mov		ax,1
	sta.w i_003	;---	mov		WORD PTR i_003,ax
;   36:     REPEAT
L_022
;   37:         FOR j := 0 TO 19 DO BEGIN
	lda #0	;---	mov		ax,0
	sta.w j_004	;---	mov		WORD PTR j_004,ax
L_024
	lda #19	;---	mov		ax,19
	cmp.w j_004	;---	cmp		WORD PTR j_004,ax
	bge L_025	;---	jle		L_025
	jmp L_026	;---	jmp		L_026
L_025
;   38:             prime := i + j;
	lda.w i_003	;---	mov		ax,WORD PTR i_003
	pha.w	;---	push	ax
	lda.w j_004	;---	mov		ax,WORD PTR j_004
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
	sta.w prime_006	;---	mov		WORD PTR prime_006,ax
;   39:             IF sieve[prime] THEN
	psh.w #sieve_002	;---	lea		ax,WORD PTR sieve_002
						;---	push	ax
	lda.w prime_006	;---	mov		ax,WORD PTR prime_006
	dec.w a	;---	sub		ax,1
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
						;---	pop		bx
	lda.w (0,S)	;---	mov		ax,WORD PTR [bx]
	adj #2	;pop ops/params
	cmp.w #1	;---	cmp		ax,1
	beq L_027	;---	je		L_027
	jmp  L_028	;---	jmp		L_028
L_027
;   40:                 write(prime:3)
	lda.w prime_006	;---	mov		ax,WORD PTR prime_006
	pha.w	;---	push	ax
	lda #3	;---	mov		ax,3
	pha.w	;---	push	ax
	jsr _iwrite	;---	call	_write_integer
	adj #4	;---	add		sp,4
;   41:             ELSE
	jmp L_029	;---	jmp		L_029
L_028
;   42:                 write('   ');
	psh.w #S_030	;---	lea		ax,WORD PTR S_030
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #3	;---	mov		ax,3
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
L_029
;   43:         END;
	inc.w j_004	;---	inc		WORD PTR j_004
	jmp L_024	;---	jmp		L_024
L_026
	dec.w j_004	;---	dec		WORD PTR j_004
;   44:         writeln;
	jsr _writeln	;---	call	_write_line
;   45:         i := i + 20
	lda.w i_003	;---	mov		ax,WORD PTR i_003
	pha.w	;---	push	ax
	lda #20	;---	mov		ax,20
;   46:     UNTIL i > max
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
	sta.w i_003	;---	mov		WORD PTR i_003,ax
	lda.w i_003	;---	mov		ax,WORD PTR i_003
	pha.w	;---	push	ax
;   47: END.
	lda.w #1000	;---	mov		ax,1000
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	bgt L_031	;---	jg		L_031
	lda #0	;---	sub		ax,ax
L_031
	cmp.w #1	;---	cmp		ax,1
	beq L_023	;---	je		L_023
	jmp L_022	;---	jmp		L_022
L_023

	plx.w	;---	pop		bp
	rts	;---	ret	

	.ENDP	_pc65_main

	.DATA	;place in DATA segment

sieve_002	.DB	2000	;define array
i_003	.DB	2	;define integer
j_004	.DB	2	;define integer
limit_005	.DB	2	;define integer
prime_006	.DB	2	;define integer
factor_007	.DB	2	;define integer
S_030	.DS	"   "	;string literal absolute
S_021	.DS	"Sieve of Eratosthenes"	;string literal absolute

	.END
