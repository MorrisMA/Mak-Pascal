;    1: PROGRAM eratosthenes (output);
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
;    4:     max = 1000;
;    5: 
;    6: VAR
;    7:     sieve : ARRAY [1..max] OF BOOLEAN;
;    8:     i, j, limit, prime, factor : INTEGER;
;    9: 
;   10: BEGIN

_pascal_main	PROC

	push	bp
	mov		bp,sp
;   11:     limit := max DIV 2;
	mov		ax,1000
	push	ax
	mov		ax,2
	mov		cx,ax
	pop		ax
	sub		dx,dx
	idiv	cx
	mov		WORD PTR limit_005,ax
;   12:     sieve[1] := FALSE;
	lea		ax,WORD PTR sieve_002
	push	ax
	mov		ax,1
	sub		ax,1
	mov		dx,2
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,0
	pop		bx
	mov		WORD PTR [bx],ax
;   13: 
;   14:     FOR i := 2 TO max DO
	mov		ax,2
	mov		WORD PTR i_003,ax
$L_008:
	mov		ax,1000
	cmp		WORD PTR i_003,ax
	jle		$L_009
	jmp		$L_010
$L_009:
;   15:         sieve[i] := TRUE;
	lea		ax,WORD PTR sieve_002
	push	ax
	mov		ax,WORD PTR i_003
	sub		ax,1
	mov		dx,2
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,1
	pop		bx
	mov		WORD PTR [bx],ax
	inc		WORD PTR i_003
	jmp		$L_008
$L_010:
	dec		WORD PTR i_003
;   16: 
;   17:     prime := 1;
	mov		ax,1
	mov		WORD PTR prime_006,ax
;   18: 
;   19:     REPEAT
$L_011:
;   20:         prime := prime + 1;
	mov		ax,WORD PTR prime_006
	push	ax
	mov		ax,1
	pop		dx
	add		ax,dx
	mov		WORD PTR prime_006,ax
;   21:         WHILE NOT sieve[prime] DO
$L_013:
	lea		ax,WORD PTR sieve_002
	push	ax
	mov		ax,WORD PTR prime_006
	sub		ax,1
	mov		dx,2
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	xor		ax,1
	cmp		ax,1
	je		$L_014
	jmp		$L_015
$L_014:
;   22:             prime := prime + 1;
	mov		ax,WORD PTR prime_006
	push	ax
	mov		ax,1
	pop		dx
	add		ax,dx
	mov		WORD PTR prime_006,ax
	jmp		$L_013
$L_015:
;   23: 
;   24:         factor := 2*prime;
	mov		ax,2
	push	ax
	mov		ax,WORD PTR prime_006
	pop		dx
	imul	dx
	mov		WORD PTR factor_007,ax
;   25: 
;   26:         WHILE factor <= max DO BEGIN
$L_016:
	mov		ax,WORD PTR factor_007
	push	ax
	mov		ax,1000
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jle		$L_019
	sub		ax,ax
$L_019:
	cmp		ax,1
	je		$L_017
	jmp		$L_018
$L_017:
;   27:             sieve[factor] := FALSE;
	lea		ax,WORD PTR sieve_002
	push	ax
	mov		ax,WORD PTR factor_007
	sub		ax,1
	mov		dx,2
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,0
	pop		bx
	mov		WORD PTR [bx],ax
;   28:             factor := factor + prime;
	mov		ax,WORD PTR factor_007
	push	ax
	mov		ax,WORD PTR prime_006
	pop		dx
	add		ax,dx
	mov		WORD PTR factor_007,ax
;   29:         END
;   30:     UNTIL prime > limit;
	jmp		$L_016
$L_018:
	mov		ax,WORD PTR prime_006
	push	ax
	mov		ax,WORD PTR limit_005
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jg		$L_020
	sub		ax,ax
$L_020:
	cmp		ax,1
	je		$L_012
	jmp		$L_011
$L_012:
;   31: 
;   32:     writeln('Sieve of Eratosthenes');
	lea		ax,WORD PTR $S_021
	push	ax
	mov		ax,0
	push	ax
	mov		ax,21
	push	ax
	call	_write_string
	add		sp,6
	call	_write_line
;   33:     writeln;
	call	_write_line
;   34: 
;   35:     i := 1;
	mov		ax,1
	mov		WORD PTR i_003,ax
;   36:     REPEAT
$L_022:
;   37:         FOR j := 0 TO 19 DO BEGIN
	mov		ax,0
	mov		WORD PTR j_004,ax
$L_024:
	mov		ax,19
	cmp		WORD PTR j_004,ax
	jle		$L_025
	jmp		$L_026
$L_025:
;   38:             prime := i + j;
	mov		ax,WORD PTR i_003
	push	ax
	mov		ax,WORD PTR j_004
	pop		dx
	add		ax,dx
	mov		WORD PTR prime_006,ax
;   39:             IF sieve[prime] THEN
	lea		ax,WORD PTR sieve_002
	push	ax
	mov		ax,WORD PTR prime_006
	sub		ax,1
	mov		dx,2
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	cmp		ax,1
	je		$L_027
	jmp		$L_028
$L_027:
;   40:                 write(prime:3)
	mov		ax,WORD PTR prime_006
	push	ax
	mov		ax,3
	push	ax
	call	_write_integer
	add		sp,4
;   41:             ELSE
	jmp		$L_029
$L_028:
;   42:                 write('   ');
	lea		ax,WORD PTR $S_030
	push	ax
	mov		ax,0
	push	ax
	mov		ax,3
	push	ax
	call	_write_string
	add		sp,6
$L_029:
;   43:         END;
	inc		WORD PTR j_004
	jmp		$L_024
$L_026:
	dec		WORD PTR j_004
;   44:         writeln;
	call	_write_line
;   45:         i := i + 20
	mov		ax,WORD PTR i_003
	push	ax
	mov		ax,20
;   46:     UNTIL i > max
	pop		dx
	add		ax,dx
	mov		WORD PTR i_003,ax
	mov		ax,WORD PTR i_003
	push	ax
;   47: END.
	mov		ax,1000
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jg		$L_031
	sub		ax,ax
$L_031:
	cmp		ax,1
	je		$L_023
	jmp		$L_022
$L_023:

	pop		bp
	ret	

_pascal_main	ENDP

	.DATA

sieve_002	DB	2000 DUP(0)
i_003	DW	0
j_004	DW	0
limit_005	DW	0
prime_006	DW	0
factor_007	DW	0
$S_030	DB	"   "
$S_021	DB	"Sieve of Eratosthenes"

	END
