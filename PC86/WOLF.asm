;    1: PROGRAM WolfIsland (input, output);
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
;    3: {   Wolf Island is a simulation of a 9 x 9 island of wolves and rabbits.
;    4:     The wolves eat rabbits, and the rabbits eat grass.  Their initial
;    5:     locations are:
;    6: 
;    7: 			. . . . . . . . .
;    8: 			. W . . . . . W .
;    9: 			. . . . . . . . .
;   10: 			. . . r r r . . .
;   11: 			. . . r r r . . .
;   12: 			. . . r r r . . .
;   13: 			. . . . . . . . .
;   14: 			. W . . . . . W .
;   15: 			. . . . . . . . .
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
;   31:     (1)	For each wolf:
;   32: 
;   33: 	Lose a food unit.  Die if 0 food units and remove.
;   34: 
;   35: 	Eat a rabbit if there is one in an adjacent location by moving
;   36: 	into the rabbit's location.  Increase the wolf's food units
;   37: 	by 6 and remove the rabbit.
;   38: 
;   39: 	Otherwise, randomly choose to move into an adjacent empty
;   40: 	location, or stay put.
;   41: 
;   42: 	If wolf reproduction time (T = 12,24,36,...), split and leave
;   43: 	behind an offspring in the previous location.  Each split wolf
;   44: 	has half (DIV 2) the food units.  If there was no move, the
;   45: 	baby was stillborn, but the food units are still halved.
;   46: 
;   47:     (2)	For each rabbit:
;   48: 
;   49: 	Randomly choose to move into an adjacent empty, or stay put.
;   50: 
;   51: 	If rabbit reproduction time (T = 5,10,15,...), split and leave
;   52: 	behind an offspring in the previous location.  If there was no
;   53: 	move, the baby was stillborn.
;   54: 
;   55: 	The simulation ends when all the wolves are dead or all the
;   56: 	rabbits are eaten.
;   57: 
;   58: 	The island is printed at times T = 0,1,2,3,4,5,6,7,8,9,10,
;   59: 	15,20,25,30,...,80.  A message is printed whenever a wolf is
;   60: 	born or dies, and whenever a rabbit is born or is eaten.
;   61: }
;   62: 
;   63: CONST
;   64:     size            = 9;	    {size of island}
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
;   77: 	{Contents each each island location.  Each time a wolf or
;   78: 	 rabbit moves, newwolf or newrabbit is initially placed in
;   79: 	 the new location.  This prevents a wolf or rabbit from
;   80: 	 being processed again in its new location during the same
;   81: 	 time period.}
;   82: 
;   83: VAR
;   84:     island     : ARRAY [index, index] OF contents;
;   85: 				{Wolf Island with border}
;   86:     foodunits  : ARRAY [1..size, 1..size] OF posint;
;   87: 				{wolves' food unit matrix}
;   88:     printtimes : ARRAY [1..maxprinttimes] OF posint;
;   89: 				{times to print island}
;   90: 
;   91:     numwolves, numrabbits : posint;	    {no. of wolves and rabbits}
;   92:     numprinttimes         : posint;     {no. of print times}
;   93:     t      	              : posint;     {time}
;   94:     xpt  : 1..maxprinttimes;     	{print times index}
;   95:     seed : posint;               	{random number seed}
;   96: 
;   97:     rowoffset : ARRAY [0..4] OF -1..+1;
;   98:     coloffset : ARRAY [0..4] OF -1..+1;
;   99: 	{Row and column offsets.  When added to the current row and
;  100: 	 column of a wolf's or rabbit's location, gives the row and
;  101: 	 column of the same or an adjacent location.}
;  102: 
;  103: 
;  104: PROCEDURE Initialize;
;  105: 
;  106:     {Initialize all arrays.}
;  107: 
;  108:     VAR
;  109: 	i        : posint;
;  110: 	row, col : index;
;  111: 
;  112:     BEGIN

i_014	EQU	<WORD PTR [bp-4]>
row_015	EQU	<WORD PTR [bp-8]>
col_016	EQU	<WORD PTR [bp-12]>

initialize_013	PROC

	push	bp
	mov		bp,sp
	sub		sp,12
;  113: 
;  114: 	{Initialize the island and wolf food matrices.}
;  115: 	FOR i := 0 TO max DO BEGIN
	mov		ax,0
	mov		WORD PTR i_014,ax
$L_017:
	mov		ax,10
	cmp		WORD PTR i_014,ax
	jle		$L_018
	jmp		$L_019
$L_018:
;  116: 	    island[0,   i] := border;
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,0
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR i_014
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,5
	pop		bx
	mov		WORD PTR [bx],ax
;  117: 	    island[max, i] := border;
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,10
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR i_014
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,5
	pop		bx
	mov		WORD PTR [bx],ax
;  118: 	    island[i, 0]   := border;
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,WORD PTR i_014
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,0
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,5
	pop		bx
	mov		WORD PTR [bx],ax
;  119: 	    island[i, max] := border;
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,WORD PTR i_014
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,10
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,5
	pop		bx
	mov		WORD PTR [bx],ax
;  120: 	END;
	inc		WORD PTR i_014
	jmp		$L_017
$L_019:
	dec		WORD PTR i_014
;  121: 	FOR row := 1 TO size DO BEGIN
	mov		ax,1
	mov		WORD PTR row_015,ax
$L_020:
	mov		ax,9
	cmp		WORD PTR row_015,ax
	jle		$L_021
	jmp		$L_022
$L_021:
;  122: 	    FOR col := 1 TO size DO BEGIN
	mov		ax,1
	mov		WORD PTR col_016,ax
$L_023:
	mov		ax,9
	cmp		WORD PTR col_016,ax
	jle		$L_024
	jmp		$L_025
$L_024:
;  123: 		island[row, col]    := empty;
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,WORD PTR row_015
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR col_016
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,4
	pop		bx
	mov		WORD PTR [bx],ax
;  124: 		foodunits[row, col] := 0;
	lea		ax,WORD PTR foodunits_003
	push	ax
	mov		ax,WORD PTR row_015
	sub		ax,1
	mov		dx,36
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR col_016
	sub		ax,1
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,0
	pop		bx
	mov		WORD PTR [bx],ax
;  125: 	    END;
	inc		WORD PTR col_016
	jmp		$L_023
$L_025:
	dec		WORD PTR col_016
;  126: 	END;
	inc		WORD PTR row_015
	jmp		$L_020
$L_022:
	dec		WORD PTR row_015
;  127: 
;  128: 	{Place wolves on the island.}
;  129: 	read(numwolves);
	lea		ax,WORD PTR numwolves_005
	push	ax
	call	_read_integer
	pop		bx
	mov		WORD PTR [bx],ax
;  130: 	FOR i := 1 TO numwolves DO BEGIN
	mov		ax,1
	mov		WORD PTR i_014,ax
$L_026:
	mov		ax,WORD PTR numwolves_005
	cmp		WORD PTR i_014,ax
	jle		$L_027
	jmp		$L_028
$L_027:
;  131: 	    read(row, col);
	lea		ax,WORD PTR row_015
	push	ax
	call	_read_integer
	pop		bx
	mov		WORD PTR [bx],ax
	lea		ax,WORD PTR col_016
	push	ax
	call	_read_integer
	pop		bx
	mov		WORD PTR [bx],ax
;  132: 	    island[row, col]    := wolf;
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,WORD PTR row_015
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR col_016
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,0
	pop		bx
	mov		WORD PTR [bx],ax
;  133: 	    foodunits[row, col] := initfoodunits;
	lea		ax,WORD PTR foodunits_003
	push	ax
	mov		ax,WORD PTR row_015
	sub		ax,1
	mov		dx,36
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR col_016
	sub		ax,1
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,6
	pop		bx
	mov		WORD PTR [bx],ax
;  134: 	END;
	inc		WORD PTR i_014
	jmp		$L_026
$L_028:
	dec		WORD PTR i_014
;  135: 
;  136: 	{Place rabbits on the island.}
;  137: 	read(numrabbits);
	lea		ax,WORD PTR numrabbits_006
	push	ax
	call	_read_integer
	pop		bx
	mov		WORD PTR [bx],ax
;  138: 	FOR i := 1 TO numrabbits DO BEGIN
	mov		ax,1
	mov		WORD PTR i_014,ax
$L_029:
	mov		ax,WORD PTR numrabbits_006
	cmp		WORD PTR i_014,ax
	jle		$L_030
	jmp		$L_031
$L_030:
;  139: 	    read(row, col);
	lea		ax,WORD PTR row_015
	push	ax
	call	_read_integer
	pop		bx
	mov		WORD PTR [bx],ax
	lea		ax,WORD PTR col_016
	push	ax
	call	_read_integer
	pop		bx
	mov		WORD PTR [bx],ax
;  140: 	    island[row, col] := rabbit;
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,WORD PTR row_015
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR col_016
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,1
	pop		bx
	mov		WORD PTR [bx],ax
;  141: 	END;
	inc		WORD PTR i_014
	jmp		$L_029
$L_031:
	dec		WORD PTR i_014
;  142: 
;  143: 	{Read print times.}
;  144: 	read(numprinttimes);
	lea		ax,WORD PTR numprinttimes_007
	push	ax
	call	_read_integer
	pop		bx
	mov		WORD PTR [bx],ax
;  145: 	FOR i := 1 TO numprinttimes DO BEGIN
	mov		ax,1
	mov		WORD PTR i_014,ax
$L_032:
	mov		ax,WORD PTR numprinttimes_007
	cmp		WORD PTR i_014,ax
	jle		$L_033
	jmp		$L_034
$L_033:
;  146: 	    read(printtimes[i]);
	lea		ax,WORD PTR printtimes_004
	push	ax
	mov		ax,WORD PTR i_014
	sub		ax,1
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	call	_read_integer
	pop		bx
	mov		WORD PTR [bx],ax
;  147: 	END;
	inc		WORD PTR i_014
	jmp		$L_032
$L_034:
	dec		WORD PTR i_014
;  148: 
;  149: 	{Initialize the row and column offsets for moves.}
;  150: 	rowoffset[0] :=  0;  coloffset[0] :=  0;    {stay put}
	lea		ax,WORD PTR rowoffset_011
	push	ax
	mov		ax,0
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,0
	pop		bx
	mov		WORD PTR [bx],ax
	lea		ax,WORD PTR coloffset_012
	push	ax
	mov		ax,0
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,0
	pop		bx
	mov		WORD PTR [bx],ax
;  151: 	rowoffset[1] := -1;  coloffset[1] :=  0;    {up}
	lea		ax,WORD PTR rowoffset_011
	push	ax
	mov		ax,1
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,1
	neg		ax
	pop		bx
	mov		WORD PTR [bx],ax
	lea		ax,WORD PTR coloffset_012
	push	ax
	mov		ax,1
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,0
	pop		bx
	mov		WORD PTR [bx],ax
;  152: 	rowoffset[2] :=  0;  coloffset[2] := -1;    {left}
	lea		ax,WORD PTR rowoffset_011
	push	ax
	mov		ax,2
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,0
	pop		bx
	mov		WORD PTR [bx],ax
	lea		ax,WORD PTR coloffset_012
	push	ax
	mov		ax,2
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,1
	neg		ax
	pop		bx
	mov		WORD PTR [bx],ax
;  153: 	rowoffset[3] :=  0;  coloffset[3] := +1;    {right}
	lea		ax,WORD PTR rowoffset_011
	push	ax
	mov		ax,3
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,0
	pop		bx
	mov		WORD PTR [bx],ax
	lea		ax,WORD PTR coloffset_012
	push	ax
	mov		ax,3
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,1
	pop		bx
	mov		WORD PTR [bx],ax
;  154: 	rowoffset[4] := +1;  coloffset[4] :=  0;    {down}
	lea		ax,WORD PTR rowoffset_011
	push	ax
	mov		ax,4
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,1
	pop		bx
	mov		WORD PTR [bx],ax
	lea		ax,WORD PTR coloffset_012
	push	ax
	mov		ax,4
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,0
	pop		bx
	mov		WORD PTR [bx],ax
;  155:     END {Initialize};
	mov		sp,bp
	pop		bp
	ret		2

initialize_013	ENDP
;  156: 
;  157: 
;  158: FUNCTION random (limit : posint) : posint;
;  159: 
;  160:     {Return a random integer from 0..limit-1.}
;  161: 
;  162:     CONST
;  163: 	multiplier = 21;
;  164: 	increment  = 77;
;  165: 	divisor    = 1024;
;  166: 
;  167:     BEGIN

limit_036	EQU	<WORD PTR [bp+6]>

random_035	PROC

	push	bp
	mov		bp,sp
	sub		sp,4
;  168: 	seed   := (seed*multiplier + increment) MOD divisor;
	mov		ax,WORD PTR seed_010
	push	ax
	mov		ax,21
	pop		dx
	imul	dx
	push	ax
	mov		ax,77
	pop		dx
	add		ax,dx
	push	ax
	mov		ax,1024
	mov		cx,ax
	pop		ax
	sub		dx,dx
	idiv	cx
	mov		ax,dx
	mov		WORD PTR seed_010,ax
;  169: 	random := (seed*limit) DIV divisor;
	lea		ax,$RETURN_VALUE
	push	ax
	mov		ax,WORD PTR seed_010
	push	ax
	mov		ax,WORD PTR limit_036
	pop		dx
	imul	dx
	push	ax
	mov		ax,1024
	mov		cx,ax
	pop		ax
	sub		dx,dx
	idiv	cx
	pop		bx
	mov		WORD PTR [bx],ax
;  170:     END {random};
	mov		ax,$RETURN_VALUE
	mov		sp,bp
	pop		bp
	ret		6

random_035	ENDP
;  171: 
;  172: 
;  173: PROCEDURE NewLocation (creature : contents;
;  174: 		       oldrow, oldcol : index;
;  175: 		       VAR newrow, newcol : index);
;  176: 
;  177:     {Find a new location for the creature currently at
;  178:      island[oldrow, oldcol].}
;  179: 
;  180: 
;  181:     VAR
;  182: 	adj  : 0..4;	    {adjacent locations index}
;  183: 	what : contents;    {contents of location}
;  184: 	done : boolean;
;  185: 
;  186:     BEGIN

creature_038	EQU	<WORD PTR [bp+22]>
oldrow_039	EQU	<WORD PTR [bp+18]>
oldcol_040	EQU	<WORD PTR [bp+14]>
newrow_041	EQU	<WORD PTR [bp+10]>
newcol_042	EQU	<WORD PTR [bp+6]>
adj_043	EQU	<WORD PTR [bp-4]>
what_044	EQU	<WORD PTR [bp-8]>
done_045	EQU	<WORD PTR [bp-12]>

newlocation_037	PROC

	push	bp
	mov		bp,sp
	sub		sp,12
;  187: 	done := false;
	mov		ax,0
	mov		WORD PTR done_045,ax
;  188: 
;  189: 	{A wolf first tries to eat a rabbit.
;  190: 	 Check adjacent locations.}
;  191: 	IF creature = wolf THEN BEGIN
	mov		ax,WORD PTR creature_038
	push	ax
	mov		ax,0
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_048
	sub		ax,ax
$L_048:
	cmp		ax,1
	je		$L_046
	jmp		$L_047
$L_046:
;  192: 	    adj := 0;
	mov		ax,0
	mov		WORD PTR adj_043,ax
;  193: 	    REPEAT
$L_049:
;  194: 		adj := adj + 1;
	mov		ax,WORD PTR adj_043
	push	ax
	mov		ax,1
	pop		dx
	add		ax,dx
	mov		WORD PTR adj_043,ax
;  195: 		newrow := oldrow + rowoffset[adj];
	mov		ax,WORD PTR newrow_041
	push	ax
	mov		ax,WORD PTR oldrow_039
	push	ax
	lea		ax,WORD PTR rowoffset_011
	push	ax
	mov		ax,WORD PTR adj_043
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	pop		dx
	add		ax,dx
	pop		bx
	mov		WORD PTR [bx],ax
;  196: 		newcol := oldcol + coloffset[adj];
	mov		ax,WORD PTR newcol_042
	push	ax
	mov		ax,WORD PTR oldcol_040
	push	ax
	lea		ax,WORD PTR coloffset_012
	push	ax
	mov		ax,WORD PTR adj_043
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	pop		dx
	add		ax,dx
	pop		bx
	mov		WORD PTR [bx],ax
;  197: 		what   := island[newrow, newcol];
	lea		ax,WORD PTR island_002
	push	ax
	mov		bx,WORD PTR newrow_041
	mov		ax,WORD PTR [bx]
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		bx,WORD PTR newcol_042
	mov		ax,WORD PTR [bx]
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	mov		WORD PTR what_044,ax
;  198: 		done   := what = rabbit;
	mov		ax,WORD PTR what_044
	push	ax
	mov		ax,1
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_051
	sub		ax,ax
$L_051:
	mov		WORD PTR done_045,ax
;  199: 	    UNTIL done OR (adj = 4);
	mov		ax,WORD PTR done_045
	push	ax
	mov		ax,WORD PTR adj_043
	push	ax
	mov		ax,4
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_052
	sub		ax,ax
$L_052:
	pop		dx
	or		ax,dx
	cmp		ax,1
	je		$L_050
	jmp		$L_049
$L_050:
;  200: 	END;
$L_047:
;  201: 
;  202: 	{Move randomly into an adjacent location or stay put.}
;  203: 	IF NOT done THEN BEGIN
	mov		ax,WORD PTR done_045
	xor		ax,1
	cmp		ax,1
	je		$L_053
	jmp		$L_054
$L_053:
;  204: 	    REPEAT
$L_055:
;  205: 		adj := random(5);
	mov		ax,5
	push	ax
	push	$STATIC_LINK
	call	random_035
	mov		WORD PTR adj_043,ax
;  206: 		newrow := oldrow + rowoffset[adj];
	mov		ax,WORD PTR newrow_041
	push	ax
	mov		ax,WORD PTR oldrow_039
	push	ax
	lea		ax,WORD PTR rowoffset_011
	push	ax
	mov		ax,WORD PTR adj_043
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	pop		dx
	add		ax,dx
	pop		bx
	mov		WORD PTR [bx],ax
;  207: 		newcol := oldcol + coloffset[adj];
	mov		ax,WORD PTR newcol_042
	push	ax
	mov		ax,WORD PTR oldcol_040
	push	ax
	lea		ax,WORD PTR coloffset_012
	push	ax
	mov		ax,WORD PTR adj_043
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	pop		dx
	add		ax,dx
	pop		bx
	mov		WORD PTR [bx],ax
;  208: 		what   := island[newrow, newcol];
	lea		ax,WORD PTR island_002
	push	ax
	mov		bx,WORD PTR newrow_041
	mov		ax,WORD PTR [bx]
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		bx,WORD PTR newcol_042
	mov		ax,WORD PTR [bx]
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	mov		WORD PTR what_044,ax
;  209: 	    UNTIL    (what = empty)
	mov		ax,WORD PTR what_044
	push	ax
	mov		ax,4
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_057
	sub		ax,ax
$L_057:
;  210: 		  OR ((newrow = oldrow) AND (newcol = oldcol));
	push	ax
	mov		bx,WORD PTR newrow_041
	mov		ax,WORD PTR [bx]
	push	ax
	mov		ax,WORD PTR oldrow_039
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_058
	sub		ax,ax
$L_058:
	push	ax
	mov		bx,WORD PTR newcol_042
	mov		ax,WORD PTR [bx]
	push	ax
	mov		ax,WORD PTR oldcol_040
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_059
	sub		ax,ax
$L_059:
	pop		dx
	and		ax,dx
	pop		dx
	or		ax,dx
	cmp		ax,1
	je		$L_056
	jmp		$L_055
$L_056:
;  211: 	END;
$L_054:
;  212:     END {NewLocation};
	mov		sp,bp
	pop		bp
	ret		22

newlocation_037	ENDP
;  213: 
;  214: 
;  215: PROCEDURE ProcessWolf (oldrow, oldcol : index);
;  216: 
;  217:     {Process the wolf located at island[oldrow, oldcol].}
;  218: 
;  219:     VAR
;  220: 	newrow, newcol : index;	    {new row and column}
;  221: 	moved : boolean;            {true iff wolf moved}
;  222: 
;  223:     BEGIN

oldrow_061	EQU	<WORD PTR [bp+10]>
oldcol_062	EQU	<WORD PTR [bp+6]>
newrow_063	EQU	<WORD PTR [bp-4]>
newcol_064	EQU	<WORD PTR [bp-8]>
moved_065	EQU	<WORD PTR [bp-12]>

processwolf_060	PROC

	push	bp
	mov		bp,sp
	sub		sp,12
;  224: 
;  225: 	{Lose a food unit.}
;  226: 	foodunits[oldrow, oldcol] := foodunits[oldrow, oldcol] - 1;
	lea		ax,WORD PTR foodunits_003
	push	ax
	mov		ax,WORD PTR oldrow_061
	sub		ax,1
	mov		dx,36
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR oldcol_062
	sub		ax,1
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	lea		ax,WORD PTR foodunits_003
	push	ax
	mov		ax,WORD PTR oldrow_061
	sub		ax,1
	mov		dx,36
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR oldcol_062
	sub		ax,1
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	push	ax
	mov		ax,1
	pop		dx
	sub		dx,ax
	mov		ax,dx
	pop		bx
	mov		WORD PTR [bx],ax
;  227: 
;  228: 	IF foodunits[oldrow, oldcol] = 0 THEN BEGIN
	lea		ax,WORD PTR foodunits_003
	push	ax
	mov		ax,WORD PTR oldrow_061
	sub		ax,1
	mov		dx,36
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR oldcol_062
	sub		ax,1
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	push	ax
	mov		ax,0
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_068
	sub		ax,ax
$L_068:
	cmp		ax,1
	je		$L_066
	jmp		$L_067
$L_066:
;  229: 
;  230: 	    {Die of starvation.}
;  231: 	    island[oldrow, oldcol] := empty;
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,WORD PTR oldrow_061
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR oldcol_062
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,4
	pop		bx
	mov		WORD PTR [bx],ax
;  232: 	    numwolves := numwolves - 1;
	mov		ax,WORD PTR numwolves_005
	push	ax
	mov		ax,1
	pop		dx
	sub		dx,ax
	mov		ax,dx
	mov		WORD PTR numwolves_005,ax
;  233: 	    writeln('t =', t:4, ' : Wolf died at ',
	lea		ax,WORD PTR $S_069
	push	ax
	mov		ax,0
	push	ax
	mov		ax,3
	push	ax
	call	_write_string
	add		sp,6
	mov		ax,WORD PTR t_008
	push	ax
	mov		ax,4
	push	ax
	call	_write_integer
	add		sp,4
	lea		ax,WORD PTR $S_070
	push	ax
	mov		ax,0
	push	ax
	mov		ax,16
	push	ax
	call	_write_string
	add		sp,6
;  234: 		    '[', oldrow:1, ', ', oldcol:1, ']');
	mov		ax,'['
	push	ax
	mov		ax,0
	push	ax
	call	_write_char
	add		sp,4
	mov		ax,WORD PTR oldrow_061
	push	ax
	mov		ax,1
	push	ax
	call	_write_integer
	add		sp,4
	lea		ax,WORD PTR $S_071
	push	ax
	mov		ax,0
	push	ax
	mov		ax,2
	push	ax
	call	_write_string
	add		sp,6
	mov		ax,WORD PTR oldcol_062
	push	ax
	mov		ax,1
	push	ax
	call	_write_integer
	add		sp,4
	mov		ax,']'
	push	ax
	mov		ax,0
	push	ax
	call	_write_char
	add		sp,4
	call	_write_line
;  235: 	END
;  236: 	ELSE BEGIN
	jmp		$L_072
$L_067:
;  237: 
;  238: 	    {Move to adjacent location, or stay put.}
;  239: 	    NewLocation(wolf, oldrow, oldcol, newrow, newcol);
	mov		ax,0
	push	ax
	mov		ax,WORD PTR oldrow_061
	push	ax
	mov		ax,WORD PTR oldcol_062
	push	ax
	lea		ax,WORD PTR newrow_063
	push	ax
	lea		ax,WORD PTR newcol_064
	push	ax
	push	$STATIC_LINK
	call	newlocation_037
;  240: 	    moved := (newrow <> oldrow) OR (newcol <> oldcol);
	mov		ax,WORD PTR newrow_063
	push	ax
	mov		ax,WORD PTR oldrow_061
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jne		$L_073
	sub		ax,ax
$L_073:
	push	ax
	mov		ax,WORD PTR newcol_064
	push	ax
	mov		ax,WORD PTR oldcol_062
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jne		$L_074
	sub		ax,ax
$L_074:
	pop		dx
	or		ax,dx
	mov		WORD PTR moved_065,ax
;  241: 
;  242: 	    IF moved THEN BEGIN
	mov		ax,WORD PTR moved_065
	cmp		ax,1
	je		$L_075
	jmp		$L_076
$L_075:
;  243: 
;  244: 		{If there's a rabbit there, eat it.}
;  245: 		IF island[newrow, newcol] = rabbit THEN BEGIN
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,WORD PTR newrow_063
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR newcol_064
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	push	ax
	mov		ax,1
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_079
	sub		ax,ax
$L_079:
	cmp		ax,1
	je		$L_077
	jmp		$L_078
$L_077:
;  246: 		    foodunits[oldrow, oldcol] :=
	lea		ax,WORD PTR foodunits_003
	push	ax
	mov		ax,WORD PTR oldrow_061
	sub		ax,1
	mov		dx,36
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR oldcol_062
	sub		ax,1
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
;  247: 			foodunits[oldrow, oldcol] + rabbitfoodunits;
	lea		ax,WORD PTR foodunits_003
	push	ax
	mov		ax,WORD PTR oldrow_061
	sub		ax,1
	mov		dx,36
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR oldcol_062
	sub		ax,1
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	push	ax
	mov		ax,6
	pop		dx
	add		ax,dx
	pop		bx
	mov		WORD PTR [bx],ax
;  248: 		    numrabbits := numrabbits - 1;
	mov		ax,WORD PTR numrabbits_006
	push	ax
	mov		ax,1
	pop		dx
	sub		dx,ax
	mov		ax,dx
	mov		WORD PTR numrabbits_006,ax
;  249: 		    writeln('t =', t:4, ' : Rabbit eaten at ',
	lea		ax,WORD PTR $S_069
	push	ax
	mov		ax,0
	push	ax
	mov		ax,3
	push	ax
	call	_write_string
	add		sp,6
	mov		ax,WORD PTR t_008
	push	ax
	mov		ax,4
	push	ax
	call	_write_integer
	add		sp,4
	lea		ax,WORD PTR $S_080
	push	ax
	mov		ax,0
	push	ax
	mov		ax,19
	push	ax
	call	_write_string
	add		sp,6
;  250: 			    '[', newrow:1, ', ', newcol:1, ']');
	mov		ax,'['
	push	ax
	mov		ax,0
	push	ax
	call	_write_char
	add		sp,4
	mov		ax,WORD PTR newrow_063
	push	ax
	mov		ax,1
	push	ax
	call	_write_integer
	add		sp,4
	lea		ax,WORD PTR $S_071
	push	ax
	mov		ax,0
	push	ax
	mov		ax,2
	push	ax
	call	_write_string
	add		sp,6
	mov		ax,WORD PTR newcol_064
	push	ax
	mov		ax,1
	push	ax
	call	_write_integer
	add		sp,4
	mov		ax,']'
	push	ax
	mov		ax,0
	push	ax
	call	_write_char
	add		sp,4
	call	_write_line
;  251: 		END;
$L_078:
;  252: 
;  253: 		{Set new (or same) location.}
;  254: 		island[newrow, newcol] := newwolf;
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,WORD PTR newrow_063
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR newcol_064
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,2
	pop		bx
	mov		WORD PTR [bx],ax
;  255: 		island[oldrow, oldcol] := empty;
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,WORD PTR oldrow_061
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR oldcol_062
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,4
	pop		bx
	mov		WORD PTR [bx],ax
;  256: 		foodunits[newrow, newcol] := foodunits[oldrow, oldcol];
	lea		ax,WORD PTR foodunits_003
	push	ax
	mov		ax,WORD PTR newrow_063
	sub		ax,1
	mov		dx,36
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR newcol_064
	sub		ax,1
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	lea		ax,WORD PTR foodunits_003
	push	ax
	mov		ax,WORD PTR oldrow_061
	sub		ax,1
	mov		dx,36
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR oldcol_062
	sub		ax,1
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	pop		bx
	mov		WORD PTR [bx],ax
;  257: 		foodunits[oldrow, oldcol] := 0;
	lea		ax,WORD PTR foodunits_003
	push	ax
	mov		ax,WORD PTR oldrow_061
	sub		ax,1
	mov		dx,36
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR oldcol_062
	sub		ax,1
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,0
	pop		bx
	mov		WORD PTR [bx],ax
;  258: 	    END;
$L_076:
;  259: 
;  260: 	    {Wolf reproduction time?}
;  261: 	    IF     ((t MOD wolfreprotime) = 0)
	mov		ax,WORD PTR t_008
	push	ax
	mov		ax,12
	mov		cx,ax
	pop		ax
	sub		dx,dx
	idiv	cx
	mov		ax,dx
	push	ax
	mov		ax,0
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_083
	sub		ax,ax
$L_083:
;  262: 	       AND (foodunits[newrow, newcol] > 1) THEN BEGIN
	push	ax
	lea		ax,WORD PTR foodunits_003
	push	ax
	mov		ax,WORD PTR newrow_063
	sub		ax,1
	mov		dx,36
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR newcol_064
	sub		ax,1
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	push	ax
	mov		ax,1
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jg		$L_084
	sub		ax,ax
$L_084:
	pop		dx
	and		ax,dx
	cmp		ax,1
	je		$L_081
	jmp		$L_082
$L_081:
;  263: 		foodunits[newrow, newcol] :=
	lea		ax,WORD PTR foodunits_003
	push	ax
	mov		ax,WORD PTR newrow_063
	sub		ax,1
	mov		dx,36
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR newcol_064
	sub		ax,1
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
;  264: 		    foodunits[newrow, newcol] DIV 2;
	lea		ax,WORD PTR foodunits_003
	push	ax
	mov		ax,WORD PTR newrow_063
	sub		ax,1
	mov		dx,36
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR newcol_064
	sub		ax,1
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	push	ax
	mov		ax,2
	mov		cx,ax
	pop		ax
	sub		dx,dx
	idiv	cx
	pop		bx
	mov		WORD PTR [bx],ax
;  265: 
;  266: 		{If moved, then leave behind an offspring.}
;  267: 		IF moved THEN BEGIN
	mov		ax,WORD PTR moved_065
	cmp		ax,1
	je		$L_085
	jmp		$L_086
$L_085:
;  268: 		    island[oldrow, oldcol] := newwolf;
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,WORD PTR oldrow_061
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR oldcol_062
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,2
	pop		bx
	mov		WORD PTR [bx],ax
;  269: 		    foodunits[oldrow, oldcol] :=
	lea		ax,WORD PTR foodunits_003
	push	ax
	mov		ax,WORD PTR oldrow_061
	sub		ax,1
	mov		dx,36
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR oldcol_062
	sub		ax,1
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
;  270: 			foodunits[newrow, newcol];
	lea		ax,WORD PTR foodunits_003
	push	ax
	mov		ax,WORD PTR newrow_063
	sub		ax,1
	mov		dx,36
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR newcol_064
	sub		ax,1
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	pop		bx
	mov		WORD PTR [bx],ax
;  271: 		    numwolves := numwolves + 1;
	mov		ax,WORD PTR numwolves_005
	push	ax
	mov		ax,1
	pop		dx
	add		ax,dx
	mov		WORD PTR numwolves_005,ax
;  272: 		    writeln('t =', t:4, ' : Wolf born at ',
	lea		ax,WORD PTR $S_069
	push	ax
	mov		ax,0
	push	ax
	mov		ax,3
	push	ax
	call	_write_string
	add		sp,6
	mov		ax,WORD PTR t_008
	push	ax
	mov		ax,4
	push	ax
	call	_write_integer
	add		sp,4
	lea		ax,WORD PTR $S_087
	push	ax
	mov		ax,0
	push	ax
	mov		ax,16
	push	ax
	call	_write_string
	add		sp,6
;  273: 			    '[', oldrow:1, ', ', oldcol:1, ']');
	mov		ax,'['
	push	ax
	mov		ax,0
	push	ax
	call	_write_char
	add		sp,4
	mov		ax,WORD PTR oldrow_061
	push	ax
	mov		ax,1
	push	ax
	call	_write_integer
	add		sp,4
	lea		ax,WORD PTR $S_071
	push	ax
	mov		ax,0
	push	ax
	mov		ax,2
	push	ax
	call	_write_string
	add		sp,6
	mov		ax,WORD PTR oldcol_062
	push	ax
	mov		ax,1
	push	ax
	call	_write_integer
	add		sp,4
	mov		ax,']'
	push	ax
	mov		ax,0
	push	ax
	call	_write_char
	add		sp,4
	call	_write_line
;  274: 		END;
$L_086:
;  275: 	    END;
$L_082:
;  276: 	END;
$L_072:
;  277:     END {ProcessWolf};
	mov		sp,bp
	pop		bp
	ret		10

processwolf_060	ENDP
;  278: 
;  279: 
;  280: PROCEDURE ProcessRabbit (oldrow, oldcol : index);
;  281: 
;  282:     {Process the rabbit located at island[oldrow, oldcol].}
;  283: 
;  284:     VAR
;  285: 	newrow, newcol : index;	    {new row and column}
;  286: 	moved : boolean;            {true iff rabbit moved}
;  287: 
;  288:     BEGIN

oldrow_089	EQU	<WORD PTR [bp+10]>
oldcol_090	EQU	<WORD PTR [bp+6]>
newrow_091	EQU	<WORD PTR [bp-4]>
newcol_092	EQU	<WORD PTR [bp-8]>
moved_093	EQU	<WORD PTR [bp-12]>

processrabbit_088	PROC

	push	bp
	mov		bp,sp
	sub		sp,12
;  289: 
;  290: 	{Move to adjacent location, or stay put.}
;  291: 	NewLocation(rabbit, oldrow, oldcol, newrow, newcol);
	mov		ax,1
	push	ax
	mov		ax,WORD PTR oldrow_089
	push	ax
	mov		ax,WORD PTR oldcol_090
	push	ax
	lea		ax,WORD PTR newrow_091
	push	ax
	lea		ax,WORD PTR newcol_092
	push	ax
	push	$STATIC_LINK
	call	newlocation_037
;  292: 	moved := (newrow <> oldrow) OR (newcol <> oldcol);
	mov		ax,WORD PTR newrow_091
	push	ax
	mov		ax,WORD PTR oldrow_089
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jne		$L_094
	sub		ax,ax
$L_094:
	push	ax
	mov		ax,WORD PTR newcol_092
	push	ax
	mov		ax,WORD PTR oldcol_090
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jne		$L_095
	sub		ax,ax
$L_095:
	pop		dx
	or		ax,dx
	mov		WORD PTR moved_093,ax
;  293: 	IF moved THEN BEGIN
	mov		ax,WORD PTR moved_093
	cmp		ax,1
	je		$L_096
	jmp		$L_097
$L_096:
;  294: 	    island[newrow, newcol] := newrabbit;
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,WORD PTR newrow_091
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR newcol_092
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,3
	pop		bx
	mov		WORD PTR [bx],ax
;  295: 	    island[oldrow, oldcol] := empty;
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,WORD PTR oldrow_089
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR oldcol_090
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,4
	pop		bx
	mov		WORD PTR [bx],ax
;  296: 	END;
$L_097:
;  297: 
;  298: 	{Rabbit reproduction time?}
;  299: 	IF (t MOD rabbitreprotime) = 0 THEN BEGIN
	mov		ax,WORD PTR t_008
	push	ax
	mov		ax,5
	mov		cx,ax
	pop		ax
	sub		dx,dx
	idiv	cx
	mov		ax,dx
	push	ax
	mov		ax,0
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_100
	sub		ax,ax
$L_100:
	cmp		ax,1
	je		$L_098
	jmp		$L_099
$L_098:
;  300: 
;  301: 	    {If moved, then leave behind an offspring.}
;  302: 	    IF moved THEN BEGIN
	mov		ax,WORD PTR moved_093
	cmp		ax,1
	je		$L_101
	jmp		$L_102
$L_101:
;  303: 		island[oldrow, oldcol] := newrabbit;
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,WORD PTR oldrow_089
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR oldcol_090
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,3
	pop		bx
	mov		WORD PTR [bx],ax
;  304: 		numrabbits := numrabbits + 1;
	mov		ax,WORD PTR numrabbits_006
	push	ax
	mov		ax,1
	pop		dx
	add		ax,dx
	mov		WORD PTR numrabbits_006,ax
;  305: 		writeln('t =', t:4, ' : Rabbit born at ',
	lea		ax,WORD PTR $S_069
	push	ax
	mov		ax,0
	push	ax
	mov		ax,3
	push	ax
	call	_write_string
	add		sp,6
	mov		ax,WORD PTR t_008
	push	ax
	mov		ax,4
	push	ax
	call	_write_integer
	add		sp,4
	lea		ax,WORD PTR $S_103
	push	ax
	mov		ax,0
	push	ax
	mov		ax,18
	push	ax
	call	_write_string
	add		sp,6
;  306: 			'[', oldrow:1, ', ', oldcol:1, ']');
	mov		ax,'['
	push	ax
	mov		ax,0
	push	ax
	call	_write_char
	add		sp,4
	mov		ax,WORD PTR oldrow_089
	push	ax
	mov		ax,1
	push	ax
	call	_write_integer
	add		sp,4
	lea		ax,WORD PTR $S_071
	push	ax
	mov		ax,0
	push	ax
	mov		ax,2
	push	ax
	call	_write_string
	add		sp,6
	mov		ax,WORD PTR oldcol_090
	push	ax
	mov		ax,1
	push	ax
	call	_write_integer
	add		sp,4
	mov		ax,']'
	push	ax
	mov		ax,0
	push	ax
	call	_write_char
	add		sp,4
	call	_write_line
;  307: 	    END;
$L_102:
;  308: 	END;
$L_099:
;  309:     END {ProcessRabbit};
	mov		sp,bp
	pop		bp
	ret		10

processrabbit_088	ENDP
;  310: 
;  311: 
;  312: PROCEDURE EventsOccur;
;  313: 
;  314:     {Perform the events that occur for each time unit.}
;  315: 
;  316:     VAR
;  317: 	row, col : index;
;  318: 
;  319:     BEGIN

row_105	EQU	<WORD PTR [bp-4]>
col_106	EQU	<WORD PTR [bp-8]>

eventsoccur_104	PROC

	push	bp
	mov		bp,sp
	sub		sp,8
;  320: 
;  321: 	{Scan for wolves and process each one in turn.}
;  322: 	FOR row := 1 TO size DO BEGIN
	mov		ax,1
	mov		WORD PTR row_105,ax
$L_107:
	mov		ax,9
	cmp		WORD PTR row_105,ax
	jle		$L_108
	jmp		$L_109
$L_108:
;  323: 	    FOR col := 1 TO size DO BEGIN
	mov		ax,1
	mov		WORD PTR col_106,ax
$L_110:
	mov		ax,9
	cmp		WORD PTR col_106,ax
	jle		$L_111
	jmp		$L_112
$L_111:
;  324: 		IF island[row, col] = wolf THEN BEGIN
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,WORD PTR row_105
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR col_106
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	push	ax
	mov		ax,0
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_115
	sub		ax,ax
$L_115:
	cmp		ax,1
	je		$L_113
	jmp		$L_114
$L_113:
;  325: 		    ProcessWolf(row, col);
	mov		ax,WORD PTR row_105
	push	ax
	mov		ax,WORD PTR col_106
	push	ax
	push	$STATIC_LINK
	call	processwolf_060
;  326: 		END;
$L_114:
;  327: 	    END;
	inc		WORD PTR col_106
	jmp		$L_110
$L_112:
	dec		WORD PTR col_106
;  328: 	END;
	inc		WORD PTR row_105
	jmp		$L_107
$L_109:
	dec		WORD PTR row_105
;  329: 
;  330: 
;  331: 	{Scan for rabbits and process each one in turn.}
;  332: 	FOR row := 1 TO size DO BEGIN
	mov		ax,1
	mov		WORD PTR row_105,ax
$L_116:
	mov		ax,9
	cmp		WORD PTR row_105,ax
	jle		$L_117
	jmp		$L_118
$L_117:
;  333: 	    FOR col := 1 TO size DO BEGIN
	mov		ax,1
	mov		WORD PTR col_106,ax
$L_119:
	mov		ax,9
	cmp		WORD PTR col_106,ax
	jle		$L_120
	jmp		$L_121
$L_120:
;  334: 		IF island[row, col] = rabbit THEN BEGIN
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,WORD PTR row_105
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR col_106
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	push	ax
	mov		ax,1
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_124
	sub		ax,ax
$L_124:
	cmp		ax,1
	je		$L_122
	jmp		$L_123
$L_122:
;  335: 		    ProcessRabbit(row, col);
	mov		ax,WORD PTR row_105
	push	ax
	mov		ax,WORD PTR col_106
	push	ax
	push	$STATIC_LINK
	call	processrabbit_088
;  336: 		END;
$L_123:
;  337: 	    END;
	inc		WORD PTR col_106
	jmp		$L_119
$L_121:
	dec		WORD PTR col_106
;  338: 	END;
	inc		WORD PTR row_105
	jmp		$L_116
$L_118:
	dec		WORD PTR row_105
;  339:     END {EventsOccur};
	mov		sp,bp
	pop		bp
	ret		2

eventsoccur_104	ENDP
;  340: 
;  341: 
;  342: PROCEDURE PrintIsland;
;  343: 
;  344:     {Print the island.}
;  345: 
;  346:     VAR
;  347: 	row, col : index;
;  348: 	cnts     : contents;
;  349: 
;  350:     BEGIN

row_126	EQU	<WORD PTR [bp-4]>
col_127	EQU	<WORD PTR [bp-8]>
cnts_128	EQU	<WORD PTR [bp-12]>

printisland_125	PROC

	push	bp
	mov		bp,sp
	sub		sp,12
;  351: 	writeln;
	call	_write_line
;  352: 	writeln('t =', t:4, ' : Wolf Island');
	lea		ax,WORD PTR $S_069
	push	ax
	mov		ax,0
	push	ax
	mov		ax,3
	push	ax
	call	_write_string
	add		sp,6
	mov		ax,WORD PTR t_008
	push	ax
	mov		ax,4
	push	ax
	call	_write_integer
	add		sp,4
	lea		ax,WORD PTR $S_129
	push	ax
	mov		ax,0
	push	ax
	mov		ax,14
	push	ax
	call	_write_string
	add		sp,6
	call	_write_line
;  353: 	writeln;
	call	_write_line
;  354: 
;  355: 	FOR row := 1 TO size DO BEGIN
	mov		ax,1
	mov		WORD PTR row_126,ax
$L_130:
	mov		ax,9
	cmp		WORD PTR row_126,ax
	jle		$L_131
	jmp		$L_132
$L_131:
;  356: 	    write(' ':10);
	mov		ax,' '
	push	ax
	mov		ax,10
	push	ax
	call	_write_char
	add		sp,4
;  357: 	    FOR col := 1 TO size DO BEGIN
	mov		ax,1
	mov		WORD PTR col_127,ax
$L_133:
	mov		ax,9
	cmp		WORD PTR col_127,ax
	jle		$L_134
	jmp		$L_135
$L_134:
;  358: 		cnts := island[row, col];
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,WORD PTR row_126
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR col_127
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	mov		WORD PTR cnts_128,ax
;  359: 		IF      cnts = empty  THEN write('. ')
	mov		ax,WORD PTR cnts_128
	push	ax
	mov		ax,4
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_138
	sub		ax,ax
$L_138:
	cmp		ax,1
	je		$L_136
	jmp		$L_137
$L_136:
	lea		ax,WORD PTR $S_139
	push	ax
	mov		ax,0
	push	ax
	mov		ax,2
	push	ax
	call	_write_string
	add		sp,6
;  360: 		ELSE IF cnts = wolf   THEN write('W ')
	jmp		$L_140
$L_137:
	mov		ax,WORD PTR cnts_128
	push	ax
	mov		ax,0
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_143
	sub		ax,ax
$L_143:
	cmp		ax,1
	je		$L_141
	jmp		$L_142
$L_141:
	lea		ax,WORD PTR $S_144
	push	ax
	mov		ax,0
	push	ax
	mov		ax,2
	push	ax
	call	_write_string
	add		sp,6
;  361: 		ELSE IF cnts = rabbit THEN write('r ')
	jmp		$L_145
$L_142:
	mov		ax,WORD PTR cnts_128
	push	ax
	mov		ax,1
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_148
	sub		ax,ax
$L_148:
	cmp		ax,1
	je		$L_146
	jmp		$L_147
$L_146:
	lea		ax,WORD PTR $S_149
	push	ax
	mov		ax,0
	push	ax
	mov		ax,2
	push	ax
	call	_write_string
	add		sp,6
;  362: 	    END;
$L_147:
$L_145:
$L_140:
	inc		WORD PTR col_127
	jmp		$L_133
$L_135:
	dec		WORD PTR col_127
;  363: 	    writeln;
	call	_write_line
;  364: 	END;
	inc		WORD PTR row_126
	jmp		$L_130
$L_132:
	dec		WORD PTR row_126
;  365:     END {PrintIsland};
	mov		sp,bp
	pop		bp
	ret		2

printisland_125	ENDP
;  366: 
;  367: 
;  368: PROCEDURE ResetIsland;
;  369: 
;  370:     {Reset the island by setting each newwolf to wolf
;  371:      and each newrabbit to rabbit.}
;  372: 
;  373:     VAR
;  374: 	row, col : index;
;  375: 
;  376:     BEGIN

row_151	EQU	<WORD PTR [bp-4]>
col_152	EQU	<WORD PTR [bp-8]>

resetisland_150	PROC

	push	bp
	mov		bp,sp
	sub		sp,8
;  377: 	FOR row := 1 TO size DO BEGIN
	mov		ax,1
	mov		WORD PTR row_151,ax
$L_153:
	mov		ax,9
	cmp		WORD PTR row_151,ax
	jle		$L_154
	jmp		$L_155
$L_154:
;  378: 	    FOR col := 1 TO size DO BEGIN
	mov		ax,1
	mov		WORD PTR col_152,ax
$L_156:
	mov		ax,9
	cmp		WORD PTR col_152,ax
	jle		$L_157
	jmp		$L_158
$L_157:
;  379: 		IF island[row, col] = newwolf THEN BEGIN
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,WORD PTR row_151
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR col_152
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	push	ax
	mov		ax,2
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_161
	sub		ax,ax
$L_161:
	cmp		ax,1
	je		$L_159
	jmp		$L_160
$L_159:
;  380: 		    island[row, col] := wolf;
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,WORD PTR row_151
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR col_152
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,0
	pop		bx
	mov		WORD PTR [bx],ax
;  381: 		END
;  382: 		ELSE IF island[row, col] = newrabbit THEN BEGIN
	jmp		$L_162
$L_160:
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,WORD PTR row_151
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR col_152
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	push	ax
	mov		ax,3
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_165
	sub		ax,ax
$L_165:
	cmp		ax,1
	je		$L_163
	jmp		$L_164
$L_163:
;  383: 		    island[row, col] := rabbit;
	lea		ax,WORD PTR island_002
	push	ax
	mov		ax,WORD PTR row_151
	mov		dx,44
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,WORD PTR col_152
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,1
	pop		bx
	mov		WORD PTR [bx],ax
;  384: 		END;
$L_164:
$L_162:
;  385: 	    END;
	inc		WORD PTR col_152
	jmp		$L_156
$L_158:
	dec		WORD PTR col_152
;  386: 	END;
	inc		WORD PTR row_151
	jmp		$L_153
$L_155:
	dec		WORD PTR row_151
;  387:     END {ResetIsland};
	mov		sp,bp
	pop		bp
	ret		2

resetisland_150	ENDP
;  388: 
;  389: 
;  390: BEGIN {WolfIsland}

_pascal_main	PROC

	push	bp
	mov		bp,sp
;  391: 
;  392:     Initialize;
	push	bp
	call	initialize_013
;  393: 
;  394:     t   := 0;
	mov		ax,0
	mov		WORD PTR t_008,ax
;  395:     xpt := 1;
	mov		ax,1
	mov		WORD PTR xpt_009,ax
;  396:     read(seed);
	lea		ax,WORD PTR seed_010
	push	ax
	call	_read_integer
	pop		bx
	mov		WORD PTR [bx],ax
;  397: 
;  398:     PrintIsland;
	push	bp
	call	printisland_125
;  399: 
;  400:     {Loop once per time period.}
;  401:     REPEAT
$L_166:
;  402: 	writeln;
	call	_write_line
;  403: 
;  404: 	t := t + 1;
	mov		ax,WORD PTR t_008
	push	ax
	mov		ax,1
	pop		dx
	add		ax,dx
	mov		WORD PTR t_008,ax
;  405: 	EventsOccur;
	push	bp
	call	eventsoccur_104
;  406: 	ResetIsland;
	push	bp
	call	resetisland_150
;  407: 
;  408: 	{Time to print the island?}
;  409: 	IF t = printtimes[xpt] THEN BEGIN
	mov		ax,WORD PTR t_008
	push	ax
	lea		ax,WORD PTR printtimes_004
	push	ax
	mov		ax,WORD PTR xpt_009
	sub		ax,1
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		bx
	mov		ax,WORD PTR [bx]
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_170
	sub		ax,ax
$L_170:
	cmp		ax,1
	je		$L_168
	jmp		$L_169
$L_168:
;  410: 	    PrintIsland;
	push	bp
	call	printisland_125
;  411: 	    xpt := xpt + 1;
	mov		ax,WORD PTR xpt_009
	push	ax
	mov		ax,1
	pop		dx
	add		ax,dx
	mov		WORD PTR xpt_009,ax
;  412: 	END;
$L_169:
;  413:     UNTIL (numwolves = 0) OR (numrabbits = 0)
	mov		ax,WORD PTR numwolves_005
	push	ax
	mov		ax,0
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_171
	sub		ax,ax
$L_171:
	push	ax
	mov		ax,WORD PTR numrabbits_006
	push	ax
	mov		ax,0
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_172
	sub		ax,ax
$L_172:
;  414: 	  OR (xpt > numprinttimes);
	pop		dx
	or		ax,dx
	push	ax
	mov		ax,WORD PTR xpt_009
	push	ax
	mov		ax,WORD PTR numprinttimes_007
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jg		$L_173
	sub		ax,ax
$L_173:
	pop		dx
	or		ax,dx
	cmp		ax,1
	je		$L_167
	jmp		$L_166
$L_167:
;  415: 
;  416:     PrintIsland;
	push	bp
	call	printisland_125
;  417: 
;  418: END {WolfIsland}.

	pop		bp
	ret	

_pascal_main	ENDP

	.DATA

island_002	DB	484 DUP(0)
foodunits_003	DB	324 DUP(0)
printtimes_004	DB	200 DUP(0)
numwolves_005	DW	0
numrabbits_006	DW	0
numprinttimes_007	DW	0
t_008	DW	0
xpt_009	DW	0
seed_010	DW	0
rowoffset_011	DB	20 DUP(0)
coloffset_012	DB	20 DUP(0)
$S_149	DB	"r "
$S_144	DB	"W "
$S_139	DB	". "
$S_129	DB	" : Wolf Island"
$S_103	DB	" : Rabbit born at "
$S_087	DB	" : Wolf born at "
$S_080	DB	" : Rabbit eaten at "
$S_071	DB	", "
$S_070	DB	" : Wolf died at "
$S_069	DB	"t ="

	END
