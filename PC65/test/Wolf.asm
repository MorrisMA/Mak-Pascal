;    1: PROGRAM WolfIsland (input, output);
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
;    3: {   Wolf Island is a simulation of a 9 x 9 island of wolves and rabbits.
;    4:     The wolves eat rabbits, and the rabbits eat grass.  Their initial
;    5:     locations are:
;    6: 
;    7:             . . . . . . . . .
;    8:             . W . . . . . W .
;    9:             . . . . . . . . .
;   10:             . . . r r r . . .
;   11:             . . . r r r . . .
;   12:             . . . r r r . . .
;   13:             . . . . . . . . .
;   14:             . W . . . . . W .
;   15:             . . . . . . . . .
;   16: 
;   17:     A wolf or rabbit can move up, down, left, or right into an adjacent
;   18:     location.  Diagonal moves are not allowed.
;   19: 
;   20:     Time is measured in discrete time units.  Wolves reproduce every
;   21:     12 time units, and rabbits every 5 units.  An animal reproduces
;   22:     by splitting into two.
;   23: 
;   24:     Each wolf starts out with 6 food units and loses 1 every time unit.
;   25:     A wolf gains 6 food units by eating a rabbit.  It starves to death
;   26:     if it reaches 0 food units.  Since there's always enough grass to
;   27:     eat, rabbits don't worry about food units.
;   28: 
;   29:     The order of events from time unit T-1 to T is:
;   30: 
;   31:     (1) For each wolf:
;   32: 
;   33:     Lose a food unit.  Die if 0 food units and remove.
;   34: 
;   35:     Eat a rabbit if there is one in an adjacent location by moving
;   36:     into the rabbit's location.  Increase the wolf's food units
;   37:     by 6 and remove the rabbit.
;   38: 
;   39:     Otherwise, randomly choose to move into an adjacent empty
;   40:     location, or stay put.
;   41: 
;   42:     If wolf reproduction time (T = 12,24,36,...), split and leave
;   43:     behind an offspring in the previous location.  Each split wolf
;   44:     has half (DIV 2) the food units.  If there was no move, the
;   45:     baby was stillborn, but the food units are still halved.
;   46: 
;   47:     (2) For each rabbit:
;   48: 
;   49:     Randomly choose to move into an adjacent empty, or stay put.
;   50: 
;   51:     If rabbit reproduction time (T = 5,10,15,...), split and leave
;   52:     behind an offspring in the previous location.  If there was no
;   53:     move, the baby was stillborn.
;   54: 
;   55:     The simulation ends when all the wolves are dead or all the
;   56:     rabbits are eaten.
;   57: 
;   58:     The island is printed at times T = 0,1,2,3,4,5,6,7,8,9,10,
;   59:     15,20,25,30,...,80.  A message is printed whenever a wolf is
;   60:     born or dies, and whenever a rabbit is born or is eaten.
;   61: }
;   62: 
;   63: CONST
;   64:     size            = 9;    {size of island}
;   65:     max             = 10;       {size plus border}
;   66:     wolfreprotime   = 12;       {wolf reproduction period}
;   67:     rabbitreprotime = 5;        {rabbit reproduction period}
;   68:     rabbitfoodunits = 6;        {rabbit food unit worth to wolf}
;   69:     initfoodunits   = 6;        {wolf's initial food units}
;   70:     maxprinttimes   = 50;       {max. no. times to print island}
;   71: 
;   72: TYPE
;   73:     posint   = 0..32767;
;   74:     index    = 0..max;          {index range of island matrix}
;   75: 
;   76:     contents = (wolf, rabbit, newwolf, newrabbit, empty, border);
;   77:     {Contents each each island location.  Each time a wolf or
;   78:      rabbit moves, newwolf or newrabbit is initially placed in
;   79:      the new location.  This prevents a wolf or rabbit from
;   80:      being processed again in its new location during the same
;   81:      time period.}
;   82: 
;   83: VAR
;   84:     island     : ARRAY [index, index] OF contents;
;   85:                 {Wolf Island with border}
;   86:     foodunits  : ARRAY [1..size, 1..size] OF posint;
;   87:                 {wolves' food unit matrix}
;   88:     printtimes : ARRAY [1..maxprinttimes] OF posint;
;   89:                 {times to print island}
;   90: 
;   91:     numwolves, numrabbits : posint; {no. of wolves and rabbits}
;   92:     numprinttimes         : posint;     {no. of print times}
;   93:     t                 : posint;     {time}
;   94:     xpt  : 1..maxprinttimes;        {print times index}
;   95:     seed : posint;                  {random number seed}
;   96: 
;   97:     rowoffset : ARRAY [0..4] OF -1..+1;
;   98:     coloffset : ARRAY [0..4] OF -1..+1;
;   99:     {Row and column offsets.  When added to the current row and
;  100:      column of a wolf's or rabbit's location, gives the row and
;  101:      column of the same or an adjacent location.}
;  102: 
;  103: 
;  104: PROCEDURE Initialize;
;  105: 
;  106:     {Initialize all arrays.}
;  107: 
;  108:     VAR
;  109:     i        : posint;
;  110:     row, col : index;
;  111: 
;  112:     BEGIN

i_014	EQU	-2	;base-relative	---i_014	EQU	<[bp-2]>
row_015	EQU	-4	;base-relative	---row_015	EQU	<[bp-4]>
col_016	EQU	-6	;base-relative	---col_016	EQU	<[bp-6]>

_initialize_013	PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
	adj #-6	;---	sub		sp,6
;  113: 
;  114:     {Initialize the island and wolf food matrices.}
;  115:     FOR i := 0 TO max DO BEGIN
	lda #0	;---	mov		ax,0
	sta.w i_014,B	;---	mov		WORD PTR i_014,ax
L_017:
	lda #10	;---	mov		ax,10
	cmp.w i_014,B	;---	cmp		WORD PTR i_014,ax
	bge L_018	;---	jle		L_018
	jmp L_019	;---	jmp		L_019
L_018:
;  116:         island[0,   i] := border;
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda #0	;---	mov		ax,0
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w i_014,B	;---	mov		ax,WORD PTR i_014
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #5	;---	mov		ax,5
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  117:         island[max, i] := border;
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda #10	;---	mov		ax,10
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w i_014,B	;---	mov		ax,WORD PTR i_014
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #5	;---	mov		ax,5
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  118:         island[i, 0]   := border;
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda.w i_014,B	;---	mov		ax,WORD PTR i_014
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #0	;---	mov		ax,0
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #5	;---	mov		ax,5
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  119:         island[i, max] := border;
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda.w i_014,B	;---	mov		ax,WORD PTR i_014
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #10	;---	mov		ax,10
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #5	;---	mov		ax,5
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  120:     END;
	inc.w i_014,B	;---	inc		WORD PTR i_014
	jmp L_017	;---	jmp		L_017
L_019:
	dec.w i_014,B	;---	dec		WORD PTR i_014
;  121:     FOR row := 1 TO size DO BEGIN
	lda #1	;---	mov		ax,1
	sta.w row_015,B	;---	mov		WORD PTR row_015,ax
L_020:
	lda #9	;---	mov		ax,9
	cmp.w row_015,B	;---	cmp		WORD PTR row_015,ax
	bge L_021	;---	jle		L_021
	jmp L_022	;---	jmp		L_022
L_021:
;  122:         FOR col := 1 TO size DO BEGIN
	lda #1	;---	mov		ax,1
	sta.w col_016,B	;---	mov		WORD PTR col_016,ax
L_023:
	lda #9	;---	mov		ax,9
	cmp.w col_016,B	;---	cmp		WORD PTR col_016,ax
	bge L_024	;---	jle		L_024
	jmp L_025	;---	jmp		L_025
L_024:
;  123:         island[row, col]    := empty;
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda.w row_015,B	;---	mov		ax,WORD PTR row_015
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w col_016,B	;---	mov		ax,WORD PTR col_016
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #4	;---	mov		ax,4
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  124:         foodunits[row, col] := 0;
	psh.w #foodunits_003	;---	lea		ax,WORD PTR foodunits_003
	lda.w row_015,B	;---	mov		ax,WORD PTR row_015
	dec.w a	;---	sub		ax,1
						;---	mov		dx,18
						;---	imul	dx
	pha.w	;push index
	psh.w #18	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w col_016,B	;---	mov		ax,WORD PTR col_016
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
;  125:         END;
	inc.w col_016,B	;---	inc		WORD PTR col_016
	jmp L_023	;---	jmp		L_023
L_025:
	dec.w col_016,B	;---	dec		WORD PTR col_016
;  126:     END;
	inc.w row_015,B	;---	inc		WORD PTR row_015
	jmp L_020	;---	jmp		L_020
L_022:
	dec.w row_015,B	;---	dec		WORD PTR row_015
;  127: 
;  128:     {Place wolves on the island.}
;  129:     read(numwolves);
	psh.w #numwolves_005	;---	lea		ax,WORD PTR numwolves_005
	jsr _iread	;---	call	_read_integer
					;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;pop ops/params
;  130:     FOR i := 1 TO numwolves DO BEGIN
	lda #1	;---	mov		ax,1
	sta.w i_014,B	;---	mov		WORD PTR i_014,ax
L_026:
	lda.w numwolves_005	;---	mov		ax,WORD PTR numwolves_005
	cmp.w i_014,B	;---	cmp		WORD PTR i_014,ax
	bge L_027	;---	jle		L_027
	jmp L_028	;---	jmp		L_028
L_027:
;  131:         read(row, col);
	txa.w	;---	lea		ax,WORD PTR row_015
	sec	;compensate for BP/SP offset
	adc.w #row_015	compute effective address
	pha.w	;---	push	ax
	jsr _iread	;---	call	_read_integer
					;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;pop ops/params
	txa.w	;---	lea		ax,WORD PTR col_016
	sec	;compensate for BP/SP offset
	adc.w #col_016	compute effective address
	pha.w	;---	push	ax
	jsr _iread	;---	call	_read_integer
					;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;pop ops/params
;  132:         island[row, col]    := wolf;
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda.w row_015,B	;---	mov		ax,WORD PTR row_015
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w col_016,B	;---	mov		ax,WORD PTR col_016
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
;  133:         foodunits[row, col] := initfoodunits;
	psh.w #foodunits_003	;---	lea		ax,WORD PTR foodunits_003
	lda.w row_015,B	;---	mov		ax,WORD PTR row_015
	dec.w a	;---	sub		ax,1
						;---	mov		dx,18
						;---	imul	dx
	pha.w	;push index
	psh.w #18	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w col_016,B	;---	mov		ax,WORD PTR col_016
	dec.w a	;---	sub		ax,1
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #6	;---	mov		ax,6
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  134:     END;
	inc.w i_014,B	;---	inc		WORD PTR i_014
	jmp L_026	;---	jmp		L_026
L_028:
	dec.w i_014,B	;---	dec		WORD PTR i_014
;  135: 
;  136:     {Place rabbits on the island.}
;  137:     read(numrabbits);
	psh.w #numrabbits_006	;---	lea		ax,WORD PTR numrabbits_006
	jsr _iread	;---	call	_read_integer
					;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;pop ops/params
;  138:     FOR i := 1 TO numrabbits DO BEGIN
	lda #1	;---	mov		ax,1
	sta.w i_014,B	;---	mov		WORD PTR i_014,ax
L_029:
	lda.w numrabbits_006	;---	mov		ax,WORD PTR numrabbits_006
	cmp.w i_014,B	;---	cmp		WORD PTR i_014,ax
	bge L_030	;---	jle		L_030
	jmp L_031	;---	jmp		L_031
L_030:
;  139:         read(row, col);
	txa.w	;---	lea		ax,WORD PTR row_015
	sec	;compensate for BP/SP offset
	adc.w #row_015	compute effective address
	pha.w	;---	push	ax
	jsr _iread	;---	call	_read_integer
					;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;pop ops/params
	txa.w	;---	lea		ax,WORD PTR col_016
	sec	;compensate for BP/SP offset
	adc.w #col_016	compute effective address
	pha.w	;---	push	ax
	jsr _iread	;---	call	_read_integer
					;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;pop ops/params
;  140:         island[row, col] := rabbit;
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda.w row_015,B	;---	mov		ax,WORD PTR row_015
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w col_016,B	;---	mov		ax,WORD PTR col_016
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
;  141:     END;
	inc.w i_014,B	;---	inc		WORD PTR i_014
	jmp L_029	;---	jmp		L_029
L_031:
	dec.w i_014,B	;---	dec		WORD PTR i_014
;  142: 
;  143:     {Read print times.}
;  144:     read(numprinttimes);
	psh.w #numprinttimes_007	;---	lea		ax,WORD PTR numprinttimes_007
	jsr _iread	;---	call	_read_integer
					;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;pop ops/params
;  145:     FOR i := 1 TO numprinttimes DO BEGIN
	lda #1	;---	mov		ax,1
	sta.w i_014,B	;---	mov		WORD PTR i_014,ax
L_032:
	lda.w numprinttimes_007	;---	mov		ax,WORD PTR numprinttimes_007
	cmp.w i_014,B	;---	cmp		WORD PTR i_014,ax
	bge L_033	;---	jle		L_033
	jmp L_034	;---	jmp		L_034
L_033:
;  146:         read(printtimes[i]);
	psh.w #printtimes_004	;---	lea		ax,WORD PTR printtimes_004
	lda.w i_014,B	;---	mov		ax,WORD PTR i_014
	dec.w a	;---	sub		ax,1
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	jsr _iread	;---	call	_read_integer
					;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;pop ops/params
;  147:     END;
	inc.w i_014,B	;---	inc		WORD PTR i_014
	jmp L_032	;---	jmp		L_032
L_034:
	dec.w i_014,B	;---	dec		WORD PTR i_014
;  148: 
;  149:     {Initialize the row and column offsets for moves.}
;  150:     rowoffset[0] :=  0; coloffset[0] :=  0; {stay put}
	psh.w #rowoffset_011	;---	lea		ax,WORD PTR rowoffset_011
	lda #0	;---	mov		ax,0
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
	psh.w #coloffset_012	;---	lea		ax,WORD PTR coloffset_012
	lda #0	;---	mov		ax,0
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
;  151:     rowoffset[1] := -1; coloffset[1] :=  0; {up}
	psh.w #rowoffset_011	;---	lea		ax,WORD PTR rowoffset_011
	lda #1	;---	mov		ax,1
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #1	;---	mov		ax,1
	eor.w #-1	;---	neg		ax
	inc.w a	;complete negation
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
	psh.w #coloffset_012	;---	lea		ax,WORD PTR coloffset_012
	lda #1	;---	mov		ax,1
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
;  152:     rowoffset[2] :=  0; coloffset[2] := -1; {left}
	psh.w #rowoffset_011	;---	lea		ax,WORD PTR rowoffset_011
	lda #2	;---	mov		ax,2
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
	psh.w #coloffset_012	;---	lea		ax,WORD PTR coloffset_012
	lda #2	;---	mov		ax,2
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #1	;---	mov		ax,1
	eor.w #-1	;---	neg		ax
	inc.w a	;complete negation
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  153:     rowoffset[3] :=  0; coloffset[3] := +1; {right}
	psh.w #rowoffset_011	;---	lea		ax,WORD PTR rowoffset_011
	lda #3	;---	mov		ax,3
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
	psh.w #coloffset_012	;---	lea		ax,WORD PTR coloffset_012
	lda #3	;---	mov		ax,3
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
;  154:     rowoffset[4] := +1; coloffset[4] :=  0; {down}
	psh.w #rowoffset_011	;---	lea		ax,WORD PTR rowoffset_011
	lda #4	;---	mov		ax,4
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
	psh.w #coloffset_012	;---	lea		ax,WORD PTR coloffset_012
	lda #4	;---	mov		ax,4
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
;  155:     END {Initialize};
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		2
_initialize_013	ENDP
;  156: 
;  157: 
;  158: FUNCTION random (limit : posint) : posint;
;  159: 
;  160:     {Return a random integer from 0..limit-1.}
;  161: 
;  162:     CONST
;  163:     multiplier = 21;
;  164:     increment  = 77;
;  165:     divisor    = 1024;
;  166: 
;  167:     BEGIN

limit_036	EQU	+6	;base-relative	---limit_036	EQU	<[bp+6]>

_random_035	PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
	adj #-4	;---	sub		sp,4
;  168:     seed   := (seed*multiplier + increment) MOD divisor;
	lda.w seed_010	;---	mov		ax,WORD PTR seed_010
	pha.w	;---	push	ax
	lda #21	;---	mov		ax,21
	pha.w	;---	pop		dx
	jsr _imul	;---	imul	dx
	adj #4	;pop ops/params
	pha.w	;---	push	ax
	lda #77	;---	mov		ax,77
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
	pha.w	;---	push	ax
	lda.w #1024	;---	mov		ax,1024
	pha.w	;---	mov		cx,ax
						;---	pop		ax
						;---	cwd	
	jsr _idiv	;---	idiv	cx
	adj #4	;pop ops/params
	swp	;---	mov		ax,dx
	sta.w seed_010	;---	mov		WORD PTR seed_010,ax
;  169:     random := (seed*limit) DIV divisor;
	lda.w seed_010	;---	mov		ax,WORD PTR seed_010
	pha.w	;---	push	ax
	lda.w limit_036,B	;---	mov		ax,WORD PTR limit_036
	pha.w	;---	pop		dx
	jsr _imul	;---	imul	dx
	adj #4	;pop ops/params
	pha.w	;---	push	ax
	lda.w #1024	;---	mov		ax,1024
	pha.w	;---	mov		cx,ax
						;---	pop		ax
						;---	cwd	
	jsr _idiv	;---	idiv	cx
	adj #4	;pop ops/params
	sta.w RETURN_VALUE,B	;---	mov		RETURN_VALUE,ax
;  170:     END {random};
	lda.w RETURN_VALUE,B	;---	mov		ax,RETURN_VALUE
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		4
_random_035	ENDP
;  171: 
;  172: 
;  173: PROCEDURE NewLocation (creature : contents;
;  174:                oldrow, oldcol : index;
;  175:                VAR newrow, newcol : index);
;  176: 
;  177:     {Find a new location for the creature currently at
;  178:      island[oldrow, oldcol].}
;  179: 
;  180: 
;  181:     VAR
;  182:     adj  : 0..4;        {adjacent locations index}
;  183:     what : contents;    {contents of location}
;  184:     done : boolean;
;  185: 
;  186:     BEGIN

creature_038	EQU	+14	;base-relative	---creature_038	EQU	<[bp+14]>
oldrow_039	EQU	+12	;base-relative	---oldrow_039	EQU	<[bp+12]>
oldcol_040	EQU	+10	;base-relative	---oldcol_040	EQU	<[bp+10]>
newrow_041	EQU	+8	;base-relative	---newrow_041	EQU	<[bp+8]>
newcol_042	EQU	+6	;base-relative	---newcol_042	EQU	<[bp+6]>
adj_043	EQU	-2	;base-relative	---adj_043	EQU	<[bp-2]>
what_044	EQU	-4	;base-relative	---what_044	EQU	<[bp-4]>
done_045	EQU	-6	;base-relative	---done_045	EQU	<[bp-6]>

_newlocation_037	PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
	adj #-6	;---	sub		sp,6
;  187:     done := false;
	lda #0	;---	mov		ax,0
	sta.w done_045	;---	mov		WORD PTR done_045,ax
;  188: 
;  189:     {A wolf first tries to eat a rabbit.
;  190:      Check adjacent locations.}
;  191:     IF creature = wolf THEN BEGIN
	lda.w creature_038,B	;---	mov		ax,WORD PTR creature_038
	pha.w	;---	push	ax
	lda #0	;---	mov		ax,0
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_048	;---	je		L_048
	lda #0	;---	sub		ax,ax
L_048:
	cmp.w #1	;---	cmp		ax,1
	beq L_046	;---	je		L_046
	jmp  L_047	;---	jmp		L_047
L_046:
;  192:         adj := 0;
	lda #0	;---	mov		ax,0
	sta.w adj_043	;---	mov		WORD PTR adj_043,ax
;  193:         REPEAT
L_049:
;  194:         adj := adj + 1;
	lda.w adj_043,B	;---	mov		ax,WORD PTR adj_043
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
	sta.w adj_043	;---	mov		WORD PTR adj_043,ax
;  195:         newrow := oldrow + rowoffset[adj];
	lda.w newrow_041,B	;---	mov		ax,WORD PTR newrow_041
	pha.w	;---	push	ax
	lda.w oldrow_039,B	;---	mov		ax,WORD PTR oldrow_039
	pha.w	;---	push	ax
	psh.w #rowoffset_011	;---	lea		ax,WORD PTR rowoffset_011
	lda.w adj_043,B	;---	mov		ax,WORD PTR adj_043
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
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  196:         newcol := oldcol + coloffset[adj];
	lda.w newcol_042,B	;---	mov		ax,WORD PTR newcol_042
	pha.w	;---	push	ax
	lda.w oldcol_040,B	;---	mov		ax,WORD PTR oldcol_040
	pha.w	;---	push	ax
	psh.w #coloffset_012	;---	lea		ax,WORD PTR coloffset_012
	lda.w adj_043,B	;---	mov		ax,WORD PTR adj_043
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
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  197:         what   := island[newrow, newcol];
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
							;---	mov		bx,WORD PTR newrow_041
	lda.w (newrow_041,B)	;---	mov		ax,WORD PTR [bx]
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
							;---	mov		bx,WORD PTR newcol_042
	lda.w (newcol_042,B)	;---	mov		ax,WORD PTR [bx]
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
	sta.w what_044	;---	mov		WORD PTR what_044,ax
;  198:         done   := what = rabbit;
	lda.w what_044,B	;---	mov		ax,WORD PTR what_044
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_051	;---	je		L_051
	lda #0	;---	sub		ax,ax
L_051:
	sta.w done_045	;---	mov		WORD PTR done_045,ax
;  199:         UNTIL done OR (adj = 4);
	lda.w done_045,B	;---	mov		ax,WORD PTR done_045
	pha.w	;---	push	ax
	lda.w adj_043,B	;---	mov		ax,WORD PTR adj_043
	pha.w	;---	push	ax
	lda #4	;---	mov		ax,4
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_052	;---	je		L_052
	lda #0	;---	sub		ax,ax
L_052:
						;---	pop		dx
	ora.w 0,S	;---	or		ax,dx
	adj #2	;pop ops/params
	cmp.w #1	;---	cmp		ax,1
	beq L_050	;---	je		L_050
	jmp L_049	;---	jmp		L_049
L_050:
;  200:     END;
L_047:
;  201: 
;  202:     {Move randomly into an adjacent location or stay put.}
;  203:     IF NOT done THEN BEGIN
	lda.w done_045,B	;---	mov		ax,WORD PTR done_045
	eor #1	;---	xor		ax,1
	cmp.w #1	;---	cmp		ax,1
	beq L_053	;---	je		L_053
	jmp  L_054	;---	jmp		L_054
L_053:
;  204:         REPEAT
L_055:
;  205:         adj := random(5);
	lda #5	;---	mov		ax,5
	pha.w	;---	push	ax
	lda.w STATIC_LINK,B	;---	push	STATIC_LINK
	pha.w	;push acc
	jsr _random_035	;---	call	random_035
	adj #4	;pop ops/params
	sta.w adj_043	;---	mov		WORD PTR adj_043,ax
;  206:         newrow := oldrow + rowoffset[adj];
	lda.w newrow_041,B	;---	mov		ax,WORD PTR newrow_041
	pha.w	;---	push	ax
	lda.w oldrow_039,B	;---	mov		ax,WORD PTR oldrow_039
	pha.w	;---	push	ax
	psh.w #rowoffset_011	;---	lea		ax,WORD PTR rowoffset_011
	lda.w adj_043,B	;---	mov		ax,WORD PTR adj_043
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
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  207:         newcol := oldcol + coloffset[adj];
	lda.w newcol_042,B	;---	mov		ax,WORD PTR newcol_042
	pha.w	;---	push	ax
	lda.w oldcol_040,B	;---	mov		ax,WORD PTR oldcol_040
	pha.w	;---	push	ax
	psh.w #coloffset_012	;---	lea		ax,WORD PTR coloffset_012
	lda.w adj_043,B	;---	mov		ax,WORD PTR adj_043
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
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  208:         what   := island[newrow, newcol];
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
							;---	mov		bx,WORD PTR newrow_041
	lda.w (newrow_041,B)	;---	mov		ax,WORD PTR [bx]
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
							;---	mov		bx,WORD PTR newcol_042
	lda.w (newcol_042,B)	;---	mov		ax,WORD PTR [bx]
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
	sta.w what_044	;---	mov		WORD PTR what_044,ax
;  209:         UNTIL    (what = empty)
	lda.w what_044,B	;---	mov		ax,WORD PTR what_044
	pha.w	;---	push	ax
	lda #4	;---	mov		ax,4
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_057	;---	je		L_057
	lda #0	;---	sub		ax,ax
L_057:
;  210:           OR ((newrow = oldrow) AND (newcol = oldcol));
	pha.w	;---	push	ax
							;---	mov		bx,WORD PTR newrow_041
	lda.w (newrow_041,B)	;---	mov		ax,WORD PTR [bx]
	pha.w	;---	push	ax
	lda.w oldrow_039,B	;---	mov		ax,WORD PTR oldrow_039
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_058	;---	je		L_058
	lda #0	;---	sub		ax,ax
L_058:
	pha.w	;---	push	ax
							;---	mov		bx,WORD PTR newcol_042
	lda.w (newcol_042,B)	;---	mov		ax,WORD PTR [bx]
	pha.w	;---	push	ax
	lda.w oldcol_040,B	;---	mov		ax,WORD PTR oldcol_040
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_059	;---	je		L_059
	lda #0	;---	sub		ax,ax
L_059:
						;---	pop		dx
	anl.w 0,S	;---	and		ax,dx
	adj #2	;pop ops/params
						;---	pop		dx
	ora.w 0,S	;---	or		ax,dx
	adj #2	;pop ops/params
	cmp.w #1	;---	cmp		ax,1
	beq L_056	;---	je		L_056
	jmp L_055	;---	jmp		L_055
L_056:
;  211:     END;
L_054:
;  212:     END {NewLocation};
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		12
_newlocation_037	ENDP
;  213: 
;  214: 
;  215: PROCEDURE ProcessWolf (oldrow, oldcol : index);
;  216: 
;  217:     {Process the wolf located at island[oldrow, oldcol].}
;  218: 
;  219:     VAR
;  220:     newrow, newcol : index;     {new row and column}
;  221:     moved : boolean;            {true iff wolf moved}
;  222: 
;  223:     BEGIN

oldrow_061	EQU	+8	;base-relative	---oldrow_061	EQU	<[bp+8]>
oldcol_062	EQU	+6	;base-relative	---oldcol_062	EQU	<[bp+6]>
newrow_063	EQU	-2	;base-relative	---newrow_063	EQU	<[bp-2]>
newcol_064	EQU	-4	;base-relative	---newcol_064	EQU	<[bp-4]>
moved_065	EQU	-6	;base-relative	---moved_065	EQU	<[bp-6]>

_processwolf_060	PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
	adj #-6	;---	sub		sp,6
;  224: 
;  225:     {Lose a food unit.}
;  226:     foodunits[oldrow, oldcol] := foodunits[oldrow, oldcol] - 1;
	psh.w #foodunits_003	;---	lea		ax,WORD PTR foodunits_003
	lda.w oldrow_061,B	;---	mov		ax,WORD PTR oldrow_061
	dec.w a	;---	sub		ax,1
						;---	mov		dx,18
						;---	imul	dx
	pha.w	;push index
	psh.w #18	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w oldcol_062,B	;---	mov		ax,WORD PTR oldcol_062
	dec.w a	;---	sub		ax,1
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	psh.w #foodunits_003	;---	lea		ax,WORD PTR foodunits_003
	lda.w oldrow_061,B	;---	mov		ax,WORD PTR oldrow_061
	dec.w a	;---	sub		ax,1
						;---	mov		dx,18
						;---	imul	dx
	pha.w	;push index
	psh.w #18	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w oldcol_062,B	;---	mov		ax,WORD PTR oldcol_062
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
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	xma.w 0,S	;---	sub		dx,ax
	sec	;prepare to subtract
	sbc.w 0,S	;subtract operands
	adj #2	;pop ops/params
						;---	mov		ax,dx
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  227: 
;  228:     IF foodunits[oldrow, oldcol] = 0 THEN BEGIN
	psh.w #foodunits_003	;---	lea		ax,WORD PTR foodunits_003
	lda.w oldrow_061,B	;---	mov		ax,WORD PTR oldrow_061
	dec.w a	;---	sub		ax,1
						;---	mov		dx,18
						;---	imul	dx
	pha.w	;push index
	psh.w #18	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w oldcol_062,B	;---	mov		ax,WORD PTR oldcol_062
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
	pha.w	;---	push	ax
	lda #0	;---	mov		ax,0
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_068	;---	je		L_068
	lda #0	;---	sub		ax,ax
L_068:
	cmp.w #1	;---	cmp		ax,1
	beq L_066	;---	je		L_066
	jmp  L_067	;---	jmp		L_067
L_066:
;  229: 
;  230:         {Die of starvation.}
;  231:         island[oldrow, oldcol] := empty;
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda.w oldrow_061,B	;---	mov		ax,WORD PTR oldrow_061
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w oldcol_062,B	;---	mov		ax,WORD PTR oldcol_062
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #4	;---	mov		ax,4
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  232:         numwolves := numwolves - 1;
	lda.w numwolves_005	;---	mov		ax,WORD PTR numwolves_005
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	xma.w 0,S	;---	sub		dx,ax
	sec	;prepare to subtract
	sbc.w 0,S	;subtract operands
	adj #2	;pop ops/params
						;---	mov		ax,dx
	sta.w numwolves_005	;---	mov		WORD PTR numwolves_005,ax
;  233:         writeln('t =', t:4, ' : Wolf died at ',
	psh.w #S_069	;---	lea		ax,WORD PTR S_069
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #3	;---	mov		ax,3
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	lda.w t_008	;---	mov		ax,WORD PTR t_008
	pha.w	;---	push	ax
	lda #4	;---	mov		ax,4
	pha.w	;---	push	ax
	jsr _iwrite	;---	call	_write_integer
	adj #4	;---	add		sp,4
	psh.w #S_070	;---	lea		ax,WORD PTR S_070
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #16	;---	mov		ax,16
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
;  234:             '[', oldrow:1, ', ', oldcol:1, ']');
	lda #91	;---	mov		ax,'['
	pha.w	;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	jsr _cwrite	;---	call	_write_char
	adj #4	;---	add		sp,4
	lda.w oldrow_061,B	;---	mov		ax,WORD PTR oldrow_061
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
	pha.w	;---	push	ax
	jsr _iwrite	;---	call	_write_integer
	adj #4	;---	add		sp,4
	psh.w #S_071	;---	lea		ax,WORD PTR S_071
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #2	;---	mov		ax,2
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	lda.w oldcol_062,B	;---	mov		ax,WORD PTR oldcol_062
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
	pha.w	;---	push	ax
	jsr _iwrite	;---	call	_write_integer
	adj #4	;---	add		sp,4
	lda #93	;---	mov		ax,']'
	pha.w	;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	jsr _cwrite	;---	call	_write_char
	adj #4	;---	add		sp,4
	jsr _writeln	;---	call	_write_line
;  235:     END
;  236:     ELSE BEGIN
	jmp L_072	;---	jmp		L_072
L_067:
;  237: 
;  238:         {Move to adjacent location, or stay put.}
;  239:         NewLocation(wolf, oldrow, oldcol, newrow, newcol);
	lda #0	;---	mov		ax,0
	pha.w	;---	push	ax
	lda.w oldrow_061,B	;---	mov		ax,WORD PTR oldrow_061
	pha.w	;---	push	ax
	lda.w oldcol_062,B	;---	mov		ax,WORD PTR oldcol_062
	pha.w	;---	push	ax
	txa.w	;---	lea		ax,WORD PTR newrow_063
	sec	;compensate for BP/SP offset
	adc.w #newrow_063	compute effective address
	pha.w	;---	push	ax
	txa.w	;---	lea		ax,WORD PTR newcol_064
	sec	;compensate for BP/SP offset
	adc.w #newcol_064	compute effective address
	pha.w	;---	push	ax
	lda.w STATIC_LINK,B	;---	push	STATIC_LINK
	pha.w	;push acc
	jsr _newlocation_037	;---	call	newlocation_037
	adj #12	;pop ops/params
;  240:         moved := (newrow <> oldrow) OR (newcol <> oldcol);
	lda.w newrow_063,B	;---	mov		ax,WORD PTR newrow_063
	pha.w	;---	push	ax
	lda.w oldrow_061,B	;---	mov		ax,WORD PTR oldrow_061
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	bne L_073	;---	jne		L_073
	lda #0	;---	sub		ax,ax
L_073:
	pha.w	;---	push	ax
	lda.w newcol_064,B	;---	mov		ax,WORD PTR newcol_064
	pha.w	;---	push	ax
	lda.w oldcol_062,B	;---	mov		ax,WORD PTR oldcol_062
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	bne L_074	;---	jne		L_074
	lda #0	;---	sub		ax,ax
L_074:
						;---	pop		dx
	ora.w 0,S	;---	or		ax,dx
	adj #2	;pop ops/params
	sta.w moved_065	;---	mov		WORD PTR moved_065,ax
;  241: 
;  242:         IF moved THEN BEGIN
	lda.w moved_065,B	;---	mov		ax,WORD PTR moved_065
	cmp.w #1	;---	cmp		ax,1
	beq L_075	;---	je		L_075
	jmp  L_076	;---	jmp		L_076
L_075:
;  243: 
;  244:         {If there's a rabbit there, eat it.}
;  245:         IF island[newrow, newcol] = rabbit THEN BEGIN
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda.w newrow_063,B	;---	mov		ax,WORD PTR newrow_063
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w newcol_064,B	;---	mov		ax,WORD PTR newcol_064
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
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_079	;---	je		L_079
	lda #0	;---	sub		ax,ax
L_079:
	cmp.w #1	;---	cmp		ax,1
	beq L_077	;---	je		L_077
	jmp  L_078	;---	jmp		L_078
L_077:
;  246:             foodunits[oldrow, oldcol] :=
	psh.w #foodunits_003	;---	lea		ax,WORD PTR foodunits_003
	lda.w oldrow_061,B	;---	mov		ax,WORD PTR oldrow_061
	dec.w a	;---	sub		ax,1
						;---	mov		dx,18
						;---	imul	dx
	pha.w	;push index
	psh.w #18	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w oldcol_062,B	;---	mov		ax,WORD PTR oldcol_062
	dec.w a	;---	sub		ax,1
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
;  247:             foodunits[oldrow, oldcol] + rabbitfoodunits;
	psh.w #foodunits_003	;---	lea		ax,WORD PTR foodunits_003
	lda.w oldrow_061,B	;---	mov		ax,WORD PTR oldrow_061
	dec.w a	;---	sub		ax,1
						;---	mov		dx,18
						;---	imul	dx
	pha.w	;push index
	psh.w #18	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w oldcol_062,B	;---	mov		ax,WORD PTR oldcol_062
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
	pha.w	;---	push	ax
	lda #6	;---	mov		ax,6
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  248:             numrabbits := numrabbits - 1;
	lda.w numrabbits_006	;---	mov		ax,WORD PTR numrabbits_006
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	xma.w 0,S	;---	sub		dx,ax
	sec	;prepare to subtract
	sbc.w 0,S	;subtract operands
	adj #2	;pop ops/params
						;---	mov		ax,dx
	sta.w numrabbits_006	;---	mov		WORD PTR numrabbits_006,ax
;  249:             writeln('t =', t:4, ' : Rabbit eaten at ',
	psh.w #S_069	;---	lea		ax,WORD PTR S_069
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #3	;---	mov		ax,3
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	lda.w t_008	;---	mov		ax,WORD PTR t_008
	pha.w	;---	push	ax
	lda #4	;---	mov		ax,4
	pha.w	;---	push	ax
	jsr _iwrite	;---	call	_write_integer
	adj #4	;---	add		sp,4
	psh.w #S_080	;---	lea		ax,WORD PTR S_080
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #19	;---	mov		ax,19
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
;  250:                 '[', newrow:1, ', ', newcol:1, ']');
	lda #91	;---	mov		ax,'['
	pha.w	;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	jsr _cwrite	;---	call	_write_char
	adj #4	;---	add		sp,4
	lda.w newrow_063,B	;---	mov		ax,WORD PTR newrow_063
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
	pha.w	;---	push	ax
	jsr _iwrite	;---	call	_write_integer
	adj #4	;---	add		sp,4
	psh.w #S_071	;---	lea		ax,WORD PTR S_071
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #2	;---	mov		ax,2
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	lda.w newcol_064,B	;---	mov		ax,WORD PTR newcol_064
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
	pha.w	;---	push	ax
	jsr _iwrite	;---	call	_write_integer
	adj #4	;---	add		sp,4
	lda #93	;---	mov		ax,']'
	pha.w	;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	jsr _cwrite	;---	call	_write_char
	adj #4	;---	add		sp,4
	jsr _writeln	;---	call	_write_line
;  251:         END;
L_078:
;  252: 
;  253:         {Set new (or same) location.}
;  254:         island[newrow, newcol] := newwolf;
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda.w newrow_063,B	;---	mov		ax,WORD PTR newrow_063
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w newcol_064,B	;---	mov		ax,WORD PTR newcol_064
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #2	;---	mov		ax,2
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  255:         island[oldrow, oldcol] := empty;
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda.w oldrow_061,B	;---	mov		ax,WORD PTR oldrow_061
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w oldcol_062,B	;---	mov		ax,WORD PTR oldcol_062
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #4	;---	mov		ax,4
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  256:         foodunits[newrow, newcol] := foodunits[oldrow, oldcol];
	psh.w #foodunits_003	;---	lea		ax,WORD PTR foodunits_003
	lda.w newrow_063,B	;---	mov		ax,WORD PTR newrow_063
	dec.w a	;---	sub		ax,1
						;---	mov		dx,18
						;---	imul	dx
	pha.w	;push index
	psh.w #18	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w newcol_064,B	;---	mov		ax,WORD PTR newcol_064
	dec.w a	;---	sub		ax,1
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	psh.w #foodunits_003	;---	lea		ax,WORD PTR foodunits_003
	lda.w oldrow_061,B	;---	mov		ax,WORD PTR oldrow_061
	dec.w a	;---	sub		ax,1
						;---	mov		dx,18
						;---	imul	dx
	pha.w	;push index
	psh.w #18	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w oldcol_062,B	;---	mov		ax,WORD PTR oldcol_062
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
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  257:         foodunits[oldrow, oldcol] := 0;
	psh.w #foodunits_003	;---	lea		ax,WORD PTR foodunits_003
	lda.w oldrow_061,B	;---	mov		ax,WORD PTR oldrow_061
	dec.w a	;---	sub		ax,1
						;---	mov		dx,18
						;---	imul	dx
	pha.w	;push index
	psh.w #18	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w oldcol_062,B	;---	mov		ax,WORD PTR oldcol_062
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
;  258:         END;
L_076:
;  259: 
;  260:         {Wolf reproduction time?}
;  261:         IF     ((t MOD wolfreprotime) = 0)
	lda.w t_008	;---	mov		ax,WORD PTR t_008
	pha.w	;---	push	ax
	lda #12	;---	mov		ax,12
	pha.w	;---	mov		cx,ax
						;---	pop		ax
						;---	cwd	
	jsr _idiv	;---	idiv	cx
	adj #4	;pop ops/params
	swp	;---	mov		ax,dx
	pha.w	;---	push	ax
	lda #0	;---	mov		ax,0
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_083	;---	je		L_083
	lda #0	;---	sub		ax,ax
L_083:
;  262:            AND (foodunits[newrow, newcol] > 1) THEN BEGIN
	pha.w	;---	push	ax
	psh.w #foodunits_003	;---	lea		ax,WORD PTR foodunits_003
	lda.w newrow_063,B	;---	mov		ax,WORD PTR newrow_063
	dec.w a	;---	sub		ax,1
						;---	mov		dx,18
						;---	imul	dx
	pha.w	;push index
	psh.w #18	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w newcol_064,B	;---	mov		ax,WORD PTR newcol_064
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
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	bgt L_084	;---	jg		L_084
	lda #0	;---	sub		ax,ax
L_084:
						;---	pop		dx
	anl.w 0,S	;---	and		ax,dx
	adj #2	;pop ops/params
	cmp.w #1	;---	cmp		ax,1
	beq L_081	;---	je		L_081
	jmp  L_082	;---	jmp		L_082
L_081:
;  263:         foodunits[newrow, newcol] :=
	psh.w #foodunits_003	;---	lea		ax,WORD PTR foodunits_003
	lda.w newrow_063,B	;---	mov		ax,WORD PTR newrow_063
	dec.w a	;---	sub		ax,1
						;---	mov		dx,18
						;---	imul	dx
	pha.w	;push index
	psh.w #18	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w newcol_064,B	;---	mov		ax,WORD PTR newcol_064
	dec.w a	;---	sub		ax,1
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
;  264:             foodunits[newrow, newcol] DIV 2;
	psh.w #foodunits_003	;---	lea		ax,WORD PTR foodunits_003
	lda.w newrow_063,B	;---	mov		ax,WORD PTR newrow_063
	dec.w a	;---	sub		ax,1
						;---	mov		dx,18
						;---	imul	dx
	pha.w	;push index
	psh.w #18	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w newcol_064,B	;---	mov		ax,WORD PTR newcol_064
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
	pha.w	;---	push	ax
	lda #2	;---	mov		ax,2
	pha.w	;---	mov		cx,ax
						;---	pop		ax
						;---	cwd	
	jsr _idiv	;---	idiv	cx
	adj #4	;pop ops/params
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  265: 
;  266:         {If moved, then leave behind an offspring.}
;  267:         IF moved THEN BEGIN
	lda.w moved_065,B	;---	mov		ax,WORD PTR moved_065
	cmp.w #1	;---	cmp		ax,1
	beq L_085	;---	je		L_085
	jmp  L_086	;---	jmp		L_086
L_085:
;  268:             island[oldrow, oldcol] := newwolf;
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda.w oldrow_061,B	;---	mov		ax,WORD PTR oldrow_061
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w oldcol_062,B	;---	mov		ax,WORD PTR oldcol_062
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #2	;---	mov		ax,2
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  269:             foodunits[oldrow, oldcol] :=
	psh.w #foodunits_003	;---	lea		ax,WORD PTR foodunits_003
	lda.w oldrow_061,B	;---	mov		ax,WORD PTR oldrow_061
	dec.w a	;---	sub		ax,1
						;---	mov		dx,18
						;---	imul	dx
	pha.w	;push index
	psh.w #18	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w oldcol_062,B	;---	mov		ax,WORD PTR oldcol_062
	dec.w a	;---	sub		ax,1
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
;  270:             foodunits[newrow, newcol];
	psh.w #foodunits_003	;---	lea		ax,WORD PTR foodunits_003
	lda.w newrow_063,B	;---	mov		ax,WORD PTR newrow_063
	dec.w a	;---	sub		ax,1
						;---	mov		dx,18
						;---	imul	dx
	pha.w	;push index
	psh.w #18	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w newcol_064,B	;---	mov		ax,WORD PTR newcol_064
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
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  271:             numwolves := numwolves + 1;
	lda.w numwolves_005	;---	mov		ax,WORD PTR numwolves_005
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
	sta.w numwolves_005	;---	mov		WORD PTR numwolves_005,ax
;  272:             writeln('t =', t:4, ' : Wolf born at ',
	psh.w #S_069	;---	lea		ax,WORD PTR S_069
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #3	;---	mov		ax,3
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	lda.w t_008	;---	mov		ax,WORD PTR t_008
	pha.w	;---	push	ax
	lda #4	;---	mov		ax,4
	pha.w	;---	push	ax
	jsr _iwrite	;---	call	_write_integer
	adj #4	;---	add		sp,4
	psh.w #S_087	;---	lea		ax,WORD PTR S_087
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #16	;---	mov		ax,16
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
;  273:                 '[', oldrow:1, ', ', oldcol:1, ']');
	lda #91	;---	mov		ax,'['
	pha.w	;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	jsr _cwrite	;---	call	_write_char
	adj #4	;---	add		sp,4
	lda.w oldrow_061,B	;---	mov		ax,WORD PTR oldrow_061
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
	pha.w	;---	push	ax
	jsr _iwrite	;---	call	_write_integer
	adj #4	;---	add		sp,4
	psh.w #S_071	;---	lea		ax,WORD PTR S_071
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #2	;---	mov		ax,2
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	lda.w oldcol_062,B	;---	mov		ax,WORD PTR oldcol_062
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
	pha.w	;---	push	ax
	jsr _iwrite	;---	call	_write_integer
	adj #4	;---	add		sp,4
	lda #93	;---	mov		ax,']'
	pha.w	;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	jsr _cwrite	;---	call	_write_char
	adj #4	;---	add		sp,4
	jsr _writeln	;---	call	_write_line
;  274:         END;
L_086:
;  275:         END;
L_082:
;  276:     END;
L_072:
;  277:     END {ProcessWolf};
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		6
_processwolf_060	ENDP
;  278: 
;  279: 
;  280: PROCEDURE ProcessRabbit (oldrow, oldcol : index);
;  281: 
;  282:     {Process the rabbit located at island[oldrow, oldcol].}
;  283: 
;  284:     VAR
;  285:     newrow, newcol : index;     {new row and column}
;  286:     moved : boolean;            {true iff rabbit moved}
;  287: 
;  288:     BEGIN

oldrow_089	EQU	+8	;base-relative	---oldrow_089	EQU	<[bp+8]>
oldcol_090	EQU	+6	;base-relative	---oldcol_090	EQU	<[bp+6]>
newrow_091	EQU	-2	;base-relative	---newrow_091	EQU	<[bp-2]>
newcol_092	EQU	-4	;base-relative	---newcol_092	EQU	<[bp-4]>
moved_093	EQU	-6	;base-relative	---moved_093	EQU	<[bp-6]>

_processrabbit_088	PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
	adj #-6	;---	sub		sp,6
;  289: 
;  290:     {Move to adjacent location, or stay put.}
;  291:     NewLocation(rabbit, oldrow, oldcol, newrow, newcol);
	lda #1	;---	mov		ax,1
	pha.w	;---	push	ax
	lda.w oldrow_089,B	;---	mov		ax,WORD PTR oldrow_089
	pha.w	;---	push	ax
	lda.w oldcol_090,B	;---	mov		ax,WORD PTR oldcol_090
	pha.w	;---	push	ax
	txa.w	;---	lea		ax,WORD PTR newrow_091
	sec	;compensate for BP/SP offset
	adc.w #newrow_091	compute effective address
	pha.w	;---	push	ax
	txa.w	;---	lea		ax,WORD PTR newcol_092
	sec	;compensate for BP/SP offset
	adc.w #newcol_092	compute effective address
	pha.w	;---	push	ax
	lda.w STATIC_LINK,B	;---	push	STATIC_LINK
	pha.w	;push acc
	jsr _newlocation_037	;---	call	newlocation_037
	adj #12	;pop ops/params
;  292:     moved := (newrow <> oldrow) OR (newcol <> oldcol);
	lda.w newrow_091,B	;---	mov		ax,WORD PTR newrow_091
	pha.w	;---	push	ax
	lda.w oldrow_089,B	;---	mov		ax,WORD PTR oldrow_089
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	bne L_094	;---	jne		L_094
	lda #0	;---	sub		ax,ax
L_094:
	pha.w	;---	push	ax
	lda.w newcol_092,B	;---	mov		ax,WORD PTR newcol_092
	pha.w	;---	push	ax
	lda.w oldcol_090,B	;---	mov		ax,WORD PTR oldcol_090
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	bne L_095	;---	jne		L_095
	lda #0	;---	sub		ax,ax
L_095:
						;---	pop		dx
	ora.w 0,S	;---	or		ax,dx
	adj #2	;pop ops/params
	sta.w moved_093	;---	mov		WORD PTR moved_093,ax
;  293:     IF moved THEN BEGIN
	lda.w moved_093,B	;---	mov		ax,WORD PTR moved_093
	cmp.w #1	;---	cmp		ax,1
	beq L_096	;---	je		L_096
	jmp  L_097	;---	jmp		L_097
L_096:
;  294:         island[newrow, newcol] := newrabbit;
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda.w newrow_091,B	;---	mov		ax,WORD PTR newrow_091
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w newcol_092,B	;---	mov		ax,WORD PTR newcol_092
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #3	;---	mov		ax,3
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  295:         island[oldrow, oldcol] := empty;
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda.w oldrow_089,B	;---	mov		ax,WORD PTR oldrow_089
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w oldcol_090,B	;---	mov		ax,WORD PTR oldcol_090
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #4	;---	mov		ax,4
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  296:     END;
L_097:
;  297: 
;  298:     {Rabbit reproduction time?}
;  299:     IF (t MOD rabbitreprotime) = 0 THEN BEGIN
	lda.w t_008	;---	mov		ax,WORD PTR t_008
	pha.w	;---	push	ax
	lda #5	;---	mov		ax,5
	pha.w	;---	mov		cx,ax
						;---	pop		ax
						;---	cwd	
	jsr _idiv	;---	idiv	cx
	adj #4	;pop ops/params
	swp	;---	mov		ax,dx
	pha.w	;---	push	ax
	lda #0	;---	mov		ax,0
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_100	;---	je		L_100
	lda #0	;---	sub		ax,ax
L_100:
	cmp.w #1	;---	cmp		ax,1
	beq L_098	;---	je		L_098
	jmp  L_099	;---	jmp		L_099
L_098:
;  300: 
;  301:         {If moved, then leave behind an offspring.}
;  302:         IF moved THEN BEGIN
	lda.w moved_093,B	;---	mov		ax,WORD PTR moved_093
	cmp.w #1	;---	cmp		ax,1
	beq L_101	;---	je		L_101
	jmp  L_102	;---	jmp		L_102
L_101:
;  303:         island[oldrow, oldcol] := newrabbit;
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda.w oldrow_089,B	;---	mov		ax,WORD PTR oldrow_089
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w oldcol_090,B	;---	mov		ax,WORD PTR oldcol_090
						;---	mov		dx,2
						;---	imul	dx
	asl.w a	;arithmetic shift
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda #3	;---	mov		ax,3
						;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;--- pop TOS
;  304:         numrabbits := numrabbits + 1;
	lda.w numrabbits_006	;---	mov		ax,WORD PTR numrabbits_006
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
	sta.w numrabbits_006	;---	mov		WORD PTR numrabbits_006,ax
;  305:         writeln('t =', t:4, ' : Rabbit born at ',
	psh.w #S_069	;---	lea		ax,WORD PTR S_069
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #3	;---	mov		ax,3
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	lda.w t_008	;---	mov		ax,WORD PTR t_008
	pha.w	;---	push	ax
	lda #4	;---	mov		ax,4
	pha.w	;---	push	ax
	jsr _iwrite	;---	call	_write_integer
	adj #4	;---	add		sp,4
	psh.w #S_103	;---	lea		ax,WORD PTR S_103
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #18	;---	mov		ax,18
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
;  306:             '[', oldrow:1, ', ', oldcol:1, ']');
	lda #91	;---	mov		ax,'['
	pha.w	;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	jsr _cwrite	;---	call	_write_char
	adj #4	;---	add		sp,4
	lda.w oldrow_089,B	;---	mov		ax,WORD PTR oldrow_089
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
	pha.w	;---	push	ax
	jsr _iwrite	;---	call	_write_integer
	adj #4	;---	add		sp,4
	psh.w #S_071	;---	lea		ax,WORD PTR S_071
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #2	;---	mov		ax,2
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	lda.w oldcol_090,B	;---	mov		ax,WORD PTR oldcol_090
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
	pha.w	;---	push	ax
	jsr _iwrite	;---	call	_write_integer
	adj #4	;---	add		sp,4
	lda #93	;---	mov		ax,']'
	pha.w	;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	jsr _cwrite	;---	call	_write_char
	adj #4	;---	add		sp,4
	jsr _writeln	;---	call	_write_line
;  307:         END;
L_102:
;  308:     END;
L_099:
;  309:     END {ProcessRabbit};
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		6
_processrabbit_088	ENDP
;  310: 
;  311: 
;  312: PROCEDURE EventsOccur;
;  313: 
;  314:     {Perform the events that occur for each time unit.}
;  315: 
;  316:     VAR
;  317:     row, col : index;
;  318: 
;  319:     BEGIN

row_105	EQU	-2	;base-relative	---row_105	EQU	<[bp-2]>
col_106	EQU	-4	;base-relative	---col_106	EQU	<[bp-4]>

_eventsoccur_104	PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
	adj #-4	;---	sub		sp,4
;  320: 
;  321:     {Scan for wolves and process each one in turn.}
;  322:     FOR row := 1 TO size DO BEGIN
	lda #1	;---	mov		ax,1
	sta.w row_105,B	;---	mov		WORD PTR row_105,ax
L_107:
	lda #9	;---	mov		ax,9
	cmp.w row_105,B	;---	cmp		WORD PTR row_105,ax
	bge L_108	;---	jle		L_108
	jmp L_109	;---	jmp		L_109
L_108:
;  323:         FOR col := 1 TO size DO BEGIN
	lda #1	;---	mov		ax,1
	sta.w col_106,B	;---	mov		WORD PTR col_106,ax
L_110:
	lda #9	;---	mov		ax,9
	cmp.w col_106,B	;---	cmp		WORD PTR col_106,ax
	bge L_111	;---	jle		L_111
	jmp L_112	;---	jmp		L_112
L_111:
;  324:         IF island[row, col] = wolf THEN BEGIN
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda.w row_105,B	;---	mov		ax,WORD PTR row_105
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w col_106,B	;---	mov		ax,WORD PTR col_106
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
	pha.w	;---	push	ax
	lda #0	;---	mov		ax,0
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_115	;---	je		L_115
	lda #0	;---	sub		ax,ax
L_115:
	cmp.w #1	;---	cmp		ax,1
	beq L_113	;---	je		L_113
	jmp  L_114	;---	jmp		L_114
L_113:
;  325:             ProcessWolf(row, col);
	lda.w row_105,B	;---	mov		ax,WORD PTR row_105
	pha.w	;---	push	ax
	lda.w col_106,B	;---	mov		ax,WORD PTR col_106
	pha.w	;---	push	ax
	lda.w STATIC_LINK,B	;---	push	STATIC_LINK
	pha.w	;push acc
	jsr _processwolf_060	;---	call	processwolf_060
	adj #6	;pop ops/params
;  326:         END;
L_114:
;  327:         END;
	inc.w col_106,B	;---	inc		WORD PTR col_106
	jmp L_110	;---	jmp		L_110
L_112:
	dec.w col_106,B	;---	dec		WORD PTR col_106
;  328:     END;
	inc.w row_105,B	;---	inc		WORD PTR row_105
	jmp L_107	;---	jmp		L_107
L_109:
	dec.w row_105,B	;---	dec		WORD PTR row_105
;  329: 
;  330: 
;  331:     {Scan for rabbits and process each one in turn.}
;  332:     FOR row := 1 TO size DO BEGIN
	lda #1	;---	mov		ax,1
	sta.w row_105,B	;---	mov		WORD PTR row_105,ax
L_116:
	lda #9	;---	mov		ax,9
	cmp.w row_105,B	;---	cmp		WORD PTR row_105,ax
	bge L_117	;---	jle		L_117
	jmp L_118	;---	jmp		L_118
L_117:
;  333:         FOR col := 1 TO size DO BEGIN
	lda #1	;---	mov		ax,1
	sta.w col_106,B	;---	mov		WORD PTR col_106,ax
L_119:
	lda #9	;---	mov		ax,9
	cmp.w col_106,B	;---	cmp		WORD PTR col_106,ax
	bge L_120	;---	jle		L_120
	jmp L_121	;---	jmp		L_121
L_120:
;  334:         IF island[row, col] = rabbit THEN BEGIN
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda.w row_105,B	;---	mov		ax,WORD PTR row_105
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w col_106,B	;---	mov		ax,WORD PTR col_106
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
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_124	;---	je		L_124
	lda #0	;---	sub		ax,ax
L_124:
	cmp.w #1	;---	cmp		ax,1
	beq L_122	;---	je		L_122
	jmp  L_123	;---	jmp		L_123
L_122:
;  335:             ProcessRabbit(row, col);
	lda.w row_105,B	;---	mov		ax,WORD PTR row_105
	pha.w	;---	push	ax
	lda.w col_106,B	;---	mov		ax,WORD PTR col_106
	pha.w	;---	push	ax
	lda.w STATIC_LINK,B	;---	push	STATIC_LINK
	pha.w	;push acc
	jsr _processrabbit_088	;---	call	processrabbit_088
	adj #6	;pop ops/params
;  336:         END;
L_123:
;  337:         END;
	inc.w col_106,B	;---	inc		WORD PTR col_106
	jmp L_119	;---	jmp		L_119
L_121:
	dec.w col_106,B	;---	dec		WORD PTR col_106
;  338:     END;
	inc.w row_105,B	;---	inc		WORD PTR row_105
	jmp L_116	;---	jmp		L_116
L_118:
	dec.w row_105,B	;---	dec		WORD PTR row_105
;  339:     END {EventsOccur};
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		2
_eventsoccur_104	ENDP
;  340: 
;  341: 
;  342: PROCEDURE PrintIsland;
;  343: 
;  344:     {Print the island.}
;  345: 
;  346:     VAR
;  347:     row, col : index;
;  348:     cnts     : contents;
;  349: 
;  350:     BEGIN

row_126	EQU	-2	;base-relative	---row_126	EQU	<[bp-2]>
col_127	EQU	-4	;base-relative	---col_127	EQU	<[bp-4]>
cnts_128	EQU	-6	;base-relative	---cnts_128	EQU	<[bp-6]>

_printisland_125	PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
	adj #-6	;---	sub		sp,6
;  351:     writeln;
	jsr _writeln	;---	call	_write_line
;  352:     writeln('t =', t:4, ' : Wolf Island');
	psh.w #S_069	;---	lea		ax,WORD PTR S_069
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #3	;---	mov		ax,3
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	lda.w t_008	;---	mov		ax,WORD PTR t_008
	pha.w	;---	push	ax
	lda #4	;---	mov		ax,4
	pha.w	;---	push	ax
	jsr _iwrite	;---	call	_write_integer
	adj #4	;---	add		sp,4
	psh.w #S_129	;---	lea		ax,WORD PTR S_129
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #14	;---	mov		ax,14
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
	jsr _writeln	;---	call	_write_line
;  353:     writeln;
	jsr _writeln	;---	call	_write_line
;  354: 
;  355:     FOR row := 1 TO size DO BEGIN
	lda #1	;---	mov		ax,1
	sta.w row_126,B	;---	mov		WORD PTR row_126,ax
L_130:
	lda #9	;---	mov		ax,9
	cmp.w row_126,B	;---	cmp		WORD PTR row_126,ax
	bge L_131	;---	jle		L_131
	jmp L_132	;---	jmp		L_132
L_131:
;  356:         write(' ':10);
	lda #32	;---	mov		ax,' '
	pha.w	;---	push	ax
	lda #10	;---	mov		ax,10
	pha.w	;---	push	ax
	jsr _cwrite	;---	call	_write_char
	adj #4	;---	add		sp,4
;  357:         FOR col := 1 TO size DO BEGIN
	lda #1	;---	mov		ax,1
	sta.w col_127,B	;---	mov		WORD PTR col_127,ax
L_133:
	lda #9	;---	mov		ax,9
	cmp.w col_127,B	;---	cmp		WORD PTR col_127,ax
	bge L_134	;---	jle		L_134
	jmp L_135	;---	jmp		L_135
L_134:
;  358:         cnts := island[row, col];
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda.w row_126,B	;---	mov		ax,WORD PTR row_126
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w col_127,B	;---	mov		ax,WORD PTR col_127
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
	sta.w cnts_128	;---	mov		WORD PTR cnts_128,ax
;  359:         IF      cnts = empty  THEN write('. ')
	lda.w cnts_128,B	;---	mov		ax,WORD PTR cnts_128
	pha.w	;---	push	ax
	lda #4	;---	mov		ax,4
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_138	;---	je		L_138
	lda #0	;---	sub		ax,ax
L_138:
	cmp.w #1	;---	cmp		ax,1
	beq L_136	;---	je		L_136
	jmp  L_137	;---	jmp		L_137
L_136:
	psh.w #S_139	;---	lea		ax,WORD PTR S_139
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #2	;---	mov		ax,2
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
;  360:         ELSE IF cnts = wolf   THEN write('W ')
	jmp L_140	;---	jmp		L_140
L_137:
	lda.w cnts_128,B	;---	mov		ax,WORD PTR cnts_128
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
L_143:
	cmp.w #1	;---	cmp		ax,1
	beq L_141	;---	je		L_141
	jmp  L_142	;---	jmp		L_142
L_141:
	psh.w #S_144	;---	lea		ax,WORD PTR S_144
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #2	;---	mov		ax,2
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
;  361:         ELSE IF cnts = rabbit THEN write('r ')
	jmp L_145	;---	jmp		L_145
L_142:
	lda.w cnts_128,B	;---	mov		ax,WORD PTR cnts_128
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_148	;---	je		L_148
	lda #0	;---	sub		ax,ax
L_148:
	cmp.w #1	;---	cmp		ax,1
	beq L_146	;---	je		L_146
	jmp  L_147	;---	jmp		L_147
L_146:
	psh.w #S_149	;---	lea		ax,WORD PTR S_149
						;---	push	ax
	psh.w #0	;---	mov		ax,0
						;---	push	ax
	psh.w #2	;---	mov		ax,2
						;---	push	ax
	jsr _swrite	;---	call	_write_string
	adj #6	;---	add		sp,6
;  362:         END;
L_147:
L_145:
L_140:
	inc.w col_127,B	;---	inc		WORD PTR col_127
	jmp L_133	;---	jmp		L_133
L_135:
	dec.w col_127,B	;---	dec		WORD PTR col_127
;  363:         writeln;
	jsr _writeln	;---	call	_write_line
;  364:     END;
	inc.w row_126,B	;---	inc		WORD PTR row_126
	jmp L_130	;---	jmp		L_130
L_132:
	dec.w row_126,B	;---	dec		WORD PTR row_126
;  365:     END {PrintIsland};
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		2
_printisland_125	ENDP
;  366: 
;  367: 
;  368: PROCEDURE ResetIsland;
;  369: 
;  370:     {Reset the island by setting each newwolf to wolf
;  371:      and each newrabbit to rabbit.}
;  372: 
;  373:     VAR
;  374:     row, col : index;
;  375: 
;  376:     BEGIN

row_151	EQU	-2	;base-relative	---row_151	EQU	<[bp-2]>
col_152	EQU	-4	;base-relative	---col_152	EQU	<[bp-4]>

_resetisland_150	PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
	adj #-4	;---	sub		sp,4
;  377:     FOR row := 1 TO size DO BEGIN
	lda #1	;---	mov		ax,1
	sta.w row_151,B	;---	mov		WORD PTR row_151,ax
L_153:
	lda #9	;---	mov		ax,9
	cmp.w row_151,B	;---	cmp		WORD PTR row_151,ax
	bge L_154	;---	jle		L_154
	jmp L_155	;---	jmp		L_155
L_154:
;  378:         FOR col := 1 TO size DO BEGIN
	lda #1	;---	mov		ax,1
	sta.w col_152,B	;---	mov		WORD PTR col_152,ax
L_156:
	lda #9	;---	mov		ax,9
	cmp.w col_152,B	;---	cmp		WORD PTR col_152,ax
	bge L_157	;---	jle		L_157
	jmp L_158	;---	jmp		L_158
L_157:
;  379:         IF island[row, col] = newwolf THEN BEGIN
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda.w row_151,B	;---	mov		ax,WORD PTR row_151
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w col_152,B	;---	mov		ax,WORD PTR col_152
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
	pha.w	;---	push	ax
	lda #2	;---	mov		ax,2
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_161	;---	je		L_161
	lda #0	;---	sub		ax,ax
L_161:
	cmp.w #1	;---	cmp		ax,1
	beq L_159	;---	je		L_159
	jmp  L_160	;---	jmp		L_160
L_159:
;  380:             island[row, col] := wolf;
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda.w row_151,B	;---	mov		ax,WORD PTR row_151
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w col_152,B	;---	mov		ax,WORD PTR col_152
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
;  381:         END
;  382:         ELSE IF island[row, col] = newrabbit THEN BEGIN
	jmp L_162	;---	jmp		L_162
L_160:
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda.w row_151,B	;---	mov		ax,WORD PTR row_151
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w col_152,B	;---	mov		ax,WORD PTR col_152
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
	pha.w	;---	push	ax
	lda #3	;---	mov		ax,3
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_165	;---	je		L_165
	lda #0	;---	sub		ax,ax
L_165:
	cmp.w #1	;---	cmp		ax,1
	beq L_163	;---	je		L_163
	jmp  L_164	;---	jmp		L_164
L_163:
;  383:             island[row, col] := rabbit;
	psh.w #island_002	;---	lea		ax,WORD PTR island_002
	lda.w row_151,B	;---	mov		ax,WORD PTR row_151
						;---	mov		dx,22
						;---	imul	dx
	pha.w	;push index
	psh.w #22	;push element size
	jsr _imul	;compute offset
	adj #4	;pop ops/params
						;---	pop		dx
	clc	;---	add		dx,ax
	adc.w 0,S	;add index offset to array base
	sta.w 0,S	;store address of array element ---	push	dx
	lda.w col_152,B	;---	mov		ax,WORD PTR col_152
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
;  384:         END;
L_164:
L_162:
;  385:         END;
	inc.w col_152,B	;---	inc		WORD PTR col_152
	jmp L_156	;---	jmp		L_156
L_158:
	dec.w col_152,B	;---	dec		WORD PTR col_152
;  386:     END;
	inc.w row_151,B	;---	inc		WORD PTR row_151
	jmp L_153	;---	jmp		L_153
L_155:
	dec.w row_151,B	;---	dec		WORD PTR row_151
;  387:     END {ResetIsland};
	txs.w	;---	mov		sp,bp
	plx.w	;---	pop		bp
	rts	;---	ret		2
_resetisland_150	ENDP
;  388: 
;  389: 
;  390: BEGIN {WolfIsland}

_pascal_main	PROC

	phx.w	;---	push	bp
	tsx.w	;---	mov		bp,sp
;  391: 
;  392:     Initialize;
	phx.w	;---	push	bp
	jsr _initialize_013	;---	call	initialize_013
	adj #2	;pop ops/params
;  393: 
;  394:     t   := 0;
	lda #0	;---	mov		ax,0
	sta.w t_008	;---	mov		WORD PTR t_008,ax
;  395:     xpt := 1;
	lda #1	;---	mov		ax,1
	sta.w xpt_009	;---	mov		WORD PTR xpt_009,ax
;  396:     read(seed);
	psh.w #seed_010	;---	lea		ax,WORD PTR seed_010
	jsr _iread	;---	call	_read_integer
					;---	pop		bx
	sta.w (0,S)	;---	mov		WORD PTR [bx],ax
	adj #2	;pop ops/params
;  397: 
;  398:     PrintIsland;
	phx.w	;---	push	bp
	jsr _printisland_125	;---	call	printisland_125
	adj #2	;pop ops/params
;  399: 
;  400:     {Loop once per time period.}
;  401:     REPEAT
L_166:
;  402:     writeln;
	jsr _writeln	;---	call	_write_line
;  403: 
;  404:     t := t + 1;
	lda.w t_008	;---	mov		ax,WORD PTR t_008
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
	sta.w t_008	;---	mov		WORD PTR t_008,ax
;  405:     EventsOccur;
	phx.w	;---	push	bp
	jsr _eventsoccur_104	;---	call	eventsoccur_104
	adj #2	;pop ops/params
;  406:     ResetIsland;
	phx.w	;---	push	bp
	jsr _resetisland_150	;---	call	resetisland_150
	adj #2	;pop ops/params
;  407: 
;  408:     {Time to print the island?}
;  409:     IF t = printtimes[xpt] THEN BEGIN
	lda.w t_008	;---	mov		ax,WORD PTR t_008
	pha.w	;---	push	ax
	psh.w #printtimes_004	;---	lea		ax,WORD PTR printtimes_004
	lda.w xpt_009	;---	mov		ax,WORD PTR xpt_009
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
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_170	;---	je		L_170
	lda #0	;---	sub		ax,ax
L_170:
	cmp.w #1	;---	cmp		ax,1
	beq L_168	;---	je		L_168
	jmp  L_169	;---	jmp		L_169
L_168:
;  410:         PrintIsland;
	phx.w	;---	push	bp
	jsr _printisland_125	;---	call	printisland_125
	adj #2	;pop ops/params
;  411:         xpt := xpt + 1;
	lda.w xpt_009	;---	mov		ax,WORD PTR xpt_009
	pha.w	;---	push	ax
	lda #1	;---	mov		ax,1
						;---	pop		dx
	clc	;---	add		ax,dx
	adc.w 0,S	;add operands
	adj #2	;pop ops/params
	sta.w xpt_009	;---	mov		WORD PTR xpt_009,ax
;  412:     END;
L_169:
;  413:     UNTIL (numwolves = 0) OR (numrabbits = 0)
	lda.w numwolves_005	;---	mov		ax,WORD PTR numwolves_005
	pha.w	;---	push	ax
	lda #0	;---	mov		ax,0
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_171	;---	je		L_171
	lda #0	;---	sub		ax,ax
L_171:
	pha.w	;---	push	ax
	lda.w numrabbits_006	;---	mov		ax,WORD PTR numrabbits_006
	pha.w	;---	push	ax
	lda #0	;---	mov		ax,0
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	beq L_172	;---	je		L_172
	lda #0	;---	sub		ax,ax
L_172:
;  414:       OR (xpt > numprinttimes);
						;---	pop		dx
	ora.w 0,S	;---	or		ax,dx
	adj #2	;pop ops/params
	pha.w	;---	push	ax
	lda.w xpt_009	;---	mov		ax,WORD PTR xpt_009
	pha.w	;---	push	ax
	lda.w numprinttimes_007	;---	mov		ax,WORD PTR numprinttimes_007
	xma.w 0,S	;---	pop		dx
	cmp.w 0,S	;---	cmp		dx,ax
	adj #2	;pop ops/params
	php	;push PSW
	lda #1	;---	mov		ax,1
	plp	;pull PSW
	bgt L_173	;---	jg		L_173
	lda #0	;---	sub		ax,ax
L_173:
						;---	pop		dx
	ora.w 0,S	;---	or		ax,dx
	adj #2	;pop ops/params
	cmp.w #1	;---	cmp		ax,1
	beq L_167	;---	je		L_167
	jmp L_166	;---	jmp		L_166
L_167:
;  415: 
;  416:     PrintIsland;
	phx.w	;---	push	bp
	jsr _printisland_125	;---	call	printisland_125
	adj #2	;pop ops/params
;  417: 
;  418: END {WolfIsland}.

	plx.w	;---	pop		bp
	rts	;---	ret	

_pascal_main	ENDP

	.DATA	;place in DATA segment

island_002	DB	242	;define array
foodunits_003	DB	162	;define array
printtimes_004	DB	100	;define array
numwolves_005	DB	2	;define integer
numrabbits_006	DB	2	;define integer
numprinttimes_007	DB	2	;define integer
t_008	DB	2	;define integer
xpt_009	DB	2	;define integer
seed_010	DB	2	;define integer
rowoffset_011	DB	10	;define array
coloffset_012	DB	10	;define array
S_149	DS	"r "	;string literal absolute
S_144	DS	"W "	;string literal absolute
S_139	DS	". "	;string literal absolute
S_129	DS	" : Wolf Island"	;string literal absolute
S_103	DS	" : Rabbit born at "	;string literal absolute
S_087	DS	" : Wolf born at "	;string literal absolute
S_080	DS	" : Rabbit eaten at "	;string literal absolute
S_071	DS	", "	;string literal absolute
S_070	DS	" : Wolf died at "	;string literal absolute
S_069	DS	"t ="	;string literal absolute

	END
