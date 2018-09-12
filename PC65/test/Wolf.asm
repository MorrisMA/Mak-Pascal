;    1: PROGRAM WolfIsland (input, output);
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
i_014	.equ	-1
row_015	.equ	-3
col_016	.equ	-5
initialize_013	.sub
	phx.w
	tsx.w
	adj #-6
;  113: 
;  114:     {Initialize the island and wolf food matrices.}
;  115:     FOR i := 0 TO max DO BEGIN
	lda #0
	sta.w i_014,X
L_017
	lda #10
	cmp.w i_014,X
	bge L_018
	jmp L_019
L_018
;  116:         island[0,   i] := border;
	psh.w #island_002
	lda #0
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w i_014,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #5
	pli
	sta.w 0,I++
;  117:         island[max, i] := border;
	psh.w #island_002
	lda #10
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w i_014,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #5
	pli
	sta.w 0,I++
;  118:         island[i, 0]   := border;
	psh.w #island_002
	lda.w i_014,X
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda #0
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #5
	pli
	sta.w 0,I++
;  119:         island[i, max] := border;
	psh.w #island_002
	lda.w i_014,X
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda #10
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #5
	pli
	sta.w 0,I++
;  120:     END;
	inc.w i_014,X
	jmp L_017
L_019
	dec.w i_014,X
;  121:     FOR row := 1 TO size DO BEGIN
	lda #1
	sta.w row_015,X
L_020
	lda #9
	cmp.w row_015,X
	bge L_021
	jmp L_022
L_021
;  122:         FOR col := 1 TO size DO BEGIN
	lda #1
	sta.w col_016,X
L_023
	lda #9
	cmp.w col_016,X
	bge L_024
	jmp L_025
L_024
;  123:         island[row, col]    := empty;
	psh.w #island_002
	lda.w row_015,X
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w col_016,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #4
	pli
	sta.w 0,I++
;  124:         foodunits[row, col] := 0;
	psh.w #foodunits_003
	lda.w row_015,X
	dec.w a
	pha.w
	psh.w #18
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w col_016,X
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #0
	pli
	sta.w 0,I++
;  125:         END;
	inc.w col_016,X
	jmp L_023
L_025
	dec.w col_016,X
;  126:     END;
	inc.w row_015,X
	jmp L_020
L_022
	dec.w row_015,X
;  127: 
;  128:     {Place wolves on the island.}
;  129:     read(numwolves);
	psh.w #numwolves_005
	jsr _iread
	pli
	sta.w 0,I++
;  130:     FOR i := 1 TO numwolves DO BEGIN
	lda #1
	sta.w i_014,X
L_026
	lda.w numwolves_005
	cmp.w i_014,X
	bge L_027
	jmp L_028
L_027
;  131:         read(row, col);
	txa.w
	clc
	adc.w #row_015
	pha.w
	jsr _iread
	pli
	sta.w 0,I++
	txa.w
	clc
	adc.w #col_016
	pha.w
	jsr _iread
	pli
	sta.w 0,I++
;  132:         island[row, col]    := wolf;
	psh.w #island_002
	lda.w row_015,X
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w col_016,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #0
	pli
	sta.w 0,I++
;  133:         foodunits[row, col] := initfoodunits;
	psh.w #foodunits_003
	lda.w row_015,X
	dec.w a
	pha.w
	psh.w #18
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w col_016,X
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #6
	pli
	sta.w 0,I++
;  134:     END;
	inc.w i_014,X
	jmp L_026
L_028
	dec.w i_014,X
;  135: 
;  136:     {Place rabbits on the island.}
;  137:     read(numrabbits);
	psh.w #numrabbits_006
	jsr _iread
	pli
	sta.w 0,I++
;  138:     FOR i := 1 TO numrabbits DO BEGIN
	lda #1
	sta.w i_014,X
L_029
	lda.w numrabbits_006
	cmp.w i_014,X
	bge L_030
	jmp L_031
L_030
;  139:         read(row, col);
	txa.w
	clc
	adc.w #row_015
	pha.w
	jsr _iread
	pli
	sta.w 0,I++
	txa.w
	clc
	adc.w #col_016
	pha.w
	jsr _iread
	pli
	sta.w 0,I++
;  140:         island[row, col] := rabbit;
	psh.w #island_002
	lda.w row_015,X
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w col_016,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #1
	pli
	sta.w 0,I++
;  141:     END;
	inc.w i_014,X
	jmp L_029
L_031
	dec.w i_014,X
;  142: 
;  143:     {Read print times.}
;  144:     read(numprinttimes);
	psh.w #numprinttimes_007
	jsr _iread
	pli
	sta.w 0,I++
;  145:     FOR i := 1 TO numprinttimes DO BEGIN
	lda #1
	sta.w i_014,X
L_032
	lda.w numprinttimes_007
	cmp.w i_014,X
	bge L_033
	jmp L_034
L_033
;  146:         read(printtimes[i]);
	psh.w #printtimes_004
	lda.w i_014,X
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	jsr _iread
	pli
	sta.w 0,I++
;  147:     END;
	inc.w i_014,X
	jmp L_032
L_034
	dec.w i_014,X
;  148: 
;  149:     {Initialize the row and column offsets for moves.}
;  150:     rowoffset[0] :=  0; coloffset[0] :=  0; {stay put}
	psh.w #rowoffset_011
	lda #0
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #0
	pli
	sta.w 0,I++
	psh.w #coloffset_012
	lda #0
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #0
	pli
	sta.w 0,I++
;  151:     rowoffset[1] := -1; coloffset[1] :=  0; {up}
	psh.w #rowoffset_011
	lda #1
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #1
	eor.w #-1
	inc.w a
	pli
	sta.w 0,I++
	psh.w #coloffset_012
	lda #1
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #0
	pli
	sta.w 0,I++
;  152:     rowoffset[2] :=  0; coloffset[2] := -1; {left}
	psh.w #rowoffset_011
	lda #2
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #0
	pli
	sta.w 0,I++
	psh.w #coloffset_012
	lda #2
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #1
	eor.w #-1
	inc.w a
	pli
	sta.w 0,I++
;  153:     rowoffset[3] :=  0; coloffset[3] := +1; {right}
	psh.w #rowoffset_011
	lda #3
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #0
	pli
	sta.w 0,I++
	psh.w #coloffset_012
	lda #3
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #1
	pli
	sta.w 0,I++
;  154:     rowoffset[4] := +1; coloffset[4] :=  0; {down}
	psh.w #rowoffset_011
	lda #4
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #1
	pli
	sta.w 0,I++
	psh.w #coloffset_012
	lda #4
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #0
	pli
	sta.w 0,I++
;  155:     END {Initialize};
	txs.w
	plx.w
	rts
	.end	initialize_013
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
limit_036	.equ	+7
random_035	.sub
	phx.w
	tsx.w
	adj #-4
;  168:     seed   := (seed*multiplier + increment) MOD divisor;
	lda.w seed_010
	pha.w
	lda #21
	pha.w
	jsr _imul
	adj #4
	pha.w
	lda #77
	clc
	adc.w 1,S
	adj #2
	pha.w
	lda.w #1024
	pha.w
	jsr _idiv
	adj #4
	swp a
	sta.w seed_010
;  169:     random := (seed*limit) DIV divisor;
	lda.w seed_010
	pha.w
	lda.w limit_036,X
	pha.w
	jsr _imul
	adj #4
	pha.w
	lda.w #1024
	pha.w
	jsr _idiv
	adj #4
	sta.w RETURN_VALUE,X
;  170:     END {random};
	lda.w RETURN_VALUE,X
	txs.w
	plx.w
	rts
	.end	random_035
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
creature_038	.equ	+15
oldrow_039	.equ	+13
oldcol_040	.equ	+11
newrow_041	.equ	+9
newcol_042	.equ	+7
adj_043	.equ	-1
what_044	.equ	-3
done_045	.equ	-5
newlocation_037	.sub
	phx.w
	tsx.w
	adj #-6
;  187:     done := false;
	lda #0
	sta.w done_045,X
;  188: 
;  189:     {A wolf first tries to eat a rabbit.
;  190:      Check adjacent locations.}
;  191:     IF creature = wolf THEN BEGIN
	lda.w creature_038,X
	pha.w
	lda #0
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_048
	lda #0
L_048
	cmp.w #1
	beq L_046
	jmp  L_047
L_046
;  192:         adj := 0;
	lda #0
	sta.w adj_043,X
;  193:         REPEAT
L_049
;  194:         adj := adj + 1;
	lda.w adj_043,X
	pha.w
	lda #1
	clc
	adc.w 1,S
	adj #2
	sta.w adj_043,X
;  195:         newrow := oldrow + rowoffset[adj];
	lda.w newrow_041,X
	pha.w
	lda.w oldrow_039,X
	pha.w
	psh.w #rowoffset_011
	lda.w adj_043,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli
	lda.w 0,I++
	clc
	adc.w 1,S
	adj #2
	pli
	sta.w 0,I++
;  196:         newcol := oldcol + coloffset[adj];
	lda.w newcol_042,X
	pha.w
	lda.w oldcol_040,X
	pha.w
	psh.w #coloffset_012
	lda.w adj_043,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli
	lda.w 0,I++
	clc
	adc.w 1,S
	adj #2
	pli
	sta.w 0,I++
;  197:         what   := island[newrow, newcol];
	psh.w #island_002
	lda.w (newrow_041,X)
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w (newcol_042,X)
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli
	lda.w 0,I++
	sta.w what_044,X
;  198:         done   := what = rabbit;
	lda.w what_044,X
	pha.w
	lda #1
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_051
	lda #0
L_051
	sta.w done_045,X
;  199:         UNTIL done OR (adj = 4);
	lda.w done_045,X
	pha.w
	lda.w adj_043,X
	pha.w
	lda #4
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_052
	lda #0
L_052
	ora.w 1,S
	adj #2
	cmp.w #1
	beq L_050
	jmp L_049
L_050
;  200:     END;
L_047
;  201: 
;  202:     {Move randomly into an adjacent location or stay put.}
;  203:     IF NOT done THEN BEGIN
	lda.w done_045,X
	eor #1
	cmp.w #1
	beq L_053
	jmp  L_054
L_053
;  204:         REPEAT
L_055
;  205:         adj := random(5);
	lda #5
	pha.w
	lda.w STATIC_LINK,X
	pha.w
	jsr random_035
	adj #4
	sta.w adj_043,X
;  206:         newrow := oldrow + rowoffset[adj];
	lda.w newrow_041,X
	pha.w
	lda.w oldrow_039,X
	pha.w
	psh.w #rowoffset_011
	lda.w adj_043,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli
	lda.w 0,I++
	clc
	adc.w 1,S
	adj #2
	pli
	sta.w 0,I++
;  207:         newcol := oldcol + coloffset[adj];
	lda.w newcol_042,X
	pha.w
	lda.w oldcol_040,X
	pha.w
	psh.w #coloffset_012
	lda.w adj_043,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli
	lda.w 0,I++
	clc
	adc.w 1,S
	adj #2
	pli
	sta.w 0,I++
;  208:         what   := island[newrow, newcol];
	psh.w #island_002
	lda.w (newrow_041,X)
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w (newcol_042,X)
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli
	lda.w 0,I++
	sta.w what_044,X
;  209:         UNTIL    (what = empty)
	lda.w what_044,X
	pha.w
	lda #4
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_057
	lda #0
L_057
;  210:           OR ((newrow = oldrow) AND (newcol = oldcol));
	pha.w
	lda.w (newrow_041,X)
	pha.w
	lda.w oldrow_039,X
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_058
	lda #0
L_058
	pha.w
	lda.w (newcol_042,X)
	pha.w
	lda.w oldcol_040,X
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_059
	lda #0
L_059
	and.w 1,S
	adj #2
	ora.w 1,S
	adj #2
	cmp.w #1
	beq L_056
	jmp L_055
L_056
;  211:     END;
L_054
;  212:     END {NewLocation};
	txs.w
	plx.w
	rts
	.end	newlocation_037
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
oldrow_061	.equ	+9
oldcol_062	.equ	+7
newrow_063	.equ	-1
newcol_064	.equ	-3
moved_065	.equ	-5
processwolf_060	.sub
	phx.w
	tsx.w
	adj #-6
;  224: 
;  225:     {Lose a food unit.}
;  226:     foodunits[oldrow, oldcol] := foodunits[oldrow, oldcol] - 1;
	psh.w #foodunits_003
	lda.w oldrow_061,X
	dec.w a
	pha.w
	psh.w #18
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w oldcol_062,X
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	psh.w #foodunits_003
	lda.w oldrow_061,X
	dec.w a
	pha.w
	psh.w #18
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w oldcol_062,X
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli
	lda.w 0,I++
	pha.w
	lda #1
	xma.w 1,S
	sec
	sbc.w 1,S
	adj #2
	pli
	sta.w 0,I++
;  227: 
;  228:     IF foodunits[oldrow, oldcol] = 0 THEN BEGIN
	psh.w #foodunits_003
	lda.w oldrow_061,X
	dec.w a
	pha.w
	psh.w #18
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w oldcol_062,X
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli
	lda.w 0,I++
	pha.w
	lda #0
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_068
	lda #0
L_068
	cmp.w #1
	beq L_066
	jmp  L_067
L_066
;  229: 
;  230:         {Die of starvation.}
;  231:         island[oldrow, oldcol] := empty;
	psh.w #island_002
	lda.w oldrow_061,X
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w oldcol_062,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #4
	pli
	sta.w 0,I++
;  232:         numwolves := numwolves - 1;
	lda.w numwolves_005
	pha.w
	lda #1
	xma.w 1,S
	sec
	sbc.w 1,S
	adj #2
	sta.w numwolves_005
;  233:         writeln('t =', t:4, ' : Wolf died at ',
	psh.w #S_069
	psh.w #0
	psh.w #3
	jsr _swrite
	adj #6
	lda.w t_008
	pha.w
	lda #4
	pha.w
	jsr _iwrite
	adj #4
	psh.w #S_070
	psh.w #0
	psh.w #16
	jsr _swrite
	adj #6
;  234:             '[', oldrow:1, ', ', oldcol:1, ']');
	lda #91
	pha.w
	psh.w #0
	jsr _cwrite
	adj #4
	lda.w oldrow_061,X
	pha.w
	lda #1
	pha.w
	jsr _iwrite
	adj #4
	psh.w #S_071
	psh.w #0
	psh.w #2
	jsr _swrite
	adj #6
	lda.w oldcol_062,X
	pha.w
	lda #1
	pha.w
	jsr _iwrite
	adj #4
	lda #93
	pha.w
	psh.w #0
	jsr _cwrite
	adj #4
	jsr _writeln
;  235:     END
;  236:     ELSE BEGIN
	jmp L_072
L_067
;  237: 
;  238:         {Move to adjacent location, or stay put.}
;  239:         NewLocation(wolf, oldrow, oldcol, newrow, newcol);
	lda #0
	pha.w
	lda.w oldrow_061,X
	pha.w
	lda.w oldcol_062,X
	pha.w
	txa.w
	clc
	adc.w #newrow_063
	pha.w
	txa.w
	clc
	adc.w #newcol_064
	pha.w
	lda.w STATIC_LINK,X
	pha.w
	jsr newlocation_037
	adj #12
;  240:         moved := (newrow <> oldrow) OR (newcol <> oldcol);
	lda.w newrow_063,X
	pha.w
	lda.w oldrow_061,X
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	bne L_073
	lda #0
L_073
	pha.w
	lda.w newcol_064,X
	pha.w
	lda.w oldcol_062,X
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	bne L_074
	lda #0
L_074
	ora.w 1,S
	adj #2
	sta.w moved_065,X
;  241: 
;  242:         IF moved THEN BEGIN
	lda.w moved_065,X
	cmp.w #1
	beq L_075
	jmp  L_076
L_075
;  243: 
;  244:         {If there's a rabbit there, eat it.}
;  245:         IF island[newrow, newcol] = rabbit THEN BEGIN
	psh.w #island_002
	lda.w newrow_063,X
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w newcol_064,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli
	lda.w 0,I++
	pha.w
	lda #1
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_079
	lda #0
L_079
	cmp.w #1
	beq L_077
	jmp  L_078
L_077
;  246:             foodunits[oldrow, oldcol] :=
	psh.w #foodunits_003
	lda.w oldrow_061,X
	dec.w a
	pha.w
	psh.w #18
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w oldcol_062,X
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
;  247:             foodunits[oldrow, oldcol] + rabbitfoodunits;
	psh.w #foodunits_003
	lda.w oldrow_061,X
	dec.w a
	pha.w
	psh.w #18
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w oldcol_062,X
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli
	lda.w 0,I++
	pha.w
	lda #6
	clc
	adc.w 1,S
	adj #2
	pli
	sta.w 0,I++
;  248:             numrabbits := numrabbits - 1;
	lda.w numrabbits_006
	pha.w
	lda #1
	xma.w 1,S
	sec
	sbc.w 1,S
	adj #2
	sta.w numrabbits_006
;  249:             writeln('t =', t:4, ' : Rabbit eaten at ',
	psh.w #S_069
	psh.w #0
	psh.w #3
	jsr _swrite
	adj #6
	lda.w t_008
	pha.w
	lda #4
	pha.w
	jsr _iwrite
	adj #4
	psh.w #S_080
	psh.w #0
	psh.w #19
	jsr _swrite
	adj #6
;  250:                 '[', newrow:1, ', ', newcol:1, ']');
	lda #91
	pha.w
	psh.w #0
	jsr _cwrite
	adj #4
	lda.w newrow_063,X
	pha.w
	lda #1
	pha.w
	jsr _iwrite
	adj #4
	psh.w #S_071
	psh.w #0
	psh.w #2
	jsr _swrite
	adj #6
	lda.w newcol_064,X
	pha.w
	lda #1
	pha.w
	jsr _iwrite
	adj #4
	lda #93
	pha.w
	psh.w #0
	jsr _cwrite
	adj #4
	jsr _writeln
;  251:         END;
L_078
;  252: 
;  253:         {Set new (or same) location.}
;  254:         island[newrow, newcol] := newwolf;
	psh.w #island_002
	lda.w newrow_063,X
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w newcol_064,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #2
	pli
	sta.w 0,I++
;  255:         island[oldrow, oldcol] := empty;
	psh.w #island_002
	lda.w oldrow_061,X
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w oldcol_062,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #4
	pli
	sta.w 0,I++
;  256:         foodunits[newrow, newcol] := foodunits[oldrow, oldcol];
	psh.w #foodunits_003
	lda.w newrow_063,X
	dec.w a
	pha.w
	psh.w #18
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w newcol_064,X
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	psh.w #foodunits_003
	lda.w oldrow_061,X
	dec.w a
	pha.w
	psh.w #18
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w oldcol_062,X
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli
	lda.w 0,I++
	pli
	sta.w 0,I++
;  257:         foodunits[oldrow, oldcol] := 0;
	psh.w #foodunits_003
	lda.w oldrow_061,X
	dec.w a
	pha.w
	psh.w #18
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w oldcol_062,X
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #0
	pli
	sta.w 0,I++
;  258:         END;
L_076
;  259: 
;  260:         {Wolf reproduction time?}
;  261:         IF     ((t MOD wolfreprotime) = 0)
	lda.w t_008
	pha.w
	lda #12
	pha.w
	jsr _idiv
	adj #4
	swp a
	pha.w
	lda #0
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_083
	lda #0
L_083
;  262:            AND (foodunits[newrow, newcol] > 1) THEN BEGIN
	pha.w
	psh.w #foodunits_003
	lda.w newrow_063,X
	dec.w a
	pha.w
	psh.w #18
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w newcol_064,X
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli
	lda.w 0,I++
	pha.w
	lda #1
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	bgt L_084
	lda #0
L_084
	and.w 1,S
	adj #2
	cmp.w #1
	beq L_081
	jmp  L_082
L_081
;  263:         foodunits[newrow, newcol] :=
	psh.w #foodunits_003
	lda.w newrow_063,X
	dec.w a
	pha.w
	psh.w #18
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w newcol_064,X
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
;  264:             foodunits[newrow, newcol] DIV 2;
	psh.w #foodunits_003
	lda.w newrow_063,X
	dec.w a
	pha.w
	psh.w #18
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w newcol_064,X
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli
	lda.w 0,I++
	pha.w
	lda #2
	pha.w
	jsr _idiv
	adj #4
	pli
	sta.w 0,I++
;  265: 
;  266:         {If moved, then leave behind an offspring.}
;  267:         IF moved THEN BEGIN
	lda.w moved_065,X
	cmp.w #1
	beq L_085
	jmp  L_086
L_085
;  268:             island[oldrow, oldcol] := newwolf;
	psh.w #island_002
	lda.w oldrow_061,X
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w oldcol_062,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #2
	pli
	sta.w 0,I++
;  269:             foodunits[oldrow, oldcol] :=
	psh.w #foodunits_003
	lda.w oldrow_061,X
	dec.w a
	pha.w
	psh.w #18
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w oldcol_062,X
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
;  270:             foodunits[newrow, newcol];
	psh.w #foodunits_003
	lda.w newrow_063,X
	dec.w a
	pha.w
	psh.w #18
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w newcol_064,X
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli
	lda.w 0,I++
	pli
	sta.w 0,I++
;  271:             numwolves := numwolves + 1;
	lda.w numwolves_005
	pha.w
	lda #1
	clc
	adc.w 1,S
	adj #2
	sta.w numwolves_005
;  272:             writeln('t =', t:4, ' : Wolf born at ',
	psh.w #S_069
	psh.w #0
	psh.w #3
	jsr _swrite
	adj #6
	lda.w t_008
	pha.w
	lda #4
	pha.w
	jsr _iwrite
	adj #4
	psh.w #S_087
	psh.w #0
	psh.w #16
	jsr _swrite
	adj #6
;  273:                 '[', oldrow:1, ', ', oldcol:1, ']');
	lda #91
	pha.w
	psh.w #0
	jsr _cwrite
	adj #4
	lda.w oldrow_061,X
	pha.w
	lda #1
	pha.w
	jsr _iwrite
	adj #4
	psh.w #S_071
	psh.w #0
	psh.w #2
	jsr _swrite
	adj #6
	lda.w oldcol_062,X
	pha.w
	lda #1
	pha.w
	jsr _iwrite
	adj #4
	lda #93
	pha.w
	psh.w #0
	jsr _cwrite
	adj #4
	jsr _writeln
;  274:         END;
L_086
;  275:         END;
L_082
;  276:     END;
L_072
;  277:     END {ProcessWolf};
	txs.w
	plx.w
	rts
	.end	processwolf_060
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
oldrow_089	.equ	+9
oldcol_090	.equ	+7
newrow_091	.equ	-1
newcol_092	.equ	-3
moved_093	.equ	-5
processrabbit_088	.sub
	phx.w
	tsx.w
	adj #-6
;  289: 
;  290:     {Move to adjacent location, or stay put.}
;  291:     NewLocation(rabbit, oldrow, oldcol, newrow, newcol);
	lda #1
	pha.w
	lda.w oldrow_089,X
	pha.w
	lda.w oldcol_090,X
	pha.w
	txa.w
	clc
	adc.w #newrow_091
	pha.w
	txa.w
	clc
	adc.w #newcol_092
	pha.w
	lda.w STATIC_LINK,X
	pha.w
	jsr newlocation_037
	adj #12
;  292:     moved := (newrow <> oldrow) OR (newcol <> oldcol);
	lda.w newrow_091,X
	pha.w
	lda.w oldrow_089,X
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	bne L_094
	lda #0
L_094
	pha.w
	lda.w newcol_092,X
	pha.w
	lda.w oldcol_090,X
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	bne L_095
	lda #0
L_095
	ora.w 1,S
	adj #2
	sta.w moved_093,X
;  293:     IF moved THEN BEGIN
	lda.w moved_093,X
	cmp.w #1
	beq L_096
	jmp  L_097
L_096
;  294:         island[newrow, newcol] := newrabbit;
	psh.w #island_002
	lda.w newrow_091,X
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w newcol_092,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #3
	pli
	sta.w 0,I++
;  295:         island[oldrow, oldcol] := empty;
	psh.w #island_002
	lda.w oldrow_089,X
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w oldcol_090,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #4
	pli
	sta.w 0,I++
;  296:     END;
L_097
;  297: 
;  298:     {Rabbit reproduction time?}
;  299:     IF (t MOD rabbitreprotime) = 0 THEN BEGIN
	lda.w t_008
	pha.w
	lda #5
	pha.w
	jsr _idiv
	adj #4
	swp a
	pha.w
	lda #0
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_100
	lda #0
L_100
	cmp.w #1
	beq L_098
	jmp  L_099
L_098
;  300: 
;  301:         {If moved, then leave behind an offspring.}
;  302:         IF moved THEN BEGIN
	lda.w moved_093,X
	cmp.w #1
	beq L_101
	jmp  L_102
L_101
;  303:         island[oldrow, oldcol] := newrabbit;
	psh.w #island_002
	lda.w oldrow_089,X
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w oldcol_090,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #3
	pli
	sta.w 0,I++
;  304:         numrabbits := numrabbits + 1;
	lda.w numrabbits_006
	pha.w
	lda #1
	clc
	adc.w 1,S
	adj #2
	sta.w numrabbits_006
;  305:         writeln('t =', t:4, ' : Rabbit born at ',
	psh.w #S_069
	psh.w #0
	psh.w #3
	jsr _swrite
	adj #6
	lda.w t_008
	pha.w
	lda #4
	pha.w
	jsr _iwrite
	adj #4
	psh.w #S_103
	psh.w #0
	psh.w #18
	jsr _swrite
	adj #6
;  306:             '[', oldrow:1, ', ', oldcol:1, ']');
	lda #91
	pha.w
	psh.w #0
	jsr _cwrite
	adj #4
	lda.w oldrow_089,X
	pha.w
	lda #1
	pha.w
	jsr _iwrite
	adj #4
	psh.w #S_071
	psh.w #0
	psh.w #2
	jsr _swrite
	adj #6
	lda.w oldcol_090,X
	pha.w
	lda #1
	pha.w
	jsr _iwrite
	adj #4
	lda #93
	pha.w
	psh.w #0
	jsr _cwrite
	adj #4
	jsr _writeln
;  307:         END;
L_102
;  308:     END;
L_099
;  309:     END {ProcessRabbit};
	txs.w
	plx.w
	rts
	.end	processrabbit_088
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
row_105	.equ	-1
col_106	.equ	-3
eventsoccur_104	.sub
	phx.w
	tsx.w
	adj #-4
;  320: 
;  321:     {Scan for wolves and process each one in turn.}
;  322:     FOR row := 1 TO size DO BEGIN
	lda #1
	sta.w row_105,X
L_107
	lda #9
	cmp.w row_105,X
	bge L_108
	jmp L_109
L_108
;  323:         FOR col := 1 TO size DO BEGIN
	lda #1
	sta.w col_106,X
L_110
	lda #9
	cmp.w col_106,X
	bge L_111
	jmp L_112
L_111
;  324:         IF island[row, col] = wolf THEN BEGIN
	psh.w #island_002
	lda.w row_105,X
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w col_106,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli
	lda.w 0,I++
	pha.w
	lda #0
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_115
	lda #0
L_115
	cmp.w #1
	beq L_113
	jmp  L_114
L_113
;  325:             ProcessWolf(row, col);
	lda.w row_105,X
	pha.w
	lda.w col_106,X
	pha.w
	lda.w STATIC_LINK,X
	pha.w
	jsr processwolf_060
	adj #6
;  326:         END;
L_114
;  327:         END;
	inc.w col_106,X
	jmp L_110
L_112
	dec.w col_106,X
;  328:     END;
	inc.w row_105,X
	jmp L_107
L_109
	dec.w row_105,X
;  329: 
;  330: 
;  331:     {Scan for rabbits and process each one in turn.}
;  332:     FOR row := 1 TO size DO BEGIN
	lda #1
	sta.w row_105,X
L_116
	lda #9
	cmp.w row_105,X
	bge L_117
	jmp L_118
L_117
;  333:         FOR col := 1 TO size DO BEGIN
	lda #1
	sta.w col_106,X
L_119
	lda #9
	cmp.w col_106,X
	bge L_120
	jmp L_121
L_120
;  334:         IF island[row, col] = rabbit THEN BEGIN
	psh.w #island_002
	lda.w row_105,X
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w col_106,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli
	lda.w 0,I++
	pha.w
	lda #1
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_124
	lda #0
L_124
	cmp.w #1
	beq L_122
	jmp  L_123
L_122
;  335:             ProcessRabbit(row, col);
	lda.w row_105,X
	pha.w
	lda.w col_106,X
	pha.w
	lda.w STATIC_LINK,X
	pha.w
	jsr processrabbit_088
	adj #6
;  336:         END;
L_123
;  337:         END;
	inc.w col_106,X
	jmp L_119
L_121
	dec.w col_106,X
;  338:     END;
	inc.w row_105,X
	jmp L_116
L_118
	dec.w row_105,X
;  339:     END {EventsOccur};
	txs.w
	plx.w
	rts
	.end	eventsoccur_104
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
row_126	.equ	-1
col_127	.equ	-3
cnts_128	.equ	-5
printisland_125	.sub
	phx.w
	tsx.w
	adj #-6
;  351:     writeln;
	jsr _writeln
;  352:     writeln('t =', t:4, ' : Wolf Island');
	psh.w #S_069
	psh.w #0
	psh.w #3
	jsr _swrite
	adj #6
	lda.w t_008
	pha.w
	lda #4
	pha.w
	jsr _iwrite
	adj #4
	psh.w #S_129
	psh.w #0
	psh.w #14
	jsr _swrite
	adj #6
	jsr _writeln
;  353:     writeln;
	jsr _writeln
;  354: 
;  355:     FOR row := 1 TO size DO BEGIN
	lda #1
	sta.w row_126,X
L_130
	lda #9
	cmp.w row_126,X
	bge L_131
	jmp L_132
L_131
;  356:         write(' ':10);
	lda #32
	pha.w
	lda #10
	pha.w
	jsr _cwrite
	adj #4
;  357:         FOR col := 1 TO size DO BEGIN
	lda #1
	sta.w col_127,X
L_133
	lda #9
	cmp.w col_127,X
	bge L_134
	jmp L_135
L_134
;  358:         cnts := island[row, col];
	psh.w #island_002
	lda.w row_126,X
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w col_127,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli
	lda.w 0,I++
	sta.w cnts_128,X
;  359:         IF      cnts = empty  THEN write('. ')
	lda.w cnts_128,X
	pha.w
	lda #4
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_138
	lda #0
L_138
	cmp.w #1
	beq L_136
	jmp  L_137
L_136
	psh.w #S_139
	psh.w #0
	psh.w #2
	jsr _swrite
	adj #6
;  360:         ELSE IF cnts = wolf   THEN write('W ')
	jmp L_140
L_137
	lda.w cnts_128,X
	pha.w
	lda #0
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_143
	lda #0
L_143
	cmp.w #1
	beq L_141
	jmp  L_142
L_141
	psh.w #S_144
	psh.w #0
	psh.w #2
	jsr _swrite
	adj #6
;  361:         ELSE IF cnts = rabbit THEN write('r ')
	jmp L_145
L_142
	lda.w cnts_128,X
	pha.w
	lda #1
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_148
	lda #0
L_148
	cmp.w #1
	beq L_146
	jmp  L_147
L_146
	psh.w #S_149
	psh.w #0
	psh.w #2
	jsr _swrite
	adj #6
;  362:         END;
L_147
L_145
L_140
	inc.w col_127,X
	jmp L_133
L_135
	dec.w col_127,X
;  363:         writeln;
	jsr _writeln
;  364:     END;
	inc.w row_126,X
	jmp L_130
L_132
	dec.w row_126,X
;  365:     END {PrintIsland};
	txs.w
	plx.w
	rts
	.end	printisland_125
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
row_151	.equ	-1
col_152	.equ	-3
resetisland_150	.sub
	phx.w
	tsx.w
	adj #-4
;  377:     FOR row := 1 TO size DO BEGIN
	lda #1
	sta.w row_151,X
L_153
	lda #9
	cmp.w row_151,X
	bge L_154
	jmp L_155
L_154
;  378:         FOR col := 1 TO size DO BEGIN
	lda #1
	sta.w col_152,X
L_156
	lda #9
	cmp.w col_152,X
	bge L_157
	jmp L_158
L_157
;  379:         IF island[row, col] = newwolf THEN BEGIN
	psh.w #island_002
	lda.w row_151,X
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w col_152,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli
	lda.w 0,I++
	pha.w
	lda #2
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_161
	lda #0
L_161
	cmp.w #1
	beq L_159
	jmp  L_160
L_159
;  380:             island[row, col] := wolf;
	psh.w #island_002
	lda.w row_151,X
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w col_152,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #0
	pli
	sta.w 0,I++
;  381:         END
;  382:         ELSE IF island[row, col] = newrabbit THEN BEGIN
	jmp L_162
L_160
	psh.w #island_002
	lda.w row_151,X
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w col_152,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli
	lda.w 0,I++
	pha.w
	lda #3
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_165
	lda #0
L_165
	cmp.w #1
	beq L_163
	jmp  L_164
L_163
;  383:             island[row, col] := rabbit;
	psh.w #island_002
	lda.w row_151,X
	pha.w
	psh.w #22
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	lda.w col_152,X
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #1
	pli
	sta.w 0,I++
;  384:         END;
L_164
L_162
;  385:         END;
	inc.w col_152,X
	jmp L_156
L_158
	dec.w col_152,X
;  386:     END;
	inc.w row_151,X
	jmp L_153
L_155
	dec.w row_151,X
;  387:     END {ResetIsland};
	txs.w
	plx.w
	rts
	.end	resetisland_150
;  388: 
;  389: 
;  390: BEGIN {WolfIsland}
_pc65_main	.sub
	phx.w
	tsx.w
;  391: 
;  392:     Initialize;
	phx.w
	jsr initialize_013
	adj #2
;  393: 
;  394:     t   := 0;
	lda #0
	sta.w t_008
;  395:     xpt := 1;
	lda #1
	sta.w xpt_009
;  396:     read(seed);
	psh.w #seed_010
	jsr _iread
	pli
	sta.w 0,I++
;  397: 
;  398:     PrintIsland;
	phx.w
	jsr printisland_125
	adj #2
;  399: 
;  400:     {Loop once per time period.}
;  401:     REPEAT
L_166
;  402:     writeln;
	jsr _writeln
;  403: 
;  404:     t := t + 1;
	lda.w t_008
	pha.w
	lda #1
	clc
	adc.w 1,S
	adj #2
	sta.w t_008
;  405:     EventsOccur;
	phx.w
	jsr eventsoccur_104
	adj #2
;  406:     ResetIsland;
	phx.w
	jsr resetisland_150
	adj #2
;  407: 
;  408:     {Time to print the island?}
;  409:     IF t = printtimes[xpt] THEN BEGIN
	lda.w t_008
	pha.w
	psh.w #printtimes_004
	lda.w xpt_009
	dec.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pli
	lda.w 0,I++
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_170
	lda #0
L_170
	cmp.w #1
	beq L_168
	jmp  L_169
L_168
;  410:         PrintIsland;
	phx.w
	jsr printisland_125
	adj #2
;  411:         xpt := xpt + 1;
	lda.w xpt_009
	pha.w
	lda #1
	clc
	adc.w 1,S
	adj #2
	sta.w xpt_009
;  412:     END;
L_169
;  413:     UNTIL (numwolves = 0) OR (numrabbits = 0)
	lda.w numwolves_005
	pha.w
	lda #0
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_171
	lda #0
L_171
	pha.w
	lda.w numrabbits_006
	pha.w
	lda #0
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_172
	lda #0
L_172
;  414:       OR (xpt > numprinttimes);
	ora.w 1,S
	adj #2
	pha.w
	lda.w xpt_009
	pha.w
	lda.w numprinttimes_007
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	bgt L_173
	lda #0
L_173
	ora.w 1,S
	adj #2
	cmp.w #1
	beq L_167
	jmp L_166
L_167
;  415: 
;  416:     PrintIsland;
	phx.w
	jsr printisland_125
	adj #2
;  417: 
;  418: END {WolfIsland}.
	plx.w
	rts
	.end	_pc65_main

	.dat

island_002	.byt	242
foodunits_003	.byt	162
printtimes_004	.byt	100
numwolves_005	.byt	2
numrabbits_006	.byt	2
numprinttimes_007	.byt	2
t_008	.byt	2
xpt_009	.byt	2
seed_010	.byt	2
rowoffset_011	.byt	10
coloffset_012	.byt	10
S_149	.str	"r "
S_144	.str	"W "
S_139	.str	". "
S_129	.str	" : Wolf Island"
S_103	.str	" : Rabbit born at "
S_087	.str	" : Wolf born at "
S_080	.str	" : Rabbit eaten at "
S_071	.str	", "
S_070	.str	" : Wolf died at "
S_069	.str	"t ="

	.end
