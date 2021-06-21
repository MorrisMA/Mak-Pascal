;    1: PROGRAM newton (input, output);
	DOSSEG
	.MODEL  small
	.STACK  1024

	.CODE

	PUBLIC	_pascal_main
	INCLUDE	pasextrn.inc

$STATIC_LINK		EQU	<WORD PTR [bp+4]>
$RETURN_VALUE		EQU	<WORD PTR [bp-4]>
$HIGH_RETURN_VALUE	EQU	<WORD PTR [bp-2]>

;    2: 
;    3: CONST
;    4:     epsilon = 1e-6;
;    5: 
;    6: VAR
;    7:     number, root, sqroot : real;
;    8: 
;    9: BEGIN

_pascal_main	PROC

	push	bp
	mov		bp,sp
;   10:     REPEAT
$L_005:
;   11:     writeln;
	call	_write_line
;   12:     write('Enter new number (0 to quit): ');
	lea		ax,WORD PTR $S_007
	push	ax
	mov		ax,0
	push	ax
	mov		ax,30
	push	ax
	call	_write_string
	add		sp,6
;   13:     read(number);
	lea		ax,WORD PTR number_002
	push	ax
	call	_read_real
	pop		bx
	mov		WORD PTR [bx],ax
	mov		WORD PTR [bx+2],dx
;   14: 
;   15:     IF number = 0 THEN BEGIN
	mov		ax,WORD PTR number_002
	mov		dx,WORD PTR number_002+2
	push	dx
	push	ax
	mov		ax,0
	push	ax
	call	_float_convert
	add		sp,2
	push	dx
	push	ax
	call	_float_compare
	add		sp,8
	cmp		ax,0
	mov		ax,1
	je		$L_010
	sub		ax,ax
$L_010:
	cmp		ax,1
	je		$L_008
	jmp		$L_009
$L_008:
;   16:         writeln(number:12:6, 0.0:12:6);
	mov		ax,WORD PTR number_002
	mov		dx,WORD PTR number_002+2
	push	dx
	push	ax
	mov		ax,12
	push	ax
	mov		ax,6
	push	ax
	call	_write_real
	add		sp,8
	mov		ax,WORD PTR $F_011
	mov		dx,WORD PTR $F_011+2
	push	dx
	push	ax
	mov		ax,12
	push	ax
	mov		ax,6
	push	ax
	call	_write_real
	add		sp,8
	call	_write_line
;   17:     END
;   18:     ELSE IF number < 0 THEN BEGIN
	jmp		$L_012
$L_009:
	mov		ax,WORD PTR number_002
	mov		dx,WORD PTR number_002+2
	push	dx
	push	ax
	mov		ax,0
	push	ax
	call	_float_convert
	add		sp,2
	push	dx
	push	ax
	call	_float_compare
	add		sp,8
	cmp		ax,0
	mov		ax,1
	jl		$L_015
	sub		ax,ax
$L_015:
	cmp		ax,1
	je		$L_013
	jmp		$L_014
$L_013:
;   19:         writeln('*** ERROR:  number < 0');
	lea		ax,WORD PTR $S_016
	push	ax
	mov		ax,0
	push	ax
	mov		ax,22
	push	ax
	call	_write_string
	add		sp,6
	call	_write_line
;   20:     END
;   21:     ELSE BEGIN
	jmp		$L_017
$L_014:
;   22:         sqroot := sqrt(number);
	mov		ax,WORD PTR number_002
	mov		dx,WORD PTR number_002+2
	push	dx
	push	ax
	call	_std_sqrt
	add		sp,4
	mov		WORD PTR sqroot_004,ax
	mov		WORD PTR sqroot_004+2,dx
;   23:         writeln(number:12:6, sqroot:12:6);
	mov		ax,WORD PTR number_002
	mov		dx,WORD PTR number_002+2
	push	dx
	push	ax
	mov		ax,12
	push	ax
	mov		ax,6
	push	ax
	call	_write_real
	add		sp,8
	mov		ax,WORD PTR sqroot_004
	mov		dx,WORD PTR sqroot_004+2
	push	dx
	push	ax
	mov		ax,12
	push	ax
	mov		ax,6
	push	ax
	call	_write_real
	add		sp,8
	call	_write_line
;   24:         writeln;
	call	_write_line
;   25: 
;   26:         root := 1;
	mov		ax,1
	push	ax
	call	_float_convert
	add		sp,2
	mov		WORD PTR root_003,ax
	mov		WORD PTR root_003+2,dx
;   27:         REPEAT
$L_018:
;   28:         root := (number/root + root)/2;
	mov		ax,WORD PTR number_002
	mov		dx,WORD PTR number_002+2
	push	dx
	push	ax
	mov		ax,WORD PTR root_003
	mov		dx,WORD PTR root_003+2
	push	dx
	push	ax
	call	_float_divide
	add		sp,8
	push	dx
	push	ax
	mov		ax,WORD PTR root_003
	mov		dx,WORD PTR root_003+2
	push	dx
	push	ax
	call	_float_add
	add		sp,8
	push	dx
	push	ax
	mov		ax,2
	push	ax
	call	_float_convert
	add		sp,2
	push	dx
	push	ax
	call	_float_divide
	add		sp,8
	mov		WORD PTR root_003,ax
	mov		WORD PTR root_003+2,dx
;   29:         writeln(root:24:6,
	mov		ax,WORD PTR root_003
	mov		dx,WORD PTR root_003+2
	push	dx
	push	ax
	mov		ax,24
	push	ax
	mov		ax,6
	push	ax
	call	_write_real
	add		sp,8
;   30:             100*abs(root - sqroot)/sqroot:12:2,
	mov		ax,100
	push	ax
	mov		ax,WORD PTR root_003
	mov		dx,WORD PTR root_003+2
	push	dx
	push	ax
	mov		ax,WORD PTR sqroot_004
	mov		dx,WORD PTR sqroot_004+2
	push	dx
	push	ax
	call	_float_subtract
	add		sp,8
	push	dx
	push	ax
	call	_std_abs
	add		sp,4
	push	dx
	push	ax
	pop		ax
	pop		dx
	pop		bx
	push	dx
	push	ax
	push	bx
	call	_float_convert
	add		sp,2
	pop		bx
	pop		cx
	push	dx
	push	ax
	push	cx
	push	bx
	call	_float_multiply
	add		sp,8
	push	dx
	push	ax
	mov		ax,WORD PTR sqroot_004
	mov		dx,WORD PTR sqroot_004+2
	push	dx
	push	ax
	call	_float_divide
	add		sp,8
	push	dx
	push	ax
	mov		ax,12
	push	ax
	mov		ax,2
	push	ax
	call	_write_real
	add		sp,8
;   31:             '%')
	mov		ax,'%'
	push	ax
	mov		ax,0
	push	ax
	call	_write_char
	add		sp,4
;   32:         UNTIL abs(number/sqr(root) - 1) < epsilon;
	call	_write_line
	mov		ax,WORD PTR number_002
	mov		dx,WORD PTR number_002+2
	push	dx
	push	ax
	mov		ax,WORD PTR root_003
	mov		dx,WORD PTR root_003+2
	push	dx
	push	ax
	push	dx
	push	ax
	call	_float_multiply
	add		sp,8
	push	dx
	push	ax
	call	_float_divide
	add		sp,8
	push	dx
	push	ax
	mov		ax,1
	push	ax
	call	_float_convert
	add		sp,2
	push	dx
	push	ax
	call	_float_subtract
	add		sp,8
	push	dx
	push	ax
	call	_std_abs
	add		sp,4
	push	dx
	push	ax
	mov		ax,WORD PTR $F_020
	mov		dx,WORD PTR $F_020+2
	push	dx
	push	ax
	call	_float_compare
	add		sp,8
	cmp		ax,0
	mov		ax,1
	jl		$L_021
	sub		ax,ax
$L_021:
	cmp		ax,1
	je		$L_019
	jmp		$L_018
$L_019:
;   33:     END
;   34:     UNTIL number = 0
$L_017:
$L_012:
	mov		ax,WORD PTR number_002
	mov		dx,WORD PTR number_002+2
	push	dx
	push	ax
	mov		ax,0
;   35: END.
	push	ax
	call	_float_convert
	add		sp,2
	push	dx
	push	ax
	call	_float_compare
	add		sp,8
	cmp		ax,0
	mov		ax,1
	je		$L_022
	sub		ax,ax
$L_022:
	cmp		ax,1
	je		$L_006
	jmp		$L_005
$L_006:

	pop		bp
	ret	

_pascal_main	ENDP

	.DATA

number_002	DD	0.0
root_003	DD	0.0
sqroot_004	DD	0.0
$F_020	DD	1.000000e-006
$F_011	DD	0.000000e+000
$S_016	DB	"*** ERROR:  number < 0"
$S_007	DB	"Enter new number (0 to quit): "

	END
