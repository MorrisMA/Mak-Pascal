;    1: PROGRAM newton (input, output);
	.stk	1024
	.cod	512
STATIC_LINK			.equ	+5
RETURN_VALUE		.equ	-3
HIGH_RETURN_VALUE	.equ	-1
_start
	tsx.w		; Preserve original stack pointer
	lds.w	#16383	; Initialize program stack pointer
	jmp	_pc65_main
;    2: 
;    3: CONST
;    4:     epsilon = 1e-6;
;    5: 
;    6: VAR
;    7:     number, root, sqroot : real;
;    8: 
;    9: BEGIN
_pc65_main	.sub
	phx.w
	tsx.w
;   10:     REPEAT
L_005
;   11:     writeln;
	jsr _writeln
;   12:     write('Enter new number (0 to quit): ');
	psh.w #S_007
	psh.w #0
	psh.w #30
	jsr _swrite
	adj #6
;   13:     read(number);
	psh.w #number_002
	jsr _fread
	pli
	sta.w 0,I++
	swp
	sta.w 0,I++
;   14: 
;   15:     IF number = 0 THEN BEGIN
	lda.w number_002+2	;emit_load_value
	swp
	lda.w number_002
	swp
	pha.w
	swp
	pha.w
	lda #0
	pha.w
	jsr _fconv
	adj #2
	swp
	pha.w
	swp
	pha.w
	jsr _fcmp
	adj #8
	cmp.w #0
	php
	lda #1
	plp
	beq L_010
	lda #0
L_010
	cmp.w #1
	beq L_008
	jmp  L_009
L_008
;   16:         writeln(number:12:6, 0.0:12:6);
	lda.w number_002+2	;emit_load_value
	swp
	lda.w number_002
	swp
	pha.w
	swp
	pha.w
	lda #12
	pha.w
	lda #6
	pha.w
	jsr _fwrite
	adj #8
	lda.w F_011+2	;float_literal
	swp
	lda.w F_011
	swp
	pha.w
	swp
	pha.w
	lda #12
	pha.w
	lda #6
	pha.w
	jsr _fwrite
	adj #8
	jsr _writeln
;   17:     END
;   18:     ELSE IF number < 0 THEN BEGIN
	jmp L_012
L_009
	lda.w number_002+2	;emit_load_value
	swp
	lda.w number_002
	swp
	pha.w
	swp
	pha.w
	lda #0
	pha.w
	jsr _fconv
	adj #2
	swp
	pha.w
	swp
	pha.w
	jsr _fcmp
	adj #8
	cmp.w #0
	php
	lda #1
	plp
	blt L_015
	lda #0
L_015
	cmp.w #1
	beq L_013
	jmp  L_014
L_013
;   19:         writeln('*** ERROR:  number < 0');
	psh.w #S_016
	psh.w #0
	psh.w #22
	jsr _swrite
	adj #6
	jsr _writeln
;   20:     END
;   21:     ELSE BEGIN
	jmp L_017
L_014
;   22:         sqroot := sqrt(number);
	lda.w number_002+2	;emit_load_value
	swp
	lda.w number_002
	swp
	pha.w
	swp
	pha.w
	jsr _fsqrt
	adj #4
	sta.w sqroot_004
	swp
	sta.w sqroot_004+2	;assgnment_statement
;   23:         writeln(number:12:6, sqroot:12:6);
	lda.w number_002+2	;emit_load_value
	swp
	lda.w number_002
	swp
	pha.w
	swp
	pha.w
	lda #12
	pha.w
	lda #6
	pha.w
	jsr _fwrite
	adj #8
	lda.w sqroot_004+2	;emit_load_value
	swp
	lda.w sqroot_004
	swp
	pha.w
	swp
	pha.w
	lda #12
	pha.w
	lda #6
	pha.w
	jsr _fwrite
	adj #8
	jsr _writeln
;   24:         writeln;
	jsr _writeln
;   25: 
;   26:         root := 1;
	lda #1
	pha.w
	jsr _fconv
	adj #2
	sta.w root_003
	swp
	sta.w root_003+2	;assgnment_statement
;   27:         REPEAT
L_018
;   28:         root := (number/root + root)/2;
	lda.w number_002+2	;emit_load_value
	swp
	lda.w number_002
	swp
	pha.w
	swp
	pha.w
	lda.w root_003+2	;emit_load_value
	swp
	lda.w root_003
	swp
	pha.w
	swp
	pha.w
	jsr _fdiv
	adj #8
	swp
	pha.w
	swp
	pha.w
	lda.w root_003+2	;emit_load_value
	swp
	lda.w root_003
	swp
	pha.w
	swp
	pha.w
	jsr _fadd
	adj #8
	swp
	pha.w
	swp
	pha.w
	lda #2
	pha.w
	jsr _fconv
	adj #2
	swp
	pha.w
	swp
	pha.w
	jsr _fdiv
	adj #8
	sta.w root_003
	swp
	sta.w root_003+2	;assgnment_statement
;   29:         writeln(root:24:6,
	lda.w root_003+2	;emit_load_value
	swp
	lda.w root_003
	swp
	pha.w
	swp
	pha.w
	lda #24
	pha.w
	lda #6
	pha.w
	jsr _fwrite
	adj #8
;   30:             100*abs(root - sqroot)/sqroot:12:2,
	lda #100
	pha.w
	lda.w root_003+2	;emit_load_value
	swp
	lda.w root_003
	swp
	pha.w
	swp
	pha.w
	lda.w sqroot_004+2	;emit_load_value
	swp
	lda.w sqroot_004
	swp
	pha.w
	swp
	pha.w
	jsr _fsub
	adj #8
	swp
	pha.w
	swp
	pha.w
	jsr _fabs
	adj #4
	swp
	pha.w
	swp
	pha.w
	pla.w
	swp
	pla.w
	ply.w
	pha.w
	swp
	pha.w
	phy.w
	jsr _fconv
	adj #2
	ply.w
	swp.y
	ply.w
	swp
	pha.w
	swp
	pha.w
	phy.w
	swp.y
	phy.w
	jsr _fmul
	adj #8
	swp
	pha.w
	swp
	pha.w
	lda.w sqroot_004+2	;emit_load_value
	swp
	lda.w sqroot_004
	swp
	pha.w
	swp
	pha.w
	jsr _fdiv
	adj #8
	swp
	pha.w
	swp
	pha.w
	lda #12
	pha.w
	lda #2
	pha.w
	jsr _fwrite
	adj #8
;   31:             '%')
	lda #37
	pha.w
	psh.w #0
	jsr _cwrite
	adj #4
;   32:         UNTIL abs(number/sqr(root) - 1) < epsilon;
	jsr _writeln
	lda.w number_002+2	;emit_load_value
	swp
	lda.w number_002
	swp
	pha.w
	swp
	pha.w
	lda.w root_003+2	;emit_load_value
	swp
	lda.w root_003
	swp
	pha.w
	swp
	pha.w
	swp
	pha.w
	swp
	pha.w
	jsr _fmul
	adj #8
	swp
	pha.w
	swp
	pha.w
	jsr _fdiv
	adj #8
	swp
	pha.w
	swp
	pha.w
	lda #1
	pha.w
	jsr _fconv
	adj #2
	swp
	pha.w
	swp
	pha.w
	jsr _fsub
	adj #8
	swp
	pha.w
	swp
	pha.w
	jsr _fabs
	adj #4
	swp
	pha.w
	swp
	pha.w
	lda.w F_020+2	;float_literal
	swp
	lda.w F_020
	swp
	pha.w
	swp
	pha.w
	jsr _fcmp
	adj #8
	cmp.w #0
	php
	lda #1
	plp
	blt L_021
	lda #0
L_021
	cmp.w #1
	beq L_019
	jmp L_018
L_019
;   33:     END
;   34:     UNTIL number = 0
L_017
L_012
	lda.w number_002+2	;emit_load_value
	swp
	lda.w number_002
	swp
	pha.w
	swp
	pha.w
	lda #0
;   35: END.
	pha.w
	jsr _fconv
	adj #2
	swp
	pha.w
	swp
	pha.w
	jsr _fcmp
	adj #8
	cmp.w #0
	php
	lda #1
	plp
	beq L_022
	lda #0
L_022
	cmp.w #1
	beq L_006
	jmp L_005
L_006
	plx.w
	rts
	.end	_pc65_main

	.dat

number_002	.byt	4
root_003	.byt	4
sqroot_004	.byt	4
F_020	.flt	1.000000e-06
F_011	.flt	0.000000e+00
S_016	.str	"*** ERROR:  number < 0"
S_007	.str	"Enter new number (0 to quit): "

	.end
