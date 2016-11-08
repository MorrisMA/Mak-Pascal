;    1: PROGRAM xref (input, output);
	.STACK  1024	;Set stack size

	.CODE	;place in CODE segment

STATIC_LINK			.EQ	+4	;--- base-relative STATIC_LINK			EQU	<WORD PTR [bp+4]>
RETURN_VALUE		.EQ	-4	;--- base-relativeRETURN_VALUE		EQU	<WORD PTR [bp-4]>
HIGH_RETURN_VALUE	.EQ	-2	;--- base-relative HIGH_RETURN_VALUE	EQU	<WORD PTR [bp-2]>

;    2: 
;    3:     {Generate a cross-reference listing from a text file.}
;    4: 
;    5: CONST
;    6:     maxwordlen       =   20;
;    7:     wordtablesize    =  500;
;    8:     numbertablesize  = 1000;
;    9:     maxlinenumber    =  999;
;   10: 
;   11: TYPE
;   12:     charindex        = 1..maxwordlen;
;   13:     wordtableindex   = 1..wordtablesize;
;   14:     numbertableindex = 0..numbertablesize;
;   15:     linenumbertype   = 1..maxlinenumber;
;   16: 
;   17:     wordtype         = ARRAY [charindex] OF char;  {string type}
;   18: 
;   19:     wordentrytype    = RECORD  {entry in word table}
;   20:                word : wordtype; {word string}
word_002	.EQ	+0	;numeric literal absolute	---word_002	EQU	+0
;   21:                firstnumberindex,    {head and tail of    }
;   22:                lastnumberindex      {  linked number list}
;   23:                    : numbertableindex;
firstnumberindex_003	.EQ	+20	;numeric literal absolute	---firstnumberindex_003	EQU	+20
lastnumberindex_004	.EQ	+22	;numeric literal absolute	---lastnumberindex_004	EQU	+22
;   24:                END;
;   25: 
;   26:     numberentrytype  = RECORD  {entry in number table}
;   27:                number                   {line number}
;   28:                    : linenumbertype;
number_005	.EQ	+0	;numeric literal absolute	---number_005	EQU	+0
;   29:                nextindex                {index of next   }
;   30:                    : numbertableindex;  {  in linked list}
nextindex_006	.EQ	+2	;numeric literal absolute	---nextindex_006	EQU	+2
;   31:                END;
;   32: 
;   33:     wordtabletype    = ARRAY [wordtableindex]   OF wordentrytype;
;   34:     numbertabletype  = ARRAY [numbertableindex] OF numberentrytype;
;   35: 
;   36: VAR
;   37:     wordtable                      : wordtabletype;
;   38:     numbertable                    : numbertabletype;
;   39:     nextwordindex              : wordtableindex;
;   40:     nextnumberindex                : numbertableindex;
;   41:     linenumber                     : linenumbertype;
;   42:     wordtablefull, numbertablefull : boolean;
;   43:     newline, gotword               : boolean;
;   44: 
;   45: 
;   46: FUNCTION nextchar : char;
;   47: 
;   48:     {Fetch and echo the next character.
;   49:      Print the line number before each new line.}
;   50: 
;   51:     CONST
;   52:     blank = ' ';
;   53: 
;   54:     VAR
;   55:     ch : char;
;   56: 
;   57:     BEGIN

ch_017	.EQ	-6	;base-relative	---ch_017	EQU	<[bp-6]>

nextchar_016	.PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
	adj #-4	;---	sub		sp,4
	adj #-2	;---	sub		sp,2
;   58:     newline := eoln;
	jsr _eol	;---	call	_std_end_of_line
	sta.w newline_014	;---	mov		WORD PTR newline_014,ax
;   59:     IF newline THEN BEGIN
	lda.w newline_014	;---	mov		ax,WORD PTR newline_014
	cmp.w #1	;---	cmp		ax,1
	beq L_018	;---	je		L_018
	jmp  L_019	;---	jmp		L_019
L_018
;   60:         readln;
	jsr _readln	;---	call	_read_line
;   61:         writeln;
	jsr _writeln	;---	call	_write_line
;   62:         linenumber := linenumber + 1;
	lda.w linenumber_011	;---	mov		ax,WORD PTR linenumber_011
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
	sta.w linenumber_011	;---	mov		WORD PTR linenumber_011,ax
;   63:         write(linenumber:5, ' : ');
	lda.w linenumber_011	;---	mov		ax,WORD PTR linenumber_011
	pha.w	;---	push	ax
	lda #5	;---	mov		ax,5
	pha.w	;---	push	ax
	jsr _iwrite	;---	call	_write_integer
	adj #4	;---	add		sp,4
	psh.w #S_020	;---	lea		ax,WORD PTR S_020
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #3	;---	mov		ax,3
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
;   64:     END;
L_019
;   65:     IF newline OR eof THEN BEGIN
	lda.w newline_014	;---	mov		ax,WORD PTR newline_014
	pha.w	;---	push	ax
	jsr _eof	;---	call	_std_end_of_file
						;---	pop		dx
	ora.w 0,S	;---	or		ax,dx
	adj #2	;pop ops/params
	cmp.w #1	;---	cmp		ax,1
	beq L_021	;---	je		L_021
	jmp  L_022	;---	jmp		L_022
L_021
;   66:         ch := blank;
	lda #' '	;---	mov		ax,' '
	sta ch_017	;---	mov		BYTE PTR ch_017,al
;   67:     END
;   68:     ELSE BEGIN
	jmp L_023	;---	jmp		L_023
L_022
;   69:         read(ch);
	txa.w	;---	lea		ax,WORD PTR ch_017
	sec	;compensate for BP/SP offset
	adc.w #ch_017	compute effective address
	pha.w	;---	push	ax
	jsr _cread	;---	call	_read_char
					;---	pop		bx
	sta (0,S)	;store byte---	mov		BYTE PTR [bx],al
	adj #2	;pop ops/params
;   70:         write(ch);
					;---	sub		ax,ax
	lda ch_017,B	;---	mov		al,BYTE PTR ch_017
	pha.w	;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	jsr _cwrite	;---	call	_write_char
	adj #4	;---	add		sp,4
;   71:     END;
L_023
;   72:     nextchar := ch;
					;---	sub		ax,ax
	lda ch_017,B	;---	mov		al,BYTE PTR ch_017
	tay	;---	sub		bx,bx
	tya	;---	mov		ah,bh
	sta.w RETURN_VALUE,B	;---	mov		RETURN_VALUE,ax
;   73:     END;
	lda.w RETURN_VALUE,B	;---	mov		ax,RETURN_VALUE
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		2
	.ENDP	nextchar_016
;   74: 
;   75: 
;   76: FUNCTION isletter (ch : char) : boolean;
;   77: 
;   78:     {Return true if the character is a letter, false otherwise.}
;   79: 
;   80:     BEGIN

ch_025	.EQ	+6	;base-relative	---ch_025	EQU	<[bp+6]>

isletter_024	.PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
	adj #-4	;---	sub		sp,4
;   81:     isletter :=    ((ch >= 'a') AND (ch <= 'z'))
					;---	sub		ax,ax
	lda ch_025,B	;---	mov		al,BYTE PTR ch_025
	pha.w	;---	push	ax
	lda #97	;---	mov		ax,'a'
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	bge L_026	;---	jge		L_026
	lda #0	;---	sub		ax,ax
L_026
	pha.w	;---	push	ax
					;---	sub		ax,ax
	lda ch_025,B	;---	mov		al,BYTE PTR ch_025
	pha.w	;---	push	ax
	lda #122	;---	mov		ax,'z'
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	ble L_027	;---	jle		L_027
	lda #0	;---	sub		ax,ax
L_027
						;---	pop		dx
	anl.w 0,S	;---	and		ax,dx
	adj #2	;pop ops/params
;   82:             OR ((ch >= 'A') AND (ch <= 'Z'));
	pha.w	;---	push	ax
					;---	sub		ax,ax
	lda ch_025,B	;---	mov		al,BYTE PTR ch_025
	pha.w	;---	push	ax
	lda #65	;---	mov		ax,'A'
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	bge L_028	;---	jge		L_028
	lda #0	;---	sub		ax,ax
L_028
	pha.w	;---	push	ax
					;---	sub		ax,ax
	lda ch_025,B	;---	mov		al,BYTE PTR ch_025
	pha.w	;---	push	ax
	lda #90	;---	mov		ax,'Z'
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	ble L_029	;---	jle		L_029
	lda #0	;---	sub		ax,ax
L_029
						;---	pop		dx
	anl.w 0,S	;---	and		ax,dx
	adj #2	;pop ops/params
						;---	pop		dx
	ora.w 0,S	;---	or		ax,dx
	adj #2	;pop ops/params
	sta.w RETURN_VALUE,B	;---	mov		RETURN_VALUE,ax
;   83:     END;
	lda.w RETURN_VALUE,B	;---	mov		ax,RETURN_VALUE
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		4
	.ENDP	isletter_024
;   84: 
;   85: 
;   86: PROCEDURE readword (VAR buffer : wordtype);
;   87: 
;   88:     {Extract the next word and place it into the buffer.}
;   89: 
;   90:     CONST
;   91:     blank = ' ';
;   92: 
;   93:     VAR
;   94:     charcount : 0..maxwordlen;
;   95:     ch : char;
;   96: 
;   97:     BEGIN

buffer_031	.EQ	+6	;base-relative	---buffer_031	EQU	<[bp+6]>
charcount_032	.EQ	-2	;base-relative	---charcount_032	EQU	<[bp-2]>
ch_033	.EQ	-4	;base-relative	---ch_033	EQU	<[bp-4]>

readword_030	.PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
	adj #-4	;---	sub		sp,4
;   98:     gotword := false;
	lda #0	;---	mov		ax,0
	sta.w gotword_015	;---	mov		WORD PTR gotword_015,ax
;   99: 
;  100:     {Skip over any preceding non-letters.}
;  101:     IF NOT eof THEN BEGIN
	jsr _eof	;---	call	_std_end_of_file
	eor #1	;---	xor		ax,1
	cmp.w #1	;---	cmp		ax,1
	beq L_034	;---	je		L_034
	jmp  L_035	;---	jmp		L_035
L_034
;  102:         REPEAT
L_036
;  103:         ch := nextchar;
	lda.w STATIC_LINK,B	;---	push	STATIC_LINK
	pha.w	;push acc
	jsr nextchar_016	;---	call	nextchar_016
	adj #2	;pop ops/params
	sta ch_033	;---	mov		BYTE PTR ch_033,al
;  104:         UNTIL eof OR isletter(ch);
	jsr _eof	;---	call	_std_end_of_file
	pha.w	;---	push	ax
					;---	sub		ax,ax
	lda ch_033,B	;---	mov		al,BYTE PTR ch_033
	pha.w	;---	push	ax
	lda.w STATIC_LINK,B	;---	push	STATIC_LINK
	pha.w	;push acc
	jsr isletter_024	;---	call	isletter_024
	adj #4	;pop ops/params
						;---	pop		dx
	ora.w 0,S	;---	or		ax,dx
	adj #2	;pop ops/params
	cmp.w #1	;---	cmp		ax,1
	beq L_037	;---	je		L_037
	jmp L_036	;---	jmp		L_036
L_037
;  105:     END;
L_035
;  106: 
;  107:     {Find a letter?}
;  108:     IF NOT eof THEN BEGIN
	jsr _eof	;---	call	_std_end_of_file
	eor #1	;---	xor		ax,1
	cmp.w #1	;---	cmp		ax,1
	beq L_038	;---	je		L_038
	jmp  L_039	;---	jmp		L_039
L_038
;  109:         charcount := 0;
	lda #0	;---	mov		ax,0
	sta.w charcount_032,B	;---	mov		WORD PTR charcount_032,ax
;  110: 
;  111:         {Place the word's letters into the buffer.
;  112:          Downshift uppercase letters.}
;  113:         WHILE isletter(ch) DO BEGIN
L_040
					;---	sub		ax,ax
	lda ch_033,B	;---	mov		al,BYTE PTR ch_033
	pha.w	;---	push	ax
	lda.w STATIC_LINK,B	;---	push	STATIC_LINK
	pha.w	;push acc
	jsr isletter_024	;---	call	isletter_024
	adj #4	;pop ops/params
	cmp.w #1	;---	cmp		ax,1
	beq L_041	;---	je		L_041
	jmp L_042	;---	jmp		L_042
L_041
;  114:         IF charcount < maxwordlen THEN BEGIN
	lda.w charcount_032,B	;---	mov		ax,WORD PTR charcount_032
	pha.w	;---	push	ax
	lda #20	;---	mov		ax,20
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	blt L_045	;---	jl		L_045
	lda #0	;---	sub		ax,ax
L_045
	cmp.w #1	;---	cmp		ax,1
	beq L_043	;---	je		L_043
	jmp  L_044	;---	jmp		L_044
L_043
;  115:             IF (ch >= 'A') AND (ch <= 'Z') THEN BEGIN
					;---	sub		ax,ax
	lda ch_033,B	;---	mov		al,BYTE PTR ch_033
	pha.w	;---	push	ax
	lda #65	;---	mov		ax,'A'
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	bge L_048	;---	jge		L_048
	lda #0	;---	sub		ax,ax
L_048
	pha.w	;---	push	ax
					;---	sub		ax,ax
	lda ch_033,B	;---	mov		al,BYTE PTR ch_033
	pha.w	;---	push	ax
	lda #90	;---	mov		ax,'Z'
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	ble L_049	;---	jle		L_049
	lda #0	;---	sub		ax,ax
L_049
						;---	pop		dx
	anl.w 0,S	;---	and		ax,dx
	adj #2	;pop ops/params
	cmp.w #1	;---	cmp		ax,1
	beq L_046	;---	je		L_046
	jmp  L_047	;---	jmp		L_047
L_046
;  116:             ch := chr(ord(ch) + (ord('a') - ord('A')));
					;---	sub		ax,ax
	lda ch_033,B	;---	mov		al,BYTE PTR ch_033
	pha.w	;---	push	ax
	lda #97	;---	mov		ax,'a'
	pha.w	;---	push	ax
	lda #65	;---	mov		ax,'A'
						;---	pop		dx
	xma.w 0,S	;---	sub		dx,ax
	sec	;prepare to subtract
	sbc.w 0,S	;subtract operands
	adj #2	;pop ops/params
						;---	mov		ax,dx
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
	sta ch_033	;---	mov		BYTE PTR ch_033,al
;  117:             END;
L_047
;  118:             charcount := charcount + 1;
	lda.w charcount_032,B	;---	mov		ax,WORD PTR charcount_032
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
	sta.w charcount_032,B	;---	mov		WORD PTR charcount_032,ax
;  119:             buffer[charcount] := ch;
	lda.w buffer_031,B	;---	mov		ax,WORD PTR buffer_031
	pha.w	;---	push	ax
	lda.w charcount_032,B	;---	mov		ax,WORD PTR charcount_032
	dec.w a	;---	sub		ax,1
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
					;---	sub		ax,ax
	lda ch_033,B	;---	mov		al,BYTE PTR ch_033
						;---	pop		bx
	sta (0,S)	;---	mov		BYTE PTR [bx],al
	adj #2	;--- pop TOS
;  120:         END;
L_044
;  121:         ch := nextchar;
	lda.w STATIC_LINK,B	;---	push	STATIC_LINK
	pha.w	;push acc
	jsr nextchar_016	;---	call	nextchar_016
	adj #2	;pop ops/params
	sta ch_033	;---	mov		BYTE PTR ch_033,al
;  122:         END;
	jmp L_040	;---	jmp		L_040
L_042
;  123: 
;  124:         {Pad the rest of the buffer with blanks.}
;  125:         FOR charcount := charcount + 1 TO maxwordlen DO BEGIN
	lda.w charcount_032,B	;---	mov		ax,WORD PTR charcount_032
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
	sta.w charcount_032,B	;---	mov		WORD PTR charcount_032,ax
L_050
	lda #20	;---	mov		ax,20
	cmp.w charcount_032,B	;---	cmp		WORD PTR charcount_032,ax
	bge L_051	;---	jle		L_051
	jmp L_052	;---	jmp		L_052
L_051
;  126:         buffer[charcount] := blank;
	lda.w buffer_031,B	;---	mov		ax,WORD PTR buffer_031
	pha.w	;---	push	ax
	lda.w charcount_032,B	;---	mov		ax,WORD PTR charcount_032
	dec.w a	;---	sub		ax,1
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #' '	;---	mov		ax,' '
						;---	pop		bx
	sta (0,S)	;---	mov		BYTE PTR [bx],al
	adj #2	;--- pop TOS
;  127:         END;
	inc.w charcount_032,B	;---	inc		WORD PTR charcount_032
	jmp L_050	;---	jmp		L_050
L_052
	dec.w charcount_032,B	;---	dec		WORD PTR charcount_032
;  128: 
;  129:         gotword := true;
	lda #1	;---	mov		ax,1
	sta.w gotword_015	;---	mov		WORD PTR gotword_015,ax
;  130:     END;
L_039
;  131:     END;
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		4
	.ENDP	readword_030
;  132: 
;  133: 
;  134: FUNCTION appendlinenumber(lastnumberindex : numbertableindex)
;  135:          : numbertableindex;
;  136: 
;  137:     {Append the current line number to the end of the current word's
;  138:      linked list.  Lastnumberindex is 0 if this is the word's first
;  139:      number; else, it is the index of the last number in the list.}
;  140: 
;  141:     BEGIN

lastnumberindex_054	.EQ	+6	;base-relative	---lastnumberindex_054	EQU	<[bp+6]>

appendlinenumber_053	.PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
	adj #-4	;---	sub		sp,4
;  142:         IF nextnumberindex < numbertablesize THEN BEGIN
	lda.w nextnumberindex_010	;---	mov		ax,WORD PTR nextnumberindex_010
	pha.w	;---	push	ax
	lda.w #1000	;---	mov		ax,1000
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	blt L_057	;---	jl		L_057
	lda #0	;---	sub		ax,ax
L_057
	cmp.w #1	;---	cmp		ax,1
	beq L_055	;---	je		L_055
	jmp  L_056	;---	jmp		L_056
L_055
;  143:         IF lastnumberindex <> 0 THEN BEGIN
	lda.w lastnumberindex_054,B	;---	mov		ax,WORD PTR lastnumberindex_054
	pha.w	;---	push	ax
	lda #0	;---	mov		ax,0
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	bne L_060	;---	jne		L_060
	lda #0	;---	sub		ax,ax
L_060
	cmp.w #1	;---	cmp		ax,1
	beq L_058	;---	je		L_058
	jmp  L_059	;---	jmp		L_059
L_058
;  144:             numbertable[lastnumberindex].nextindex := nextnumberindex;
	psh.w #numbertable_008	;---	lea		ax,WORD PTR numbertable_008
	lda.w lastnumberindex_054,B	;---	mov		ax,WORD PTR lastnumberindex_054
						;---	mov		dx,4
						;---	imul	dx
	asl.w a	;arithmetic shift
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	pla.w	;---	pop		ax
	clc	;---	add		ax,nextindex_006
	adc.w #nextindex_006	;compute field offset
	pha.w	;---	push	ax
	lda.w nextnumberindex_010	;---	mov		ax,WORD PTR nextnumberindex_010
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  145:         END;
L_059
;  146:         numbertable[nextnumberindex].number    := linenumber;
	psh.w #numbertable_008	;---	lea		ax,WORD PTR numbertable_008
	lda.w nextnumberindex_010	;---	mov		ax,WORD PTR nextnumberindex_010
						;---	mov		dx,4
						;---	imul	dx
	asl.w a	;arithmetic shift
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	pla.w	;---	pop		ax
	clc	;---	add		ax,number_005
	adc.w #number_005	;compute field offset
	pha.w	;---	push	ax
	lda.w linenumber_011	;---	mov		ax,WORD PTR linenumber_011
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  147:         numbertable[nextnumberindex].nextindex := 0;
	psh.w #numbertable_008	;---	lea		ax,WORD PTR numbertable_008
	lda.w nextnumberindex_010	;---	mov		ax,WORD PTR nextnumberindex_010
						;---	mov		dx,4
						;---	imul	dx
	asl.w a	;arithmetic shift
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	pla.w	;---	pop		ax
	clc	;---	add		ax,nextindex_006
	adc.w #nextindex_006	;compute field offset
	pha.w	;---	push	ax
	lda #0	;---	mov		ax,0
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  148:         appendlinenumber := nextnumberindex;
	lda.w nextnumberindex_010	;---	mov		ax,WORD PTR nextnumberindex_010
	sta.w RETURN_VALUE,B	;---	mov		RETURN_VALUE,ax
;  149:         nextnumberindex  := nextnumberindex + 1;
	lda.w nextnumberindex_010	;---	mov		ax,WORD PTR nextnumberindex_010
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
	sta.w nextnumberindex_010	;---	mov		WORD PTR nextnumberindex_010,ax
;  150:         END
;  151:         ELSE BEGIN
	jmp L_061	;---	jmp		L_061
L_056
;  152:             numbertablefull  := true;
	lda #1	;---	mov		ax,1
	sta.w numbertablefull_013	;---	mov		WORD PTR numbertablefull_013,ax
;  153:             appendlinenumber := 0;
	lda #0	;---	mov		ax,0
	sta.w RETURN_VALUE,B	;---	mov		RETURN_VALUE,ax
;  154:         END;
L_061
;  155:     END;
	lda.w RETURN_VALUE,B	;---	mov		ax,RETURN_VALUE
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		4
	.ENDP	appendlinenumber_053
;  156: 
;  157: 
;  158: PROCEDURE enterword;
;  159: 
;  160:     {Enter the current word into the word table.  Each word is first
;  161:      read into the end of the table.}
;  162: 
;  163:     VAR
;  164:     i : wordtableindex;
;  165: 
;  166:     BEGIN

i_063	.EQ	-2	;base-relative	---i_063	EQU	<[bp-2]>

enterword_062	.PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
	adj #-2	;---	sub		sp,2
;  167:     {By the time we process a word at the end of an input line,
;  168:      linenumber has already been incremented, so temporarily
;  169:      decrement it.}
;  170:     IF newline THEN linenumber := linenumber - 1;
	lda.w newline_014	;---	mov		ax,WORD PTR newline_014
	cmp.w #1	;---	cmp		ax,1
	beq L_064	;---	je		L_064
	jmp  L_065	;---	jmp		L_065
L_064
	lda.w linenumber_011	;---	mov		ax,WORD PTR linenumber_011
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	xma.w 0,S	;---	sub		dx,ax
	sec	;prepare to subtract
	sbc.w 0,S	;subtract operands
	adj #2	;pop ops/params
						;---	mov		ax,dx
	sta.w linenumber_011	;---	mov		WORD PTR linenumber_011,ax
L_065
;  171: 
;  172:     {Search to see if the word has previously been entered.}
;  173:     i := 1;
	lda #1	;---	mov		ax,1
	sta.w i_063,B	;---	mov		WORD PTR i_063,ax
;  174:     WHILE    wordtable[i].word
L_066
	psh.w #wordtable_007	;---	lea		ax,WORD PTR wordtable_007
	lda.w i_063,B	;---	mov		ax,WORD PTR i_063
	dec.w a	;---	sub		ax,1
						;---	mov		dx,24
						;---	imul	dx
	pha.w	;push index
	psh.w #24	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
;  175:           <> wordtable[nextwordindex].word DO BEGIN
	pla.w	;---	pop		ax
	clc	;---	add		ax,word_002
	adc.w #word_002	;compute field offset
	pha.w	;---	push	ax
	psh.w #wordtable_007	;---	lea		ax,WORD PTR wordtable_007
	lda.w nextwordindex_009	;---	mov		ax,WORD PTR nextwordindex_009
	dec.w a	;---	sub		ax,1
						;---	mov		dx,24
						;---	imul	dx
	pha.w	;push index
	psh.w #24	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	pla.w	;---	pop		ax
	clc	;---	add		ax,word_002
	adc.w #word_002	;compute field offset
	pha.w	;---	push	ax
						;---	cld
	psh.w #20	;---	mov		cx,20
						;---	pop		di
						;---	pop		si
						;---	mov		ax,ds
						;---	mov		es,ax
	jsr _cmpsb	;---	repe	cmpsb
	adj #+6	; remove parameters
	php	;---	mov		ax,1
	lda #1	;load integer literal
	plp	;pull PSW
	bne L_069	;---	jne		L_069
	lda #0	;---	sub		ax,ax
L_069
	cmp.w #1	;---	cmp		ax,1
	beq L_067	;---	je		L_067
	jmp L_068	;---	jmp		L_068
L_067
;  176:         i := i + 1;
	lda.w i_063,B	;---	mov		ax,WORD PTR i_063
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
	sta.w i_063,B	;---	mov		WORD PTR i_063,ax
;  177:     END;
	jmp L_066	;---	jmp		L_066
L_068
;  178: 
;  179:     {Yes.  Update the previous entry.}
;  180:     IF i < nextwordindex THEN BEGIN
	lda.w i_063,B	;---	mov		ax,WORD PTR i_063
	pha.w	;---	push	ax
	lda.w nextwordindex_009	;---	mov		ax,WORD PTR nextwordindex_009
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	blt L_072	;---	jl		L_072
	lda #0	;---	sub		ax,ax
L_072
	cmp.w #1	;---	cmp		ax,1
	beq L_070	;---	je		L_070
	jmp  L_071	;---	jmp		L_071
L_070
;  181:         wordtable[i].lastnumberindex :=
	psh.w #wordtable_007	;---	lea		ax,WORD PTR wordtable_007
	lda.w i_063,B	;---	mov		ax,WORD PTR i_063
	dec.w a	;---	sub		ax,1
						;---	mov		dx,24
						;---	imul	dx
	pha.w	;push index
	psh.w #24	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	pla.w	;---	pop		ax
	clc	;---	add		ax,lastnumberindex_004
	adc.w #lastnumberindex_004	;compute field offset
	pha.w	;---	push	ax
;  182:         appendlinenumber(wordtable[i].lastnumberindex);
	psh.w #wordtable_007	;---	lea		ax,WORD PTR wordtable_007
	lda.w i_063,B	;---	mov		ax,WORD PTR i_063
	dec.w a	;---	sub		ax,1
						;---	mov		dx,24
						;---	imul	dx
	pha.w	;push index
	psh.w #24	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	pla.w	;---	pop		ax
	clc	;---	add		ax,lastnumberindex_004
	adc.w #lastnumberindex_004	;compute field offset
	pha.w	;---	push	ax
						;---	pop		bx
	lda.w (0,S)	;---	mov		ax,WORD PTR [bx]
	adj #2	;pop ops/params
	pha.w	;---	push	ax
	lda.w STATIC_LINK,B	;---	push	STATIC_LINK
	pha.w	;push acc
	jsr appendlinenumber_053	;---	call	appendlinenumber_053
	adj #4	;pop ops/params
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  183:     END
;  184: 
;  185:     {No.  Initialize the entry at the end of the table.}
;  186:     ELSE IF nextwordindex < wordtablesize THEN BEGIN
	jmp L_073	;---	jmp		L_073
L_071
	lda.w nextwordindex_009	;---	mov		ax,WORD PTR nextwordindex_009
	pha.w	;---	push	ax
	lda.w #500	;---	mov		ax,500
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	blt L_076	;---	jl		L_076
	lda #0	;---	sub		ax,ax
L_076
	cmp.w #1	;---	cmp		ax,1
	beq L_074	;---	je		L_074
	jmp  L_075	;---	jmp		L_075
L_074
;  187:         nextwordindex := nextwordindex + 1;
	lda.w nextwordindex_009	;---	mov		ax,WORD PTR nextwordindex_009
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
	sta.w nextwordindex_009	;---	mov		WORD PTR nextwordindex_009,ax
;  188:         wordtable[i].firstnumberindex := appendlinenumber(0);
	psh.w #wordtable_007	;---	lea		ax,WORD PTR wordtable_007
	lda.w i_063,B	;---	mov		ax,WORD PTR i_063
	dec.w a	;---	sub		ax,1
						;---	mov		dx,24
						;---	imul	dx
	pha.w	;push index
	psh.w #24	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	pla.w	;---	pop		ax
	clc	;---	add		ax,firstnumberindex_003
	adc.w #firstnumberindex_003	;compute field offset
	pha.w	;---	push	ax
	lda #0	;---	mov		ax,0
	pha.w	;---	push	ax
	lda.w STATIC_LINK,B	;---	push	STATIC_LINK
	pha.w	;push acc
	jsr appendlinenumber_053	;---	call	appendlinenumber_053
	adj #4	;pop ops/params
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  189:         wordtable[i].lastnumberindex :=
	psh.w #wordtable_007	;---	lea		ax,WORD PTR wordtable_007
	lda.w i_063,B	;---	mov		ax,WORD PTR i_063
	dec.w a	;---	sub		ax,1
						;---	mov		dx,24
						;---	imul	dx
	pha.w	;push index
	psh.w #24	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	pla.w	;---	pop		ax
	clc	;---	add		ax,lastnumberindex_004
	adc.w #lastnumberindex_004	;compute field offset
	pha.w	;---	push	ax
;  190:         wordtable[i].firstnumberindex;
	psh.w #wordtable_007	;---	lea		ax,WORD PTR wordtable_007
	lda.w i_063,B	;---	mov		ax,WORD PTR i_063
	dec.w a	;---	sub		ax,1
						;---	mov		dx,24
						;---	imul	dx
	pha.w	;push index
	psh.w #24	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	pla.w	;---	pop		ax
	clc	;---	add		ax,firstnumberindex_003
	adc.w #firstnumberindex_003	;compute field offset
	pha.w	;---	push	ax
						;---	pop		bx
	lda.w (0,S)	;---	mov		ax,WORD PTR [bx]
	adj #2	;pop ops/params
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  191:     END
;  192: 
;  193:     {Oops.  Table overflow!}
;  194:     ELSE wordtablefull := true;
	jmp L_077	;---	jmp		L_077
L_075
	lda #1	;---	mov		ax,1
	sta.w wordtablefull_012	;---	mov		WORD PTR wordtablefull_012,ax
L_077
L_073
;  195: 
;  196:     IF newline THEN linenumber := linenumber + 1;
	lda.w newline_014	;---	mov		ax,WORD PTR newline_014
	cmp.w #1	;---	cmp		ax,1
	beq L_078	;---	je		L_078
	jmp  L_079	;---	jmp		L_079
L_078
	lda.w linenumber_011	;---	mov		ax,WORD PTR linenumber_011
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
	sta.w linenumber_011	;---	mov		WORD PTR linenumber_011,ax
L_079
;  197:     END;
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		2
	.ENDP	enterword_062
;  198: 
;  199: 
;  200: PROCEDURE sortwords;
;  201: 
;  202:     {Sort the words alphabetically.}
;  203: 
;  204:     VAR
;  205:     i, j : wordtableindex;
;  206:     temp : wordentrytype;
;  207: 
;  208:     BEGIN

i_081	.EQ	-2	;base-relative	---i_081	EQU	<[bp-2]>
j_082	.EQ	-4	;base-relative	---j_082	EQU	<[bp-4]>
temp_083	.EQ	-28	;base-relative	---temp_083	EQU	<[bp-28]>

sortwords_080	.PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
	adj #-28	;---	sub		sp,28
;  209:     FOR i := 1 TO nextwordindex - 2 DO BEGIN
	lda #1	;---	mov		ax,1
	sta.w i_081,B	;---	mov		WORD PTR i_081,ax
L_084
	lda.w nextwordindex_009	;---	mov		ax,WORD PTR nextwordindex_009
	pha.w	;---	push	ax
	lda #2	;---	mov		ax,2
						;---	pop		dx
	xma.w 0,S	;---	sub		dx,ax
	sec	;prepare to subtract
	sbc.w 0,S	;subtract operands
	adj #2	;pop ops/params
						;---	mov		ax,dx
	cmp.w i_081,B	;---	cmp		WORD PTR i_081,ax
	bge L_085	;---	jle		L_085
	jmp L_086	;---	jmp		L_086
L_085
;  210:         FOR j := i + 1 TO nextwordindex - 1 DO BEGIN
	lda.w i_081,B	;---	mov		ax,WORD PTR i_081
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
	sta.w j_082,B	;---	mov		WORD PTR j_082,ax
L_087
	lda.w nextwordindex_009	;---	mov		ax,WORD PTR nextwordindex_009
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	xma.w 0,S	;---	sub		dx,ax
	sec	;prepare to subtract
	sbc.w 0,S	;subtract operands
	adj #2	;pop ops/params
						;---	mov		ax,dx
	cmp.w j_082,B	;---	cmp		WORD PTR j_082,ax
	bge L_088	;---	jle		L_088
	jmp L_089	;---	jmp		L_089
L_088
;  211:         IF wordtable[i].word > wordtable[j].word THEN BEGIN
	psh.w #wordtable_007	;---	lea		ax,WORD PTR wordtable_007
	lda.w i_081,B	;---	mov		ax,WORD PTR i_081
	dec.w a	;---	sub		ax,1
						;---	mov		dx,24
						;---	imul	dx
	pha.w	;push index
	psh.w #24	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	pla.w	;---	pop		ax
	clc	;---	add		ax,word_002
	adc.w #word_002	;compute field offset
	pha.w	;---	push	ax
	psh.w #wordtable_007	;---	lea		ax,WORD PTR wordtable_007
	lda.w j_082,B	;---	mov		ax,WORD PTR j_082
	dec.w a	;---	sub		ax,1
						;---	mov		dx,24
						;---	imul	dx
	pha.w	;push index
	psh.w #24	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	pla.w	;---	pop		ax
	clc	;---	add		ax,word_002
	adc.w #word_002	;compute field offset
	pha.w	;---	push	ax
						;---	cld
	psh.w #20	;---	mov		cx,20
						;---	pop		di
						;---	pop		si
						;---	mov		ax,ds
						;---	mov		es,ax
	jsr _cmpsb	;---	repe	cmpsb
	adj #+6	; remove parameters
	php	;---	mov		ax,1
	lda #1	;load integer literal
	plp	;pull PSW
	bgt L_092	;---	jg		L_092
	lda #0	;---	sub		ax,ax
L_092
	cmp.w #1	;---	cmp		ax,1
	beq L_090	;---	je		L_090
	jmp  L_091	;---	jmp		L_091
L_090
;  212:             temp := wordtable[i];
	txa.w	;---	lea		ax,WORD PTR temp_083
	sec	;compensate for BP/SP offset
	adc.w #temp_083	compute effective address
	pha.w	;---	push	ax
	psh.w #wordtable_007	;---	lea		ax,WORD PTR wordtable_007
	lda.w i_081,B	;---	mov		ax,WORD PTR i_081
	dec.w a	;---	sub		ax,1
						;---	mov		dx,24
						;---	imul	dx
	pha.w	;push index
	psh.w #24	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	swp.x	;--- Save BP
	lda #24	;---	mov		cx,24
	plx.w	;---	pop		si
	ply.w	;---	pop		di
						;---	mov		ax,ds
						;---	mov		es,ax
						;---	cld
	mvb #51	;blk move: inc si, inc di---	rep	movsb
	swp.x	;--- Restore BP
;  213:             wordtable[i] := wordtable[j];
	psh.w #wordtable_007	;---	lea		ax,WORD PTR wordtable_007
	lda.w i_081,B	;---	mov		ax,WORD PTR i_081
	dec.w a	;---	sub		ax,1
						;---	mov		dx,24
						;---	imul	dx
	pha.w	;push index
	psh.w #24	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	psh.w #wordtable_007	;---	lea		ax,WORD PTR wordtable_007
	lda.w j_082,B	;---	mov		ax,WORD PTR j_082
	dec.w a	;---	sub		ax,1
						;---	mov		dx,24
						;---	imul	dx
	pha.w	;push index
	psh.w #24	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	swp.x	;--- Save BP
	lda #24	;---	mov		cx,24
	plx.w	;---	pop		si
	ply.w	;---	pop		di
						;---	mov		ax,ds
						;---	mov		es,ax
						;---	cld
	mvb #51	;blk move: inc si, inc di---	rep	movsb
	swp.x	;--- Restore BP
;  214:             wordtable[j] := temp;
	psh.w #wordtable_007	;---	lea		ax,WORD PTR wordtable_007
	lda.w j_082,B	;---	mov		ax,WORD PTR j_082
	dec.w a	;---	sub		ax,1
						;---	mov		dx,24
						;---	imul	dx
	pha.w	;push index
	psh.w #24	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	txa.w	;---	lea		ax,WORD PTR temp_083
	sec	;compensate for BP/SP offset
	adc.w #temp_083	compute effective address
	pha.w	;---	push	ax
	swp.x	;--- Save BP
	lda #24	;---	mov		cx,24
	plx.w	;---	pop		si
	ply.w	;---	pop		di
						;---	mov		ax,ds
						;---	mov		es,ax
						;---	cld
	mvb #51	;blk move: inc si, inc di---	rep	movsb
	swp.x	;--- Restore BP
;  215:         END;
L_091
;  216:         END;
	inc.w j_082,B	;---	inc		WORD PTR j_082
	jmp L_087	;---	jmp		L_087
L_089
	dec.w j_082,B	;---	dec		WORD PTR j_082
;  217:     END;
	inc.w i_081,B	;---	inc		WORD PTR i_081
	jmp L_084	;---	jmp		L_084
L_086
	dec.w i_081,B	;---	dec		WORD PTR i_081
;  218:     END;
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		2
	.ENDP	sortwords_080
;  219: 
;  220: 
;  221: PROCEDURE printnumbers (i : numbertableindex);
;  222: 
;  223:     {Print a word's linked list of line numbers.}
;  224: 
;  225:     BEGIN

i_094	.EQ	+6	;base-relative	---i_094	EQU	<[bp+6]>

printnumbers_093	.PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
;  226:     REPEAT
L_095
;  227:         write(numbertable[i].number:4);
	psh.w #numbertable_008	;---	lea		ax,WORD PTR numbertable_008
	lda.w i_094,B	;---	mov		ax,WORD PTR i_094
						;---	mov		dx,4
						;---	imul	dx
	asl.w a	;arithmetic shift
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	pla.w	;---	pop		ax
	clc	;---	add		ax,number_005
	adc.w #number_005	;compute field offset
	pha.w	;---	push	ax
						;---	pop		bx
	lda.w (0,S)	;---	mov		ax,WORD PTR [bx]
	adj #2	;pop ops/params
	pha.w	;---	push	ax
	lda #4	;---	mov		ax,4
	pha.w	;---	push	ax
	jsr _iwrite	;---	call	_write_integer
	adj #4	;---	add		sp,4
;  228:         i := numbertable[i].nextindex;
	psh.w #numbertable_008	;---	lea		ax,WORD PTR numbertable_008
	lda.w i_094,B	;---	mov		ax,WORD PTR i_094
						;---	mov		dx,4
						;---	imul	dx
	asl.w a	;arithmetic shift
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	pla.w	;---	pop		ax
	clc	;---	add		ax,nextindex_006
	adc.w #nextindex_006	;compute field offset
	pha.w	;---	push	ax
						;---	pop		bx
	lda.w (0,S)	;---	mov		ax,WORD PTR [bx]
	adj #2	;pop ops/params
	sta.w i_094,B	;---	mov		WORD PTR i_094,ax
;  229:     UNTIL i = 0;
	lda.w i_094,B	;---	mov		ax,WORD PTR i_094
	pha.w	;---	push	ax
	lda #0	;---	mov		ax,0
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_097	;---	je		L_097
	lda #0	;---	sub		ax,ax
L_097
	cmp.w #1	;---	cmp		ax,1
	beq L_096	;---	je		L_096
	jmp L_095	;---	jmp		L_095
L_096
;  230:     writeln;
	jsr _writeln	;---	call	_write_line
;  231:     END;
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		4
	.ENDP	printnumbers_093
;  232: 
;  233: 
;  234: PROCEDURE printxref;
;  235: 
;  236:     {Print the cross reference listing.}
;  237: 
;  238:     VAR
;  239:     i : wordtableindex;
;  240: 
;  241:     BEGIN

i_099	.EQ	-2	;base-relative	---i_099	EQU	<[bp-2]>

printxref_098	.PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
	adj #-2	;---	sub		sp,2
;  242:     writeln;
	jsr _writeln	;---	call	_write_line
;  243:     writeln;
	jsr _writeln	;---	call	_write_line
;  244:     writeln('Cross-reference');
	psh.w #S_100	;---	lea		ax,WORD PTR S_100
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #15	;---	mov		ax,15
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jsr _writeln	;---	call	_write_line
;  245:     writeln('---------------');
	psh.w #S_101	;---	lea		ax,WORD PTR S_101
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #15	;---	mov		ax,15
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jsr _writeln	;---	call	_write_line
;  246:     writeln;
	jsr _writeln	;---	call	_write_line
;  247:     sortwords;
	lda.w STATIC_LINK,B	;---	push	STATIC_LINK
	pha.w	;push acc
	jsr sortwords_080	;---	call	sortwords_080
	adj #2	;pop ops/params
;  248:     FOR i := 1 TO nextwordindex - 1 DO BEGIN
	lda #1	;---	mov		ax,1
	sta.w i_099,B	;---	mov		WORD PTR i_099,ax
L_102
	lda.w nextwordindex_009	;---	mov		ax,WORD PTR nextwordindex_009
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	xma.w 0,S	;---	sub		dx,ax
	sec	;prepare to subtract
	sbc.w 0,S	;subtract operands
	adj #2	;pop ops/params
						;---	mov		ax,dx
	cmp.w i_099,B	;---	cmp		WORD PTR i_099,ax
	bge L_103	;---	jle		L_103
	jmp L_104	;---	jmp		L_104
L_103
;  249:         write(wordtable[i].word);
	psh.w #wordtable_007	;---	lea		ax,WORD PTR wordtable_007
	lda.w i_099,B	;---	mov		ax,WORD PTR i_099
	dec.w a	;---	sub		ax,1
						;---	mov		dx,24
						;---	imul	dx
	pha.w	;push index
	psh.w #24	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	pla.w	;---	pop		ax
	clc	;---	add		ax,word_002
	adc.w #word_002	;compute field offset
	pha.w	;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #20	;---	mov		ax,20
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
;  250:         printnumbers(wordtable[i].firstnumberindex);
	psh.w #wordtable_007	;---	lea		ax,WORD PTR wordtable_007
	lda.w i_099,B	;---	mov		ax,WORD PTR i_099
	dec.w a	;---	sub		ax,1
						;---	mov		dx,24
						;---	imul	dx
	pha.w	;push index
	psh.w #24	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	pla.w	;---	pop		ax
	clc	;---	add		ax,firstnumberindex_003
	adc.w #firstnumberindex_003	;compute field offset
	pha.w	;---	push	ax
						;---	pop		bx
	lda.w (0,S)	;---	mov		ax,WORD PTR [bx]
	adj #2	;pop ops/params
	pha.w	;---	push	ax
	lda.w STATIC_LINK,B	;---	push	STATIC_LINK
	pha.w	;push acc
	jsr printnumbers_093	;---	call	printnumbers_093
	adj #4	;pop ops/params
;  251:     END;
	inc.w i_099,B	;---	inc		WORD PTR i_099
	jmp L_102	;---	jmp		L_102
L_104
	dec.w i_099,B	;---	dec		WORD PTR i_099
;  252:     END;
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		2
	.ENDP	printxref_098
;  253: 
;  254: 
;  255: BEGIN {xref}

_pc65_main	.PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
;  256:     wordtablefull   := false;
	lda #0	;---	mov		ax,0
	sta.w wordtablefull_012	;---	mov		WORD PTR wordtablefull_012,ax
;  257:     numbertablefull := false;
	lda #0	;---	mov		ax,0
	sta.w numbertablefull_013	;---	mov		WORD PTR numbertablefull_013,ax
;  258:     nextwordindex   := 1;
	lda #1	;---	mov		ax,1
	sta.w nextwordindex_009	;---	mov		WORD PTR nextwordindex_009,ax
;  259:     nextnumberindex := 1;
	lda #1	;---	mov		ax,1
	sta.w nextnumberindex_010	;---	mov		WORD PTR nextnumberindex_010,ax
;  260:     linenumber      := 1;
	lda #1	;---	mov		ax,1
	sta.w linenumber_011	;---	mov		WORD PTR linenumber_011,ax
;  261:     write('    1 : ');
	psh.w #S_105	;---	lea		ax,WORD PTR S_105
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #8	;---	mov		ax,8
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
;  262: 
;  263:     {First read the words.}
;  264:     WHILE NOT (eof OR wordtablefull OR numbertablefull) DO BEGIN
L_106
	jsr _eof	;---	call	_std_end_of_file
	pha.w	;---	push	ax
	lda.w wordtablefull_012	;---	mov		ax,WORD PTR wordtablefull_012
						;---	pop		dx
	ora.w 0,S	;---	or		ax,dx
	adj #2	;pop ops/params
	pha.w	;---	push	ax
	lda.w numbertablefull_013	;---	mov		ax,WORD PTR numbertablefull_013
						;---	pop		dx
	ora.w 0,S	;---	or		ax,dx
	adj #2	;pop ops/params
	eor #1	;---	xor		ax,1
	cmp.w #1	;---	cmp		ax,1
	beq L_107	;---	je		L_107
	jmp L_108	;---	jmp		L_108
L_107
;  265:     readword(wordtable[nextwordindex].word);
	psh.w #wordtable_007	;---	lea		ax,WORD PTR wordtable_007
	lda.w nextwordindex_009	;---	mov		ax,WORD PTR nextwordindex_009
	dec.w a	;---	sub		ax,1
						;---	mov		dx,24
						;---	imul	dx
	pha.w	;push index
	psh.w #24	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	pla.w	;---	pop		ax
	clc	;---	add		ax,word_002
	adc.w #word_002	;compute field offset
	pha.w	;---	push	ax
	phx.w	;---	push	bp
	jsr readword_030	;---	call	readword_030
	adj #4	;pop ops/params
;  266:     IF gotword THEN enterword;
	lda.w gotword_015	;---	mov		ax,WORD PTR gotword_015
	cmp.w #1	;---	cmp		ax,1
	beq L_109	;---	je		L_109
	jmp  L_110	;---	jmp		L_110
L_109
	phx.w	;---	push	bp
	jsr enterword_062	;---	call	enterword_062
	adj #2	;pop ops/params
L_110
;  267:     END;
	jmp L_106	;---	jmp		L_106
L_108
;  268: 
;  269:     {Then print the cross reference listing if all went well.}
;  270:     IF wordtablefull THEN BEGIN
	lda.w wordtablefull_012	;---	mov		ax,WORD PTR wordtablefull_012
	cmp.w #1	;---	cmp		ax,1
	beq L_111	;---	je		L_111
	jmp  L_112	;---	jmp		L_112
L_111
;  271:         writeln;
	jsr _writeln	;---	call	_write_line
;  272:     writeln('*** The word table is not large enough. ***');
	psh.w #S_113	;---	lea		ax,WORD PTR S_113
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #43	;---	mov		ax,43
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jsr _writeln	;---	call	_write_line
;  273:     END
;  274:     ELSE IF numbertablefull THEN BEGIN
	jmp L_114	;---	jmp		L_114
L_112
	lda.w numbertablefull_013	;---	mov		ax,WORD PTR numbertablefull_013
	cmp.w #1	;---	cmp		ax,1
	beq L_115	;---	je		L_115
	jmp  L_116	;---	jmp		L_116
L_115
;  275:         writeln;
	jsr _writeln	;---	call	_write_line
;  276:     writeln('*** The number table is not large enough. ***');
	psh.w #S_117	;---	lea		ax,WORD PTR S_117
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #45	;---	mov		ax,45
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jsr _writeln	;---	call	_write_line
;  277:     END
;  278:     ELSE BEGIN
	jmp L_118	;---	jmp		L_118
L_116
;  279:     printxref;
	phx.w	;---	push	bp
	jsr printxref_098	;---	call	printxref_098
	adj #2	;pop ops/params
;  280:     END;
L_118
L_114
;  281: 
;  282:     {Print final stats.}
;  283:     writeln;
	jsr _writeln	;---	call	_write_line
;  284:     writeln((nextwordindex - 1):5,   ' word entries.');
	lda.w nextwordindex_009	;---	mov		ax,WORD PTR nextwordindex_009
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	xma.w 0,S	;---	sub		dx,ax
	sec	;prepare to subtract
	sbc.w 0,S	;subtract operands
	adj #2	;pop ops/params
						;---	mov		ax,dx
	pha.w	;---	push	ax
	lda #5	;---	mov		ax,5
	pha.w	;---	push	ax
	jsr _iwrite	;---	call	_write_integer
	adj #4	;---	add		sp,4
	psh.w #S_119	;---	lea		ax,WORD PTR S_119
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #14	;---	mov		ax,14
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jsr _writeln	;---	call	_write_line
;  285:     writeln((nextnumberindex - 1):5, ' line number entries.');
	lda.w nextnumberindex_010	;---	mov		ax,WORD PTR nextnumberindex_010
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	xma.w 0,S	;---	sub		dx,ax
	sec	;prepare to subtract
	sbc.w 0,S	;subtract operands
	adj #2	;pop ops/params
						;---	mov		ax,dx
	pha.w	;---	push	ax
	lda #5	;---	mov		ax,5
	pha.w	;---	push	ax
	jsr _iwrite	;---	call	_write_integer
	adj #4	;---	add		sp,4
	psh.w #S_120	;---	lea		ax,WORD PTR S_120
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #21	;---	mov		ax,21
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jsr _writeln	;---	call	_write_line
;  286: END {xref}.
;  287: 

	plx.w	;---	pop		bp
	rts	;---	ret	

	.ENDP	_pc65_main

	.DATA	;place in DATA segment

wordtable_007	.DB	12000	;define array
numbertable_008	.DB	4004	;define array
nextwordindex_009	.DB	2	;define integer
nextnumberindex_010	.DB	2	;define integer
linenumber_011	.DB	2	;define integer
wordtablefull_012	.DB	2	;define integer
numbertablefull_013	.DB	2	;define integer
newline_014	.DB	2	;define integer
gotword_015	.DB	2	;define integer
S_120	.DS	" line number entries."	;string literal absolute
S_119	.DS	" word entries."	;string literal absolute
S_117	.DS	"*** The number table is not large enough. ***"	;string literal absolute
S_113	.DS	"*** The word table is not large enough. ***"	;string literal absolute
S_105	.DS	"    1 : "	;string literal absolute
S_101	.DS	"---------------"	;string literal absolute
S_100	.DS	"Cross-reference"	;string literal absolute
S_020	.DS	" : "	;string literal absolute

	.END
