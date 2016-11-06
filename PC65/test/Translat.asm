;    1: PROGRAM NumberTranslator (input, output);
	.STACK  1024	;Set stack size

	.CODE	;place in CODE segment

STATIC_LINK			.EQ	+4	;--- base-relative STATIC_LINK			EQU	<WORD PTR [bp+4]>
RETURN_VALUE		.EQ	-4	;--- base-relativeRETURN_VALUE		EQU	<WORD PTR [bp-4]>
HIGH_RETURN_VALUE	.EQ	-2	;--- base-relative HIGH_RETURN_VALUE	EQU	<WORD PTR [bp-2]>

;    2: 
;    3: {   Translate a list of integers from numeric form into
;    4:     words.  The integers must not be negative nor be
;    5:     greater than the value of maxnumber.  The last
;    6:     integer in the list has the value of terminator.
;    7: }
;    8: 
;    9: CONST
;   10:     maxnumber  = 30000; {maximum allowable number}
;   11:     terminator = 0;     {last number in list}
;   12: 
;   13: VAR
;   14:     number : integer;   {number to be translated}
;   15: 
;   16: 
;   17:     PROCEDURE Translate (n : integer);
;   18: 
;   19:         {Translate number n into words.}
;   20: 
;   21:         VAR
;   22:             partbefore,     {part before the comma}
;   23:             partafter       {part after the comma}
;   24:              : integer;
;   25: 
;   26: 
;   27:         PROCEDURE DoPart (part : integer);

n_004	.EQ	+6	;base-relative	---n_004	EQU	<[bp+6]>
partbefore_005	.EQ	-2	;base-relative	---partbefore_005	EQU	<[bp-2]>
partafter_006	.EQ	-4	;base-relative	---partafter_006	EQU	<[bp-4]>
;   28: 
;   29:         {Translate a part of a number into words,
;   30:          where 1 <= part <= 999.}
;   31: 
;   32:         VAR
;   33:             hundredsdigit,  {hundreds digit 0..9}
;   34:             tenspart,           {tens part 0..99}
;   35:             tensdigit,          {tens digit 0..9}
;   36:             onesdigit           {ones digit 0..9}
;   37:             : integer;
;   38: 
;   39: 
;   40:             PROCEDURE DoOnes (digit : integer);

part_008	.EQ	+6	;base-relative	---part_008	EQU	<[bp+6]>
hundredsdigit_009	.EQ	-2	;base-relative	---hundredsdigit_009	EQU	<[bp-2]>
tenspart_010	.EQ	-4	;base-relative	---tenspart_010	EQU	<[bp-4]>
tensdigit_011	.EQ	-6	;base-relative	---tensdigit_011	EQU	<[bp-6]>
onesdigit_012	.EQ	-8	;base-relative	---onesdigit_012	EQU	<[bp-8]>
;   41: 
;   42:             {Translate a single ones digit into a word,
;   43:              where 1 <= digit <= 9.}
;   44: 
;   45:             BEGIN

digit_014	.EQ	+6	;base-relative	---digit_014	EQU	<[bp+6]>

doones_013	.PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
;   46:                 CASE digit OF
	lda.w digit_014,B	;---	mov		ax,WORD PTR digit_014
;   47:                     1:  write (' one');
	cmp.w #1	;---	cmp		ax,1
	bne L_017	;---	jne		L_017
L_016
	psh.w #S_018	;---	lea		ax,WORD PTR S_018
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #4	;---	mov		ax,4
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_015	;---	jmp		L_015
L_017
;   48:                     2:  write (' two');
	cmp.w #2	;---	cmp		ax,2
	bne L_020	;---	jne		L_020
L_019
	psh.w #S_021	;---	lea		ax,WORD PTR S_021
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #4	;---	mov		ax,4
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_015	;---	jmp		L_015
L_020
;   49:                     3:  write (' three');
	cmp.w #3	;---	cmp		ax,3
	bne L_023	;---	jne		L_023
L_022
	psh.w #S_024	;---	lea		ax,WORD PTR S_024
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #6	;---	mov		ax,6
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_015	;---	jmp		L_015
L_023
;   50:                     4:  write (' four');
	cmp.w #4	;---	cmp		ax,4
	bne L_026	;---	jne		L_026
L_025
	psh.w #S_027	;---	lea		ax,WORD PTR S_027
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #5	;---	mov		ax,5
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_015	;---	jmp		L_015
L_026
;   51:                     5:  write (' five');
	cmp.w #5	;---	cmp		ax,5
	bne L_029	;---	jne		L_029
L_028
	psh.w #S_030	;---	lea		ax,WORD PTR S_030
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #5	;---	mov		ax,5
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_015	;---	jmp		L_015
L_029
;   52:                     6:  write (' six');
	cmp.w #6	;---	cmp		ax,6
	bne L_032	;---	jne		L_032
L_031
	psh.w #S_033	;---	lea		ax,WORD PTR S_033
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #4	;---	mov		ax,4
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_015	;---	jmp		L_015
L_032
;   53:                     7:  write (' seven');
	cmp.w #7	;---	cmp		ax,7
	bne L_035	;---	jne		L_035
L_034
	psh.w #S_036	;---	lea		ax,WORD PTR S_036
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #6	;---	mov		ax,6
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_015	;---	jmp		L_015
L_035
;   54:                     8:  write (' eight');
	cmp.w #8	;---	cmp		ax,8
	bne L_038	;---	jne		L_038
L_037
	psh.w #S_039	;---	lea		ax,WORD PTR S_039
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #6	;---	mov		ax,6
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_015	;---	jmp		L_015
L_038
;   55:                     9:  write (' nine');
	cmp.w #9	;---	cmp		ax,9
	bne L_041	;---	jne		L_041
L_040
	psh.w #S_042	;---	lea		ax,WORD PTR S_042
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #5	;---	mov		ax,5
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_015	;---	jmp		L_015
L_041
;   56:                 END;
L_015
;   57:             END {DoOnes};
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		4
	.ENDP	doones_013
;   58: 
;   59: 
;   60:             PROCEDURE DoTeens (teens : integer);
;   61: 
;   62:             {Translate the teens into a word,
;   63:              where 10 <= teens <= 19.}
;   64: 
;   65:             BEGIN

teens_044	.EQ	+6	;base-relative	---teens_044	EQU	<[bp+6]>

doteens_043	.PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
;   66:                 CASE teens OF
	lda.w teens_044,B	;---	mov		ax,WORD PTR teens_044
;   67:                     10:  write (' ten');
	cmp.w #10	;---	cmp		ax,10
	bne L_047	;---	jne		L_047
L_046
	psh.w #S_048	;---	lea		ax,WORD PTR S_048
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #4	;---	mov		ax,4
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_045	;---	jmp		L_045
L_047
;   68:                     11:  write (' eleven');
	cmp.w #11	;---	cmp		ax,11
	bne L_050	;---	jne		L_050
L_049
	psh.w #S_051	;---	lea		ax,WORD PTR S_051
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #7	;---	mov		ax,7
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_045	;---	jmp		L_045
L_050
;   69:                     12:  write (' twelve');
	cmp.w #12	;---	cmp		ax,12
	bne L_053	;---	jne		L_053
L_052
	psh.w #S_054	;---	lea		ax,WORD PTR S_054
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #7	;---	mov		ax,7
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_045	;---	jmp		L_045
L_053
;   70:                     13:  write (' thirteen');
	cmp.w #13	;---	cmp		ax,13
	bne L_056	;---	jne		L_056
L_055
	psh.w #S_057	;---	lea		ax,WORD PTR S_057
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #9	;---	mov		ax,9
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_045	;---	jmp		L_045
L_056
;   71:                     14:  write (' fourteen');
	cmp.w #14	;---	cmp		ax,14
	bne L_059	;---	jne		L_059
L_058
	psh.w #S_060	;---	lea		ax,WORD PTR S_060
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #9	;---	mov		ax,9
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_045	;---	jmp		L_045
L_059
;   72:                     15:  write (' fifteen');
	cmp.w #15	;---	cmp		ax,15
	bne L_062	;---	jne		L_062
L_061
	psh.w #S_063	;---	lea		ax,WORD PTR S_063
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #8	;---	mov		ax,8
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_045	;---	jmp		L_045
L_062
;   73:                     16:  write (' sixteen');
	cmp.w #16	;---	cmp		ax,16
	bne L_065	;---	jne		L_065
L_064
	psh.w #S_066	;---	lea		ax,WORD PTR S_066
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #8	;---	mov		ax,8
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_045	;---	jmp		L_045
L_065
;   74:                     17:  write (' seventeen');
	cmp.w #17	;---	cmp		ax,17
	bne L_068	;---	jne		L_068
L_067
	psh.w #S_069	;---	lea		ax,WORD PTR S_069
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #10	;---	mov		ax,10
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_045	;---	jmp		L_045
L_068
;   75:                     18:  write (' eighteen');
	cmp.w #18	;---	cmp		ax,18
	bne L_071	;---	jne		L_071
L_070
	psh.w #S_072	;---	lea		ax,WORD PTR S_072
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #9	;---	mov		ax,9
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_045	;---	jmp		L_045
L_071
;   76:                     19:  write (' nineteen');
	cmp.w #19	;---	cmp		ax,19
	bne L_074	;---	jne		L_074
L_073
	psh.w #S_075	;---	lea		ax,WORD PTR S_075
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #9	;---	mov		ax,9
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_045	;---	jmp		L_045
L_074
;   77:                 END;
L_045
;   78:             END {DoTeens};
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		4
	.ENDP	doteens_043
;   79: 
;   80: 
;   81:             PROCEDURE DoTens (digit : integer);
;   82: 
;   83:                 {Translate a single tens digit into a word,
;   84:                  where 2 <= digit <= 9.}
;   85: 
;   86:             BEGIN

digit_077	.EQ	+6	;base-relative	---digit_077	EQU	<[bp+6]>

dotens_076	.PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
;   87:                 CASE digit OF
	lda.w digit_077,B	;---	mov		ax,WORD PTR digit_077
;   88:                     2:  write (' twenty');
	cmp.w #2	;---	cmp		ax,2
	bne L_080	;---	jne		L_080
L_079
	psh.w #S_081	;---	lea		ax,WORD PTR S_081
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #7	;---	mov		ax,7
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_078	;---	jmp		L_078
L_080
;   89:                     3:  write (' thirty');
	cmp.w #3	;---	cmp		ax,3
	bne L_083	;---	jne		L_083
L_082
	psh.w #S_084	;---	lea		ax,WORD PTR S_084
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #7	;---	mov		ax,7
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_078	;---	jmp		L_078
L_083
;   90:                     4:  write (' forty');
	cmp.w #4	;---	cmp		ax,4
	bne L_086	;---	jne		L_086
L_085
	psh.w #S_087	;---	lea		ax,WORD PTR S_087
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #6	;---	mov		ax,6
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_078	;---	jmp		L_078
L_086
;   91:                     5:  write (' fifty');
	cmp.w #5	;---	cmp		ax,5
	bne L_089	;---	jne		L_089
L_088
	psh.w #S_090	;---	lea		ax,WORD PTR S_090
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #6	;---	mov		ax,6
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_078	;---	jmp		L_078
L_089
;   92:                     6:  write (' sixty');
	cmp.w #6	;---	cmp		ax,6
	bne L_092	;---	jne		L_092
L_091
	psh.w #S_093	;---	lea		ax,WORD PTR S_093
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #6	;---	mov		ax,6
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_078	;---	jmp		L_078
L_092
;   93:                     7:  write (' seventy');
	cmp.w #7	;---	cmp		ax,7
	bne L_095	;---	jne		L_095
L_094
	psh.w #S_096	;---	lea		ax,WORD PTR S_096
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #8	;---	mov		ax,8
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_078	;---	jmp		L_078
L_095
;   94:                     8:  write (' eighty');
	cmp.w #8	;---	cmp		ax,8
	bne L_098	;---	jne		L_098
L_097
	psh.w #S_099	;---	lea		ax,WORD PTR S_099
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #7	;---	mov		ax,7
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_078	;---	jmp		L_078
L_098
;   95:                     9:  write (' ninety');
	cmp.w #9	;---	cmp		ax,9
	bne L_101	;---	jne		L_101
L_100
	psh.w #S_102	;---	lea		ax,WORD PTR S_102
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #7	;---	mov		ax,7
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jmp L_078	;---	jmp		L_078
L_101
;   96:                 END;
L_078
;   97:             END {DoTens};
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		4
	.ENDP	dotens_076
;   98: 
;   99:         BEGIN {DoPart}

dopart_007	.PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
	adj #-8	;---	sub		sp,8
;  100: 
;  101:             {Break up the number part.}
;  102:             hundredsdigit := part DIV 100;
	lda.w part_008,B	;---	mov		ax,WORD PTR part_008
	pha.w	;---	push	ax
	lda #100	;---	mov		ax,100
	pha.w	;---	mov		cx,ax
						;---	pop		ax
						;---	cwd	
	jsr _idiv	;---	idiv	cx
	adj #4	;pop ops/params
	sta.w hundredsdigit_009,B	;---	mov		WORD PTR hundredsdigit_009,ax
;  103:             tenspart      := part MOD 100;
	lda.w part_008,B	;---	mov		ax,WORD PTR part_008
	pha.w	;---	push	ax
	lda #100	;---	mov		ax,100
	pha.w	;---	mov		cx,ax
						;---	pop		ax
						;---	cwd	
	jsr _idiv	;---	idiv	cx
	adj #4	;pop ops/params
	swp	;---	mov		ax,dx
	sta.w tenspart_010,B	;---	mov		WORD PTR tenspart_010,ax
;  104: 
;  105:             {Translate the hundreds digit.}
;  106:             IF hundredsdigit > 0 THEN BEGIN
	lda.w hundredsdigit_009,B	;---	mov		ax,WORD PTR hundredsdigit_009
	pha.w	;---	push	ax
	lda #0	;---	mov		ax,0
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	bgt L_105	;---	jg		L_105
	lda #0	;---	sub		ax,ax
L_105
	cmp.w #1	;---	cmp		ax,1
	beq L_103	;---	je		L_103
	jmp  L_104	;---	jmp		L_104
L_103
;  107:                 DoOnes (hundredsdigit);
	lda.w hundredsdigit_009,B	;---	mov		ax,WORD PTR hundredsdigit_009
	pha.w	;---	push	ax
	phx.w	;---	push	bp
	jsr doones_013	;---	call	doones_013
	adj #4	;pop ops/params
;  108:                 write (' hundred');
	psh.w #S_106	;---	lea		ax,WORD PTR S_106
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #8	;---	mov		ax,8
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
;  109:             END;
L_104
;  110: 
;  111:             {Translate the tens part.}
;  112:             IF  (tenspart >= 10) AND (tenspart <= 19) THEN BEGIN
	lda.w tenspart_010,B	;---	mov		ax,WORD PTR tenspart_010
	pha.w	;---	push	ax
	lda #10	;---	mov		ax,10
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	bge L_109	;---	jge		L_109
	lda #0	;---	sub		ax,ax
L_109
	pha.w	;---	push	ax
	lda.w tenspart_010,B	;---	mov		ax,WORD PTR tenspart_010
	pha.w	;---	push	ax
	lda #19	;---	mov		ax,19
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	ble L_110	;---	jle		L_110
	lda #0	;---	sub		ax,ax
L_110
						;---	pop		dx
	anl.w 0,S	;---	and		ax,dx
	adj #2	;pop ops/params
	cmp.w #1	;---	cmp		ax,1
	beq L_107	;---	je		L_107
	jmp  L_108	;---	jmp		L_108
L_107
;  113:                 DoTeens (tenspart);
	lda.w tenspart_010,B	;---	mov		ax,WORD PTR tenspart_010
	pha.w	;---	push	ax
	phx.w	;---	push	bp
	jsr doteens_043	;---	call	doteens_043
	adj #4	;pop ops/params
;  114:             END
;  115:             ELSE BEGIN
	jmp L_111	;---	jmp		L_111
L_108
;  116:                 tensdigit := tenspart DIV 10;
	lda.w tenspart_010,B	;---	mov		ax,WORD PTR tenspart_010
	pha.w	;---	push	ax
	lda #10	;---	mov		ax,10
	pha.w	;---	mov		cx,ax
						;---	pop		ax
						;---	cwd	
	jsr _idiv	;---	idiv	cx
	adj #4	;pop ops/params
	sta.w tensdigit_011,B	;---	mov		WORD PTR tensdigit_011,ax
;  117:                 onesdigit := tenspart MOD 10;
	lda.w tenspart_010,B	;---	mov		ax,WORD PTR tenspart_010
	pha.w	;---	push	ax
	lda #10	;---	mov		ax,10
	pha.w	;---	mov		cx,ax
						;---	pop		ax
						;---	cwd	
	jsr _idiv	;---	idiv	cx
	adj #4	;pop ops/params
	swp	;---	mov		ax,dx
	sta.w onesdigit_012,B	;---	mov		WORD PTR onesdigit_012,ax
;  118: 
;  119:                 IF tensdigit > 0 THEN DoTens (tensdigit);
	lda.w tensdigit_011,B	;---	mov		ax,WORD PTR tensdigit_011
	pha.w	;---	push	ax
	lda #0	;---	mov		ax,0
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	bgt L_114	;---	jg		L_114
	lda #0	;---	sub		ax,ax
L_114
	cmp.w #1	;---	cmp		ax,1
	beq L_112	;---	je		L_112
	jmp  L_113	;---	jmp		L_113
L_112
	lda.w tensdigit_011,B	;---	mov		ax,WORD PTR tensdigit_011
	pha.w	;---	push	ax
	phx.w	;---	push	bp
	jsr dotens_076	;---	call	dotens_076
	adj #4	;pop ops/params
L_113
;  120:                 IF onesdigit > 0 THEN DoOnes (onesdigit);
	lda.w onesdigit_012,B	;---	mov		ax,WORD PTR onesdigit_012
	pha.w	;---	push	ax
	lda #0	;---	mov		ax,0
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	bgt L_117	;---	jg		L_117
	lda #0	;---	sub		ax,ax
L_117
	cmp.w #1	;---	cmp		ax,1
	beq L_115	;---	je		L_115
	jmp  L_116	;---	jmp		L_116
L_115
	lda.w onesdigit_012,B	;---	mov		ax,WORD PTR onesdigit_012
	pha.w	;---	push	ax
	phx.w	;---	push	bp
	jsr doones_013	;---	call	doones_013
	adj #4	;pop ops/params
L_116
;  121:             END;
L_111
;  122:         END {DoPart};
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		4
	.ENDP	dopart_007
;  123: 
;  124:     BEGIN {Translate}

translate_003	.PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
	adj #-4	;---	sub		sp,4
;  125: 
;  126:         {Break up the number.}
;  127:         partbefore := n DIV 1000;
	lda.w n_004,B	;---	mov		ax,WORD PTR n_004
	pha.w	;---	push	ax
	lda.w #1000	;---	mov		ax,1000
	pha.w	;---	mov		cx,ax
						;---	pop		ax
						;---	cwd	
	jsr _idiv	;---	idiv	cx
	adj #4	;pop ops/params
	sta.w partbefore_005,B	;---	mov		WORD PTR partbefore_005,ax
;  128:         partafter  := n MOD 1000;
	lda.w n_004,B	;---	mov		ax,WORD PTR n_004
	pha.w	;---	push	ax
	lda.w #1000	;---	mov		ax,1000
	pha.w	;---	mov		cx,ax
						;---	pop		ax
						;---	cwd	
	jsr _idiv	;---	idiv	cx
	adj #4	;pop ops/params
	swp	;---	mov		ax,dx
	sta.w partafter_006,B	;---	mov		WORD PTR partafter_006,ax
;  129: 
;  130:         IF partbefore > 0 THEN BEGIN
	lda.w partbefore_005,B	;---	mov		ax,WORD PTR partbefore_005
	pha.w	;---	push	ax
	lda #0	;---	mov		ax,0
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	bgt L_120	;---	jg		L_120
	lda #0	;---	sub		ax,ax
L_120
	cmp.w #1	;---	cmp		ax,1
	beq L_118	;---	je		L_118
	jmp  L_119	;---	jmp		L_119
L_118
;  131:             DoPart (partbefore);
	lda.w partbefore_005,B	;---	mov		ax,WORD PTR partbefore_005
	pha.w	;---	push	ax
	phx.w	;---	push	bp
	jsr dopart_007	;---	call	dopart_007
	adj #4	;pop ops/params
;  132:             write (' thousand');
	psh.w #S_121	;---	lea		ax,WORD PTR S_121
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #9	;---	mov		ax,9
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
;  133:         END;
L_119
;  134: 
;  135:         IF partafter > 0 THEN DoPart (partafter);
	lda.w partafter_006,B	;---	mov		ax,WORD PTR partafter_006
	pha.w	;---	push	ax
	lda #0	;---	mov		ax,0
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	bgt L_124	;---	jg		L_124
	lda #0	;---	sub		ax,ax
L_124
	cmp.w #1	;---	cmp		ax,1
	beq L_122	;---	je		L_122
	jmp  L_123	;---	jmp		L_123
L_122
	lda.w partafter_006,B	;---	mov		ax,WORD PTR partafter_006
	pha.w	;---	push	ax
	phx.w	;---	push	bp
	jsr dopart_007	;---	call	dopart_007
	adj #4	;pop ops/params
L_123
;  136:     END {Translate};
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		4
	.ENDP	translate_003
;  137: 
;  138: 
;  139: BEGIN {NumberTranslator}

_pc65_main	.PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
;  140: 
;  141:     {Loop to read, write, check, and translate the numbers.}
;  142:     REPEAT
L_125
;  143:         read (number);
	psh.w #number_002	;---	lea		ax,WORD PTR number_002
	jsr _iread	;---	call	_read_integer
					;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;pop ops/params
;  144:         write (number:6, ' :');
	lda.w number_002	;---	mov		ax,WORD PTR number_002
	pha.w	;---	push	ax
	lda #6	;---	mov		ax,6
	pha.w	;---	push	ax
	jsr _iwrite	;---	call	_write_integer
	adj #4	;---	add		sp,4
	psh.w #S_127	;---	lea		ax,WORD PTR S_127
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #2	;---	mov		ax,2
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
;  145: 
;  146:         IF number < 0 THEN BEGIN
	lda.w number_002	;---	mov		ax,WORD PTR number_002
	pha.w	;---	push	ax
	lda #0	;---	mov		ax,0
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	blt L_130	;---	jl		L_130
	lda #0	;---	sub		ax,ax
L_130
	cmp.w #1	;---	cmp		ax,1
	beq L_128	;---	je		L_128
	jmp  L_129	;---	jmp		L_129
L_128
;  147:             write (' ***** Error -- number < 0');
	psh.w #S_131	;---	lea		ax,WORD PTR S_131
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #26	;---	mov		ax,26
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
;  148:         END
;  149:         ELSE IF number > maxnumber THEN BEGIN
	jmp L_132	;---	jmp		L_132
L_129
	lda.w number_002	;---	mov		ax,WORD PTR number_002
	pha.w	;---	push	ax
	lda.w #30000	;---	mov		ax,30000
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	bgt L_135	;---	jg		L_135
	lda #0	;---	sub		ax,ax
L_135
	cmp.w #1	;---	cmp		ax,1
	beq L_133	;---	je		L_133
	jmp  L_134	;---	jmp		L_134
L_133
;  150:             write (' ***** Error -- number > ', maxnumber:1);
	psh.w #S_136	;---	lea		ax,WORD PTR S_136
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #25	;---	mov		ax,25
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	lda.w #30000	;---	mov		ax,30000
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
	pha.w	;---	push	ax
	jsr _iwrite	;---	call	_write_integer
	adj #4	;---	add		sp,4
;  151:         END
;  152:         ELSE IF number = 0 THEN BEGIN
	jmp L_137	;---	jmp		L_137
L_134
	lda.w number_002	;---	mov		ax,WORD PTR number_002
	pha.w	;---	push	ax
	lda #0	;---	mov		ax,0
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_140	;---	je		L_140
	lda #0	;---	sub		ax,ax
L_140
	cmp.w #1	;---	cmp		ax,1
	beq L_138	;---	je		L_138
	jmp  L_139	;---	jmp		L_139
L_138
;  153:             write (' zero');
	psh.w #S_141	;---	lea		ax,WORD PTR S_141
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #5	;---	mov		ax,5
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
;  154:         END
;  155:         ELSE BEGIN
	jmp L_142	;---	jmp		L_142
L_139
;  156:             Translate (number);
	lda.w number_002	;---	mov		ax,WORD PTR number_002
	pha.w	;---	push	ax
	phx.w	;---	push	bp
	jsr translate_003	;---	call	translate_003
	adj #4	;pop ops/params
;  157:         END;
L_142
L_137
L_132
;  158: 
;  159:         writeln;  {complete output line}
	jsr _writeln	;---	call	_write_line
;  160:     UNTIL number = terminator;
	lda.w number_002	;---	mov		ax,WORD PTR number_002
	pha.w	;---	push	ax
	lda #0	;---	mov		ax,0
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_143	;---	je		L_143
	lda #0	;---	sub		ax,ax
L_143
	cmp.w #1	;---	cmp		ax,1
	beq L_126	;---	je		L_126
	jmp L_125	;---	jmp		L_125
L_126
;  161: END {NumberTranslator}.

	plx.w	;---	pop		bp
	rts	;---	ret	

	.ENDP	_pc65_main

	.DATA	;place in DATA segment

number_002	.DB	2	;define integer
S_141	.DS	" zero"	;string literal absolute
S_136	.DS	" ***** Error -- number > "	;string literal absolute
S_131	.DS	" ***** Error -- number < 0"	;string literal absolute
S_127	.DS	" :"	;string literal absolute
S_121	.DS	" thousand"	;string literal absolute
S_106	.DS	" hundred"	;string literal absolute
S_102	.DS	" ninety"	;string literal absolute
S_099	.DS	" eighty"	;string literal absolute
S_096	.DS	" seventy"	;string literal absolute
S_093	.DS	" sixty"	;string literal absolute
S_090	.DS	" fifty"	;string literal absolute
S_087	.DS	" forty"	;string literal absolute
S_084	.DS	" thirty"	;string literal absolute
S_081	.DS	" twenty"	;string literal absolute
S_075	.DS	" nineteen"	;string literal absolute
S_072	.DS	" eighteen"	;string literal absolute
S_069	.DS	" seventeen"	;string literal absolute
S_066	.DS	" sixteen"	;string literal absolute
S_063	.DS	" fifteen"	;string literal absolute
S_060	.DS	" fourteen"	;string literal absolute
S_057	.DS	" thirteen"	;string literal absolute
S_054	.DS	" twelve"	;string literal absolute
S_051	.DS	" eleven"	;string literal absolute
S_048	.DS	" ten"	;string literal absolute
S_042	.DS	" nine"	;string literal absolute
S_039	.DS	" eight"	;string literal absolute
S_036	.DS	" seven"	;string literal absolute
S_033	.DS	" six"	;string literal absolute
S_030	.DS	" five"	;string literal absolute
S_027	.DS	" four"	;string literal absolute
S_024	.DS	" three"	;string literal absolute
S_021	.DS	" two"	;string literal absolute
S_018	.DS	" one"	;string literal absolute

	.END
