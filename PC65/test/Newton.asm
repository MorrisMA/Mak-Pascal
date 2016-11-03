;    1: PROGRAM newton (input, output);
	DOSSEG
	.MODEL  small
	.STACK  1024	;Set stack size

	.CODE	;place in CODE segment

	PUBLIC	_pascal_main
	INCLUDE	pasextrn.inc

STATIC_LINK			EQU	+4	;--- base-relative STATIC_LINK			EQU	<WORD PTR [bp+4]>
RETURN_VALUE		EQU	-4	;--- base-relativeRETURN_VALUE		EQU	<WORD PTR [bp-4]>
HIGH_RETURN_VALUE	EQU	-2	;--- base-relative HIGH_RETURN_VALUE	EQU	<WORD PTR [bp-2]>

;    2: 
;    3: CONST
;    4:     epsilon = 1e-6;
;    5: 
;    6: VAR
;    7:     number, root, sqroot : real;
;    8: 
;    9: BEGIN

_pascal_main	PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
;   10:     REPEAT
L_005:
;   11:     writeln;
	jsr _writeln	;---	call	_write_line
;   12:     write('Enter new number (0 to quit): ');
	psh.w #S_007	;---	lea		ax,WORD PTR S_007
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #30	;---	mov		ax,30
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
;   13:     read(number);
	psh.w #number_002	;---	lea		ax,WORD PTR number_002
	jsr _fread	;---	call	_read_real
					;---	pop		bx
	swp	;---	mov		WORD PTR [bx+2],dx
	ldy #2	;load offset to hi word
	sta.w (0,S),Y	;store hi word
	swp	;---	mov		WORD PTR [bx],ax
	sta.w (0,S)	;store lo word
	adj #2	;pop ops/params
;   14: 
;   15:     IF number = 0 THEN BEGIN
	lda.w number_002+2	;---	mov		dx,WORD PTR number_002+2
	swp	;---	mov		ax,WORD PTR number_002
	lda.w number_002	;load lo word
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	lda #0	;---	mov		ax,0
	pha.w	;---	push	ax
	jsr _fconv	;---	call	_float_convert
	adj #2	;---	add		sp,2
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	jsr _fcmp	;---	call	_float_compare
	adj #8	;---	add		sp,8
	cmp.w #0	;---	cmp		ax,0
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_010	;---	je		L_010
	lda #0	;---	sub		ax,ax
L_010:
	cmp.w #1	;---	cmp		ax,1
	beq L_008	;---	je		L_008
	jmp  L_009	;---	jmp		L_009
L_008:
;   16:         writeln(number:12:6, 0.0:12:6);
	lda.w number_002+2	;---	mov		dx,WORD PTR number_002+2
	swp	;---	mov		ax,WORD PTR number_002
	lda.w number_002	;load lo word
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	lda #12	;---	mov		ax,12
	pha.w	;---	push	ax
	lda #6	;---	mov		ax,6
	pha.w	;---	push	ax
	jsr _fwrite	;---	call	_write_real
	adj #8	;---	add		sp,8
	lda.w F_011+2	;---	mov		dx,WORD PTR F_011+2
	swp	;---	mov		ax,WORD PTR F_011
	lda.w F_011	;load lo word
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	lda #12	;---	mov		ax,12
	pha.w	;---	push	ax
	lda #6	;---	mov		ax,6
	pha.w	;---	push	ax
	jsr _fwrite	;---	call	_write_real
	adj #8	;---	add		sp,8
	jsr _writeln	;---	call	_write_line
;   17:     END
;   18:     ELSE IF number < 0 THEN BEGIN
	jmp L_012	;---	jmp		L_012
L_009:
	lda.w number_002+2	;---	mov		dx,WORD PTR number_002+2
	swp	;---	mov		ax,WORD PTR number_002
	lda.w number_002	;load lo word
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	lda #0	;---	mov		ax,0
	pha.w	;---	push	ax
	jsr _fconv	;---	call	_float_convert
	adj #2	;---	add		sp,2
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	jsr _fcmp	;---	call	_float_compare
	adj #8	;---	add		sp,8
	cmp.w #0	;---	cmp		ax,0
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	blt L_015	;---	jl		L_015
	lda #0	;---	sub		ax,ax
L_015:
	cmp.w #1	;---	cmp		ax,1
	beq L_013	;---	je		L_013
	jmp  L_014	;---	jmp		L_014
L_013:
;   19:         writeln('*** ERROR:  number < 0');
	psh.w #S_016	;---	lea		ax,WORD PTR S_016
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #22	;---	mov		ax,22
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jsr _writeln	;---	call	_write_line
;   20:     END
;   21:     ELSE BEGIN
	jmp L_017	;---	jmp		L_017
L_014:
;   22:         sqroot := sqrt(number);
	lda.w number_002+2	;---	mov		dx,WORD PTR number_002+2
	swp	;---	mov		ax,WORD PTR number_002
	lda.w number_002	;load lo word
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	jsr _fsqrt	;---	call	_std_sqrt
	adj #4	;---	add		sp,4
	swp	;---	mov		WORD PTR sqroot_004+2,dx
	sta.w sqroot_004+2	;store hi word
	swp	;---	mov		WORD PTR sqroot_004,ax
	sta.w sqroot_004	;store lo word
;   23:         writeln(number:12:6, sqroot:12:6);
	lda.w number_002+2	;---	mov		dx,WORD PTR number_002+2
	swp	;---	mov		ax,WORD PTR number_002
	lda.w number_002	;load lo word
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	lda #12	;---	mov		ax,12
	pha.w	;---	push	ax
	lda #6	;---	mov		ax,6
	pha.w	;---	push	ax
	jsr _fwrite	;---	call	_write_real
	adj #8	;---	add		sp,8
	lda.w sqroot_004+2	;---	mov		dx,WORD PTR sqroot_004+2
	swp	;---	mov		ax,WORD PTR sqroot_004
	lda.w sqroot_004	;load lo word
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	lda #12	;---	mov		ax,12
	pha.w	;---	push	ax
	lda #6	;---	mov		ax,6
	pha.w	;---	push	ax
	jsr _fwrite	;---	call	_write_real
	adj #8	;---	add		sp,8
	jsr _writeln	;---	call	_write_line
;   24:         writeln;
	jsr _writeln	;---	call	_write_line
;   25: 
;   26:         root := 1;
	lda #1	;---	mov		ax,1
	pha.w	;---	push	ax
	jsr _fconv	;---	call	_float_convert
	adj #2	;---	add		sp,2
	swp	;---	mov		WORD PTR root_003+2,dx
	sta.w root_003+2	;store hi word
	swp	;---	mov		WORD PTR root_003,ax
	sta.w root_003	;store lo word
;   27:         REPEAT
L_018:
;   28:         root := (number/root + root)/2;
	lda.w number_002+2	;---	mov		dx,WORD PTR number_002+2
	swp	;---	mov		ax,WORD PTR number_002
	lda.w number_002	;load lo word
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	lda.w root_003+2	;---	mov		dx,WORD PTR root_003+2
	swp	;---	mov		ax,WORD PTR root_003
	lda.w root_003	;load lo word
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	jsr _fdiv	;---	call	_float_divide
	adj #8	;---	add		sp,8
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	lda.w root_003+2	;---	mov		dx,WORD PTR root_003+2
	swp	;---	mov		ax,WORD PTR root_003
	lda.w root_003	;load lo word
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	jsr _fadd	;---	call	_float_add
	adj #8	;---	add		sp,8
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	lda #2	;---	mov		ax,2
	pha.w	;---	push	ax
	jsr _fconv	;---	call	_float_convert
	adj #2	;---	add		sp,2
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	jsr _fdiv	;---	call	_float_divide
	adj #8	;---	add		sp,8
	swp	;---	mov		WORD PTR root_003+2,dx
	sta.w root_003+2	;store hi word
	swp	;---	mov		WORD PTR root_003,ax
	sta.w root_003	;store lo word
;   29:         writeln(root:24:6,
	lda.w root_003+2	;---	mov		dx,WORD PTR root_003+2
	swp	;---	mov		ax,WORD PTR root_003
	lda.w root_003	;load lo word
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	lda #24	;---	mov		ax,24
	pha.w	;---	push	ax
	lda #6	;---	mov		ax,6
	pha.w	;---	push	ax
	jsr _fwrite	;---	call	_write_real
	adj #8	;---	add		sp,8
;   30:             100*abs(root - sqroot)/sqroot:12:2,
	lda #100	;---	mov		ax,100
	pha.w	;---	push	ax
	lda.w root_003+2	;---	mov		dx,WORD PTR root_003+2
	swp	;---	mov		ax,WORD PTR root_003
	lda.w root_003	;load lo word
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	lda.w sqroot_004+2	;---	mov		dx,WORD PTR sqroot_004+2
	swp	;---	mov		ax,WORD PTR sqroot_004
	lda.w sqroot_004	;load lo word
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	jsr _fsub	;---	call	_float_subtract
	adj #8	;---	add		sp,8
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	jsr _fabs	;---	call	_std_abs
	adj #4	;---	add		sp,4
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	pla.w	;---	pop		ax
	swp	;---	pop		dx
	pla.w	;push acc
	ply.w	;---	pop		bx
	pha.w	;---	push	dx
	swp	;---	push	ax
	pha.w	;push acc
	phy.w	;---	push	bx
	jsr _fconv	;---	call	_float_convert
	adj #2	;---	add		sp,2
	ply.w	;---	pop		bx
	swp.y	;---	pop		cx
	ply.w	;pull Y
	swp	;---	push	dx
	pha.w
	swp	;---	push	ax
	pha.w	;push acc
	phy.w	;---	push	cx
	swp.y	;---	push	bx
	phy.w	;push Y
	jsr _fmul	;---	call	_float_multiply
	adj #8	;---	add		sp,8
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	lda.w sqroot_004+2	;---	mov		dx,WORD PTR sqroot_004+2
	swp	;---	mov		ax,WORD PTR sqroot_004
	lda.w sqroot_004	;load lo word
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	jsr _fdiv	;---	call	_float_divide
	adj #8	;---	add		sp,8
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	lda #12	;---	mov		ax,12
	pha.w	;---	push	ax
	lda #2	;---	mov		ax,2
	pha.w	;---	push	ax
	jsr _fwrite	;---	call	_write_real
	adj #8	;---	add		sp,8
;   31:             '%')
	lda #37	;---	mov		ax,'%'
	pha.w	;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	jsr _cwrite	;---	call	_write_char
	adj #4	;---	add		sp,4
;   32:         UNTIL abs(number/sqr(root) - 1) < epsilon;
	jsr _writeln	;---	call	_write_line
	lda.w number_002+2	;---	mov		dx,WORD PTR number_002+2
	swp	;---	mov		ax,WORD PTR number_002
	lda.w number_002	;load lo word
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	lda.w root_003+2	;---	mov		dx,WORD PTR root_003+2
	swp	;---	mov		ax,WORD PTR root_003
	lda.w root_003	;load lo word
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	jsr _fmul	;---	call	_float_multiply
	adj #8	;---	add		sp,8
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	jsr _fdiv	;---	call	_float_divide
	adj #8	;---	add		sp,8
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	lda #1	;---	mov		ax,1
	pha.w	;---	push	ax
	jsr _fconv	;---	call	_float_convert
	adj #2	;---	add		sp,2
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	jsr _fsub	;---	call	_float_subtract
	adj #8	;---	add		sp,8
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	jsr _fabs	;---	call	_std_abs
	adj #4	;---	add		sp,4
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	lda.w F_020+2	;---	mov		dx,WORD PTR F_020+2
	swp	;---	mov		ax,WORD PTR F_020
	lda.w F_020	;load lo word
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	jsr _fcmp	;---	call	_float_compare
	adj #8	;---	add		sp,8
	cmp.w #0	;---	cmp		ax,0
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	blt L_021	;---	jl		L_021
	lda #0	;---	sub		ax,ax
L_021:
	cmp.w #1	;---	cmp		ax,1
	beq L_019	;---	je		L_019
	jmp L_018	;---	jmp		L_018
L_019:
;   33:     END
;   34:     UNTIL number = 0
L_017:
L_012:
	lda.w number_002+2	;---	mov		dx,WORD PTR number_002+2
	swp	;---	mov		ax,WORD PTR number_002
	lda.w number_002	;load lo word
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	lda #0	;---	mov		ax,0
;   35: END.
	pha.w	;---	push	ax
	jsr _fconv	;---	call	_float_convert
	adj #2	;---	add		sp,2
	swp	;---	push	dx
	pha.w	;push acc
	swp	;---	push	ax
	pha.w	;push acc
	jsr _fcmp	;---	call	_float_compare
	adj #8	;---	add		sp,8
	cmp.w #0	;---	cmp		ax,0
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_022	;---	je		L_022
	lda #0	;---	sub		ax,ax
L_022:
	cmp.w #1	;---	cmp		ax,1
	beq L_006	;---	je		L_006
	jmp L_005	;---	jmp		L_005
L_006:

	plx.w	;---	pop		bp
	rts	;---	ret	

_pascal_main	ENDP

	.DATA	;place in DATA segment

number_002	DB	4	;define real
root_003	DB	4	;define real
sqroot_004	DB	4	;define real
F_020	DD	1.000000e-06	;real literal absolute
F_011	DD	0.000000e+00	;real literal absolute
S_016	DS	"*** ERROR:  number < 0"	;string literal absolute
S_007	DS	"Enter new number (0 to quit): "	;string literal absolute

	END
