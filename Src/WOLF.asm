;    1: PROGRAM WolfIsland (input, output);

	;--- 8086 Pascal, Copyright 1991, Ronald Mak                  ---
	;--- For Instructional Purposes Only. NO WARRANTIES.          ---

	:--- M65C02A Pascal. (By Permission: 12/13/2015, Ronald Mak)  ---
	:--- Copyright 2015-2016, Michael A. Morris                   ---

	;--- This program is free software: you can redistribute it   ---
	;--- and/or modify it under the terms of the GNU GeneralP     ---
	;--- Public License as published by the Free Software         ---
	;--- Foundation, either version 3 of the License, or (at your ---
	;--- option) any later version.                               ---

	;--- This program is distributed in the hope that it will be  ---
	;--- useful, but WITHOUT ANY WARRANTY; without even the       ---
	;--- implied warranty of MERCHANTABILITY or FITNESS FOR A     ---
	;--- PARTICULAR PURPOSE.  See the GNU General Public License  ---
	;--- for more details.                                        ---

	;--- You should have received a copy of the GNU General       ---
	;--- Public License along with this program.  If not, see     ---
	;--- <http://www.gnu.org/licenses/>.                          ---

STATIC_LINK			equ	+4
RETURN_VALUE		equ	-4
HIGH_RETURN_VALUE	equ	-2

	code						;--- Place in CODE segment
	org	1536					;--- Start of CODE segment
start							;--- Start of CODE segment
	tsa.w						;--- Save OS/Mon SP
	lds.w #1535					;--- Initialize program SP
	psh #0						;--- Push 0 for data segment initialization
	pha.w						;--- Save OS/Mon SP

	lda.w #data_end				;--- Load address of data segment end
	sec
	sbc.w #data_begin			;--- Calculate data segment length
	dup x						;--- Save BP
	ldx.w #1535					;--- Initialize SI
	ldy.w #data_begin			;--- Initialize DI
	mvb 48						;--- Block Move: SI - hold; DI - increment
	rot x						;--- Restore BP

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

	i_014	EQU	-2
	row_015	EQU	-4
	col_016	EQU	-6

initialize_013	PROC
	phx.w
	tsx.w
	adj #-6
;  113: 
;  114:     {Initialize the island and wolf food matrices.}
;  115:     FOR i := 0 TO max DO BEGIN
	lda #0
	sta.w i_014,B
	pha.w
	lda #10
	xma.w 0,S
$L_017:
	cmp.w 0,S
	jgt $L_019
$L_018:
;  116:         island[0,   i] := border;
	psh #island_002
	lda #0
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w i_014,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #5
	sta.w (0,S)
	adj #2
;  117:         island[max, i] := border;
	psh #island_002
	lda #10
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w i_014,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #5
	sta.w (0,S)
	adj #2
;  118:         island[i, 0]   := border;
	psh #island_002
	lda.w i_014,B
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda #0
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #5
	sta.w (0,S)
	adj #2
;  119:         island[i, max] := border;
	psh #island_002
	lda.w i_014,B
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda #10
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #5
	sta.w (0,S)
	adj #2
;  120:     END;
	inc.w i_014,B
	lda.w i_014,B
	jmp $L_017
$L_019:
	dec.w i_014,B
	adj #2
;  121:     FOR row := 1 TO size DO BEGIN
	lda #1
	sta.w row_015,B
	pha.w
	lda #9
	xma.w 0,S
$L_020:
	cmp.w 0,S
	jgt $L_022
$L_021:
;  122:         FOR col := 1 TO size DO BEGIN
	lda #1
	sta.w col_016,B
	pha.w
	lda #9
	xma.w 0,S
$L_023:
	cmp.w 0,S
	jgt $L_025
$L_024:
;  123:         island[row, col]    := empty;
	psh #island_002
	lda.w row_015,B
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w col_016,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #4
	sta.w (0,S)
	adj #2
;  124:         foodunits[row, col] := 0;
	psh #foodunits_003
	lda.w row_015,B
	dec.w a
	pha.w
	psh #18
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w col_016,B
	dec.w a
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #0
	sta.w (0,S)
	adj #2
;  125:         END;
	inc.w col_016,B
	lda.w col_016,B
	jmp $L_023
$L_025:
	dec.w col_016,B
	adj #2
;  126:     END;
	inc.w row_015,B
	lda.w row_015,B
	jmp $L_020
$L_022:
	dec.w row_015,B
	adj #2
;  127: 
;  128:     {Place wolves on the island.}
;  129:     read(numwolves);
	psh #numwolves_005
	jsr _iread
	sta.w (0,S)
	adj #2
;  130:     FOR i := 1 TO numwolves DO BEGIN
	lda #1
	sta.w i_014,B
	pha.w
	lda.w numwolves_005
	xma.w 0,S
$L_026:
	cmp.w 0,S
	jgt $L_028
$L_027:
;  131:         read(row, col);
	txa.w
	sec
	adc.w #row_015
	pha.w
	jsr _iread
	sta.w (0,S)
	adj #2
	txa.w
	sec
	adc.w #col_016
	pha.w
	jsr _iread
	sta.w (0,S)
	adj #2
;  132:         island[row, col]    := wolf;
	psh #island_002
	lda.w row_015,B
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w col_016,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #0
	sta.w (0,S)
	adj #2
;  133:         foodunits[row, col] := initfoodunits;
	psh #foodunits_003
	lda.w row_015,B
	dec.w a
	pha.w
	psh #18
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w col_016,B
	dec.w a
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #6
	sta.w (0,S)
	adj #2
;  134:     END;
	inc.w i_014,B
	lda.w i_014,B
	jmp $L_026
$L_028:
	dec.w i_014,B
	adj #2
;  135: 
;  136:     {Place rabbits on the island.}
;  137:     read(numrabbits);
	psh #numrabbits_006
	jsr _iread
	sta.w (0,S)
	adj #2
;  138:     FOR i := 1 TO numrabbits DO BEGIN
	lda #1
	sta.w i_014,B
	pha.w
	lda.w numrabbits_006
	xma.w 0,S
$L_029:
	cmp.w 0,S
	jgt $L_031
$L_030:
;  139:         read(row, col);
	txa.w
	sec
	adc.w #row_015
	pha.w
	jsr _iread
	sta.w (0,S)
	adj #2
	txa.w
	sec
	adc.w #col_016
	pha.w
	jsr _iread
	sta.w (0,S)
	adj #2
;  140:         island[row, col] := rabbit;
	psh #island_002
	lda.w row_015,B
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w col_016,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #1
	sta.w (0,S)
	adj #2
;  141:     END;
	inc.w i_014,B
	lda.w i_014,B
	jmp $L_029
$L_031:
	dec.w i_014,B
	adj #2
;  142: 
;  143:     {Read print times.}
;  144:     read(numprinttimes);
	psh #numprinttimes_007
	jsr _iread
	sta.w (0,S)
	adj #2
;  145:     FOR i := 1 TO numprinttimes DO BEGIN
	lda #1
	sta.w i_014,B
	pha.w
	lda.w numprinttimes_007
	xma.w 0,S
$L_032:
	cmp.w 0,S
	jgt $L_034
$L_033:
;  146:         read(printtimes[i]);
	psh #printtimes_004
	lda.w i_014,B
	dec.w a
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	jsr _iread
	sta.w (0,S)
	adj #2
;  147:     END;
	inc.w i_014,B
	lda.w i_014,B
	jmp $L_032
$L_034:
	dec.w i_014,B
	adj #2
;  148: 
;  149:     {Initialize the row and column offsets for moves.}
;  150:     rowoffset[0] :=  0;  coloffset[0] :=  0;    {stay put}
	psh #rowoffset_011
	lda #0
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #0
	sta.w (0,S)
	adj #2
	psh #coloffset_012
	lda #0
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #0
	sta.w (0,S)
	adj #2
;  151:     rowoffset[1] := -1;  coloffset[1] :=  0;    {up}
	psh #rowoffset_011
	lda #1
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #1
	eor.w #-1
	inc.w a
	sta.w (0,S)
	adj #2
	psh #coloffset_012
	lda #1
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #0
	sta.w (0,S)
	adj #2
;  152:     rowoffset[2] :=  0;  coloffset[2] := -1;    {left}
	psh #rowoffset_011
	lda #2
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #0
	sta.w (0,S)
	adj #2
	psh #coloffset_012
	lda #2
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #1
	eor.w #-1
	inc.w a
	sta.w (0,S)
	adj #2
;  153:     rowoffset[3] :=  0;  coloffset[3] := +1;    {right}
	psh #rowoffset_011
	lda #3
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #0
	sta.w (0,S)
	adj #2
	psh #coloffset_012
	lda #3
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #1
	sta.w (0,S)
	adj #2
;  154:     rowoffset[4] := +1;  coloffset[4] :=  0;    {down}
	psh #rowoffset_011
	lda #4
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #1
	sta.w (0,S)
	adj #2
	psh #coloffset_012
	lda #4
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #0
	sta.w (0,S)
	adj #2
;  155:     END {Initialize};
	txs.w
	plx.w
	rts
initialize_013	ENDP

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

	limit_036	EQU	+6

random_035	PROC
	phx.w
	tsx.w
	adj #4
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
	adc.w 0,S
	adj #2
	pha.w
	lda.w #1024
	pha.w
	jsr _idiv
	adj #4
	sta.w seed_010,B
;  169:     random := (seed*limit) DIV divisor;
	lda.w seed_010
	pha.w
	lda.w limit_036,B
	pha.w
	jsr _imul
	adj #4
	pha.w
	lda.w #1024
	pha.w
	jsr _idiv
	adj #4
	swp a
	sta.w -4,B
;  170:     END {random};
	lda.w -4,B
	txs.w
	plx.w
	rts
random_035	ENDP

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

	creature_038	EQU	+14
	oldrow_039	EQU	+12
	oldcol_040	EQU	+10
	newrow_041	EQU	+8
	newcol_042	EQU	+6
	adj_043	EQU	-2
	what_044	EQU	-4
	done_045	EQU	-6

newlocation_037	PROC
	phx.w
	tsx.w
	adj #-6
;  187:     done := false;
	lda #0
	sta.w done_045,B
;  188: 
;  189:     {A wolf first tries to eat a rabbit.
;  190:      Check adjacent locations.}
;  191:     IF creature = wolf THEN BEGIN
	lda.w creature_038,B
	pha.w
	lda #0
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	beq $L_048
	lda #0
$L_048:
	cmp #1
	jne $L_047
$L_046:
;  192:         adj := 0;
	lda #0
	sta.w adj_043,B
;  193:         REPEAT
$L_049:
;  194:         adj := adj + 1;
	lda.w adj_043,B
	pha.w
	lda #1
	clc
	adc.w 0,S
	adj #2
	sta.w adj_043,B
;  195:         newrow := oldrow + rowoffset[adj];
	lda.w newrow_041,B
	pha.w
	lda.w oldrow_039,B
	pha.w
	psh #rowoffset_011
	lda.w adj_043,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (0,S)
	adj #2
	clc
	adc.w 0,S
	adj #2
	sta.w (0,S)
	adj #2
;  196:         newcol := oldcol + coloffset[adj];
	lda.w newcol_042,B
	pha.w
	lda.w oldcol_040,B
	pha.w
	psh #coloffset_012
	lda.w adj_043,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (0,S)
	adj #2
	clc
	adc.w 0,S
	adj #2
	sta.w (0,S)
	adj #2
;  197:         what   := island[newrow, newcol];
	psh #island_002
	lda.w (newrow_041,B)
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (newcol_042,B)
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (0,S)
	adj #2
	sta.w what_044,B
;  198:         done   := what = rabbit;
	lda.w what_044,B
	pha.w
	lda #1
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	beq $L_051
	lda #0
$L_051:
	sta.w done_045,B
;  199:         UNTIL done OR (adj = 4);
	lda.w done_045,B
	pha.w
	lda.w adj_043,B
	pha.w
	lda #4
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	beq $L_052
	lda #0
$L_052:
	ora.w 0,S
	adj #2
	cmp #1
	jne $L_049
$L_050:
;  200:     END;
$L_047:
;  201: 
;  202:     {Move randomly into an adjacent location or stay put.}
;  203:     IF NOT done THEN BEGIN
	lda.w done_045,B
	eor #1
	cmp #1
	jne $L_054
$L_053:
;  204:         REPEAT
$L_055:
;  205:         adj := random(5);
	lda #5
	pha.w
	lda.w 4,B
	pha.w
	jsr random_035
	adj #4
	sta.w adj_043,B
;  206:         newrow := oldrow + rowoffset[adj];
	lda.w newrow_041,B
	pha.w
	lda.w oldrow_039,B
	pha.w
	psh #rowoffset_011
	lda.w adj_043,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (0,S)
	adj #2
	clc
	adc.w 0,S
	adj #2
	sta.w (0,S)
	adj #2
;  207:         newcol := oldcol + coloffset[adj];
	lda.w newcol_042,B
	pha.w
	lda.w oldcol_040,B
	pha.w
	psh #coloffset_012
	lda.w adj_043,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (0,S)
	adj #2
	clc
	adc.w 0,S
	adj #2
	sta.w (0,S)
	adj #2
;  208:         what   := island[newrow, newcol];
	psh #island_002
	lda.w (newrow_041,B)
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (newcol_042,B)
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (0,S)
	adj #2
	sta.w what_044,B
;  209:         UNTIL    (what = empty)
	lda.w what_044,B
	pha.w
	lda #4
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	beq $L_057
	lda #0
$L_057:
;  210:           OR ((newrow = oldrow) AND (newcol = oldcol));
	pha.w
	lda.w (newrow_041,B)
	pha.w
	lda.w oldrow_039,B
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	beq $L_058
	lda #0
$L_058:
	pha.w
	lda.w (newcol_042,B)
	pha.w
	lda.w oldcol_040,B
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	beq $L_059
	lda #0
$L_059:
	anl.w 0,S
	adj #2
	ora.w 0,S
	adj #2
	cmp #1
	jne $L_055
$L_056:
;  211:     END;
$L_054:
;  212:     END {NewLocation};
	txs.w
	plx.w
	rts
newlocation_037	ENDP

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

	oldrow_061	EQU	+8
	oldcol_062	EQU	+6
	newrow_063	EQU	-2
	newcol_064	EQU	-4
	moved_065	EQU	-6

processwolf_060	PROC
	phx.w
	tsx.w
	adj #-6
;  224: 
;  225:     {Lose a food unit.}
;  226:     foodunits[oldrow, oldcol] := foodunits[oldrow, oldcol] - 1;
	psh #foodunits_003
	lda.w oldrow_061,B
	dec.w a
	pha.w
	psh #18
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w oldcol_062,B
	dec.w a
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	psh #foodunits_003
	lda.w oldrow_061,B
	dec.w a
	pha.w
	psh #18
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w oldcol_062,B
	dec.w a
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (0,S)
	adj #2
	pha.w
	lda #1
	sec
	sbc.w 0,S
	adj #2
	sta.w (0,S)
	adj #2
;  227: 
;  228:     IF foodunits[oldrow, oldcol] = 0 THEN BEGIN
	psh #foodunits_003
	lda.w oldrow_061,B
	dec.w a
	pha.w
	psh #18
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w oldcol_062,B
	dec.w a
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (0,S)
	adj #2
	pha.w
	lda #0
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	beq $L_068
	lda #0
$L_068:
	cmp #1
	jne $L_067
$L_066:
;  229: 
;  230:         {Die of starvation.}
;  231:         island[oldrow, oldcol] := empty;
	psh #island_002
	lda.w oldrow_061,B
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w oldcol_062,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #4
	sta.w (0,S)
	adj #2
;  232:         numwolves := numwolves - 1;
	lda.w numwolves_005
	pha.w
	lda #1
	sec
	sbc.w 0,S
	adj #2
	sta.w numwolves_005,B
;  233:         writeln('t =', t:4, ' : Wolf died at ',
	psh #$S_069
	psh #0
	psh #3
	jsr _swrite
	adj #6
	lda.w t_008
	pha.w
	lda #4
	pha.w
	jsr _iwrite
	adj #4
	psh #$S_070
	psh #0
	psh #16
	jsr _swrite
	adj #6
;  234:             '[', oldrow:1, ', ', oldcol:1, ']');
	lda #91
	pha.w
	psh #0
	jsr _cwrite
	adj #4
	lda.w oldrow_061,B
	pha.w
	lda #1
	pha.w
	jsr _iwrite
	adj #4
	psh #$S_071
	psh #0
	psh #2
	jsr _swrite
	adj #6
	lda.w oldcol_062,B
	pha.w
	lda #1
	pha.w
	jsr _iwrite
	adj #4
	lda #93
	pha.w
	psh #0
	jsr _cwrite
	adj #4
	jsr _writeln
;  235:     END
;  236:     ELSE BEGIN
	jmp $L_072
$L_067:
;  237: 
;  238:         {Move to adjacent location, or stay put.}
;  239:         NewLocation(wolf, oldrow, oldcol, newrow, newcol);
	lda #0
	pha.w
	lda.w oldrow_061,B
	pha.w
	lda.w oldcol_062,B
	pha.w
	txa.w
	sec
	adc.w #newrow_063
	pha.w
	txa.w
	sec
	adc.w #newcol_064
	pha.w
	lda.w 4,B
	pha.w
	jsr newlocation_037
	adj #12
;  240:         moved := (newrow <> oldrow) OR (newcol <> oldcol);
	lda.w newrow_063,B
	pha.w
	lda.w oldrow_061,B
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	bne $L_073
	lda #0
$L_073:
	pha.w
	lda.w newcol_064,B
	pha.w
	lda.w oldcol_062,B
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	bne $L_074
	lda #0
$L_074:
	ora.w 0,S
	adj #2
	sta.w moved_065,B
;  241: 
;  242:         IF moved THEN BEGIN
	lda.w moved_065,B
	cmp #1
	jne $L_076
$L_075:
;  243: 
;  244:         {If there's a rabbit there, eat it.}
;  245:         IF island[newrow, newcol] = rabbit THEN BEGIN
	psh #island_002
	lda.w newrow_063,B
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w newcol_064,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (0,S)
	adj #2
	pha.w
	lda #1
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	beq $L_079
	lda #0
$L_079:
	cmp #1
	jne $L_078
$L_077:
;  246:             foodunits[oldrow, oldcol] :=
	psh #foodunits_003
	lda.w oldrow_061,B
	dec.w a
	pha.w
	psh #18
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w oldcol_062,B
	dec.w a
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
;  247:             foodunits[oldrow, oldcol] + rabbitfoodunits;
	psh #foodunits_003
	lda.w oldrow_061,B
	dec.w a
	pha.w
	psh #18
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w oldcol_062,B
	dec.w a
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (0,S)
	adj #2
	pha.w
	lda #6
	clc
	adc.w 0,S
	adj #2
	sta.w (0,S)
	adj #2
;  248:             numrabbits := numrabbits - 1;
	lda.w numrabbits_006
	pha.w
	lda #1
	sec
	sbc.w 0,S
	adj #2
	sta.w numrabbits_006,B
;  249:             writeln('t =', t:4, ' : Rabbit eaten at ',
	psh #$S_069
	psh #0
	psh #3
	jsr _swrite
	adj #6
	lda.w t_008
	pha.w
	lda #4
	pha.w
	jsr _iwrite
	adj #4
	psh #$S_080
	psh #0
	psh #19
	jsr _swrite
	adj #6
;  250:                 '[', newrow:1, ', ', newcol:1, ']');
	lda #91
	pha.w
	psh #0
	jsr _cwrite
	adj #4
	lda.w newrow_063,B
	pha.w
	lda #1
	pha.w
	jsr _iwrite
	adj #4
	psh #$S_071
	psh #0
	psh #2
	jsr _swrite
	adj #6
	lda.w newcol_064,B
	pha.w
	lda #1
	pha.w
	jsr _iwrite
	adj #4
	lda #93
	pha.w
	psh #0
	jsr _cwrite
	adj #4
	jsr _writeln
;  251:         END;
$L_078:
;  252: 
;  253:         {Set new (or same) location.}
;  254:         island[newrow, newcol] := newwolf;
	psh #island_002
	lda.w newrow_063,B
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w newcol_064,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #2
	sta.w (0,S)
	adj #2
;  255:         island[oldrow, oldcol] := empty;
	psh #island_002
	lda.w oldrow_061,B
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w oldcol_062,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #4
	sta.w (0,S)
	adj #2
;  256:         foodunits[newrow, newcol] := foodunits[oldrow, oldcol];
	psh #foodunits_003
	lda.w newrow_063,B
	dec.w a
	pha.w
	psh #18
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w newcol_064,B
	dec.w a
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	psh #foodunits_003
	lda.w oldrow_061,B
	dec.w a
	pha.w
	psh #18
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w oldcol_062,B
	dec.w a
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (0,S)
	adj #2
	sta.w (0,S)
	adj #2
;  257:         foodunits[oldrow, oldcol] := 0;
	psh #foodunits_003
	lda.w oldrow_061,B
	dec.w a
	pha.w
	psh #18
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w oldcol_062,B
	dec.w a
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #0
	sta.w (0,S)
	adj #2
;  258:         END;
$L_076:
;  259: 
;  260:         {Wolf reproduction time?}
;  261:         IF     ((t MOD wolfreprotime) = 0)
	lda.w t_008
	pha.w
	lda #12
	pha.w
	jsr _idiv
	adj #4
	pha.w
	lda #0
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	beq $L_083
	lda #0
$L_083:
;  262:            AND (foodunits[newrow, newcol] > 1) THEN BEGIN
	pha.w
	psh #foodunits_003
	lda.w newrow_063,B
	dec.w a
	pha.w
	psh #18
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w newcol_064,B
	dec.w a
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (0,S)
	adj #2
	pha.w
	lda #1
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	blt $L_084
	lda #0
$L_084:
	anl.w 0,S
	adj #2
	cmp #1
	jne $L_082
$L_081:
;  263:         foodunits[newrow, newcol] :=
	psh #foodunits_003
	lda.w newrow_063,B
	dec.w a
	pha.w
	psh #18
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w newcol_064,B
	dec.w a
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
;  264:             foodunits[newrow, newcol] DIV 2;
	psh #foodunits_003
	lda.w newrow_063,B
	dec.w a
	pha.w
	psh #18
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w newcol_064,B
	dec.w a
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (0,S)
	adj #2
	pha.w
	lda #2
	pha.w
	jsr _idiv
	adj #4
	swp a
	sta.w (0,S)
	adj #2
;  265: 
;  266:         {If moved, then leave behind an offspring.}
;  267:         IF moved THEN BEGIN
	lda.w moved_065,B
	cmp #1
	jne $L_086
$L_085:
;  268:             island[oldrow, oldcol] := newwolf;
	psh #island_002
	lda.w oldrow_061,B
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w oldcol_062,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #2
	sta.w (0,S)
	adj #2
;  269:             foodunits[oldrow, oldcol] :=
	psh #foodunits_003
	lda.w oldrow_061,B
	dec.w a
	pha.w
	psh #18
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w oldcol_062,B
	dec.w a
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
;  270:             foodunits[newrow, newcol];
	psh #foodunits_003
	lda.w newrow_063,B
	dec.w a
	pha.w
	psh #18
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w newcol_064,B
	dec.w a
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (0,S)
	adj #2
	sta.w (0,S)
	adj #2
;  271:             numwolves := numwolves + 1;
	lda.w numwolves_005
	pha.w
	lda #1
	clc
	adc.w 0,S
	adj #2
	sta.w numwolves_005,B
;  272:             writeln('t =', t:4, ' : Wolf born at ',
	psh #$S_069
	psh #0
	psh #3
	jsr _swrite
	adj #6
	lda.w t_008
	pha.w
	lda #4
	pha.w
	jsr _iwrite
	adj #4
	psh #$S_087
	psh #0
	psh #16
	jsr _swrite
	adj #6
;  273:                 '[', oldrow:1, ', ', oldcol:1, ']');
	lda #91
	pha.w
	psh #0
	jsr _cwrite
	adj #4
	lda.w oldrow_061,B
	pha.w
	lda #1
	pha.w
	jsr _iwrite
	adj #4
	psh #$S_071
	psh #0
	psh #2
	jsr _swrite
	adj #6
	lda.w oldcol_062,B
	pha.w
	lda #1
	pha.w
	jsr _iwrite
	adj #4
	lda #93
	pha.w
	psh #0
	jsr _cwrite
	adj #4
	jsr _writeln
;  274:         END;
$L_086:
;  275:         END;
$L_082:
;  276:     END;
$L_072:
;  277:     END {ProcessWolf};
	txs.w
	plx.w
	rts
processwolf_060	ENDP

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

	oldrow_089	EQU	+8
	oldcol_090	EQU	+6
	newrow_091	EQU	-2
	newcol_092	EQU	-4
	moved_093	EQU	-6

processrabbit_088	PROC
	phx.w
	tsx.w
	adj #-6
;  289: 
;  290:     {Move to adjacent location, or stay put.}
;  291:     NewLocation(rabbit, oldrow, oldcol, newrow, newcol);
	lda #1
	pha.w
	lda.w oldrow_089,B
	pha.w
	lda.w oldcol_090,B
	pha.w
	txa.w
	sec
	adc.w #newrow_091
	pha.w
	txa.w
	sec
	adc.w #newcol_092
	pha.w
	lda.w 4,B
	pha.w
	jsr newlocation_037
	adj #12
;  292:     moved := (newrow <> oldrow) OR (newcol <> oldcol);
	lda.w newrow_091,B
	pha.w
	lda.w oldrow_089,B
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	bne $L_094
	lda #0
$L_094:
	pha.w
	lda.w newcol_092,B
	pha.w
	lda.w oldcol_090,B
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	bne $L_095
	lda #0
$L_095:
	ora.w 0,S
	adj #2
	sta.w moved_093,B
;  293:     IF moved THEN BEGIN
	lda.w moved_093,B
	cmp #1
	jne $L_097
$L_096:
;  294:         island[newrow, newcol] := newrabbit;
	psh #island_002
	lda.w newrow_091,B
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w newcol_092,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #3
	sta.w (0,S)
	adj #2
;  295:         island[oldrow, oldcol] := empty;
	psh #island_002
	lda.w oldrow_089,B
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w oldcol_090,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #4
	sta.w (0,S)
	adj #2
;  296:     END;
$L_097:
;  297: 
;  298:     {Rabbit reproduction time?}
;  299:     IF (t MOD rabbitreprotime) = 0 THEN BEGIN
	lda.w t_008
	pha.w
	lda #5
	pha.w
	jsr _idiv
	adj #4
	pha.w
	lda #0
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	beq $L_100
	lda #0
$L_100:
	cmp #1
	jne $L_099
$L_098:
;  300: 
;  301:         {If moved, then leave behind an offspring.}
;  302:         IF moved THEN BEGIN
	lda.w moved_093,B
	cmp #1
	jne $L_102
$L_101:
;  303:         island[oldrow, oldcol] := newrabbit;
	psh #island_002
	lda.w oldrow_089,B
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w oldcol_090,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #3
	sta.w (0,S)
	adj #2
;  304:         numrabbits := numrabbits + 1;
	lda.w numrabbits_006
	pha.w
	lda #1
	clc
	adc.w 0,S
	adj #2
	sta.w numrabbits_006,B
;  305:         writeln('t =', t:4, ' : Rabbit born at ',
	psh #$S_069
	psh #0
	psh #3
	jsr _swrite
	adj #6
	lda.w t_008
	pha.w
	lda #4
	pha.w
	jsr _iwrite
	adj #4
	psh #$S_103
	psh #0
	psh #18
	jsr _swrite
	adj #6
;  306:             '[', oldrow:1, ', ', oldcol:1, ']');
	lda #91
	pha.w
	psh #0
	jsr _cwrite
	adj #4
	lda.w oldrow_089,B
	pha.w
	lda #1
	pha.w
	jsr _iwrite
	adj #4
	psh #$S_071
	psh #0
	psh #2
	jsr _swrite
	adj #6
	lda.w oldcol_090,B
	pha.w
	lda #1
	pha.w
	jsr _iwrite
	adj #4
	lda #93
	pha.w
	psh #0
	jsr _cwrite
	adj #4
	jsr _writeln
;  307:         END;
$L_102:
;  308:     END;
$L_099:
;  309:     END {ProcessRabbit};
	txs.w
	plx.w
	rts
processrabbit_088	ENDP

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

	row_105	EQU	-2
	col_106	EQU	-4

eventsoccur_104	PROC
	phx.w
	tsx.w
	adj #-4
;  320: 
;  321:     {Scan for wolves and process each one in turn.}
;  322:     FOR row := 1 TO size DO BEGIN
	lda #1
	sta.w row_105,B
	pha.w
	lda #9
	xma.w 0,S
$L_107:
	cmp.w 0,S
	jgt $L_109
$L_108:
;  323:         FOR col := 1 TO size DO BEGIN
	lda #1
	sta.w col_106,B
	pha.w
	lda #9
	xma.w 0,S
$L_110:
	cmp.w 0,S
	jgt $L_112
$L_111:
;  324:         IF island[row, col] = wolf THEN BEGIN
	psh #island_002
	lda.w row_105,B
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w col_106,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (0,S)
	adj #2
	pha.w
	lda #0
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	beq $L_115
	lda #0
$L_115:
	cmp #1
	jne $L_114
$L_113:
;  325:             ProcessWolf(row, col);
	lda.w row_105,B
	pha.w
	lda.w col_106,B
	pha.w
	lda.w 4,B
	pha.w
	jsr processwolf_060
	adj #6
;  326:         END;
$L_114:
;  327:         END;
	inc.w col_106,B
	lda.w col_106,B
	jmp $L_110
$L_112:
	dec.w col_106,B
	adj #2
;  328:     END;
	inc.w row_105,B
	lda.w row_105,B
	jmp $L_107
$L_109:
	dec.w row_105,B
	adj #2
;  329: 
;  330: 
;  331:     {Scan for rabbits and process each one in turn.}
;  332:     FOR row := 1 TO size DO BEGIN
	lda #1
	sta.w row_105,B
	pha.w
	lda #9
	xma.w 0,S
$L_116:
	cmp.w 0,S
	jgt $L_118
$L_117:
;  333:         FOR col := 1 TO size DO BEGIN
	lda #1
	sta.w col_106,B
	pha.w
	lda #9
	xma.w 0,S
$L_119:
	cmp.w 0,S
	jgt $L_121
$L_120:
;  334:         IF island[row, col] = rabbit THEN BEGIN
	psh #island_002
	lda.w row_105,B
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w col_106,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (0,S)
	adj #2
	pha.w
	lda #1
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	beq $L_124
	lda #0
$L_124:
	cmp #1
	jne $L_123
$L_122:
;  335:             ProcessRabbit(row, col);
	lda.w row_105,B
	pha.w
	lda.w col_106,B
	pha.w
	lda.w 4,B
	pha.w
	jsr processrabbit_088
	adj #6
;  336:         END;
$L_123:
;  337:         END;
	inc.w col_106,B
	lda.w col_106,B
	jmp $L_119
$L_121:
	dec.w col_106,B
	adj #2
;  338:     END;
	inc.w row_105,B
	lda.w row_105,B
	jmp $L_116
$L_118:
	dec.w row_105,B
	adj #2
;  339:     END {EventsOccur};
	txs.w
	plx.w
	rts
eventsoccur_104	ENDP

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

	row_126	EQU	-2
	col_127	EQU	-4
	cnts_128	EQU	-6

printisland_125	PROC
	phx.w
	tsx.w
	adj #-6
;  351:     writeln;
	jsr _writeln
;  352:     writeln('t =', t:4, ' : Wolf Island');
	psh #$S_069
	psh #0
	psh #3
	jsr _swrite
	adj #6
	lda.w t_008
	pha.w
	lda #4
	pha.w
	jsr _iwrite
	adj #4
	psh #$S_129
	psh #0
	psh #14
	jsr _swrite
	adj #6
	jsr _writeln
;  353:     writeln;
	jsr _writeln
;  354: 
;  355:     FOR row := 1 TO size DO BEGIN
	lda #1
	sta.w row_126,B
	pha.w
	lda #9
	xma.w 0,S
$L_130:
	cmp.w 0,S
	jgt $L_132
$L_131:
;  356:         write(' ':10);
	lda #32
	pha.w
	lda #10
	pha.w
	jsr _cwrite
	adj #4
;  357:         FOR col := 1 TO size DO BEGIN
	lda #1
	sta.w col_127,B
	pha.w
	lda #9
	xma.w 0,S
$L_133:
	cmp.w 0,S
	jgt $L_135
$L_134:
;  358:         cnts := island[row, col];
	psh #island_002
	lda.w row_126,B
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w col_127,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (0,S)
	adj #2
	sta.w cnts_128,B
;  359:         IF      cnts = empty  THEN write('. ')
	lda.w cnts_128,B
	pha.w
	lda #4
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	beq $L_138
	lda #0
$L_138:
	cmp #1
	jne $L_137
$L_136:
	psh #$S_139
	psh #0
	psh #2
	jsr _swrite
	adj #6
;  360:         ELSE IF cnts = wolf   THEN write('W ')
	jmp $L_140
$L_137:
	lda.w cnts_128,B
	pha.w
	lda #0
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	beq $L_143
	lda #0
$L_143:
	cmp #1
	jne $L_142
$L_141:
	psh #$S_144
	psh #0
	psh #2
	jsr _swrite
	adj #6
;  361:         ELSE IF cnts = rabbit THEN write('r ')
	jmp $L_145
$L_142:
	lda.w cnts_128,B
	pha.w
	lda #1
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	beq $L_148
	lda #0
$L_148:
	cmp #1
	jne $L_147
$L_146:
	psh #$S_149
	psh #0
	psh #2
	jsr _swrite
	adj #6
;  362:         END;
$L_147:
$L_145:
$L_140:
	inc.w col_127,B
	lda.w col_127,B
	jmp $L_133
$L_135:
	dec.w col_127,B
	adj #2
;  363:         writeln;
	jsr _writeln
;  364:     END;
	inc.w row_126,B
	lda.w row_126,B
	jmp $L_130
$L_132:
	dec.w row_126,B
	adj #2
;  365:     END {PrintIsland};
	txs.w
	plx.w
	rts
printisland_125	ENDP

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

	row_151	EQU	-2
	col_152	EQU	-4

resetisland_150	PROC
	phx.w
	tsx.w
	adj #-4
;  377:     FOR row := 1 TO size DO BEGIN
	lda #1
	sta.w row_151,B
	pha.w
	lda #9
	xma.w 0,S
$L_153:
	cmp.w 0,S
	jgt $L_155
$L_154:
;  378:         FOR col := 1 TO size DO BEGIN
	lda #1
	sta.w col_152,B
	pha.w
	lda #9
	xma.w 0,S
$L_156:
	cmp.w 0,S
	jgt $L_158
$L_157:
;  379:         IF island[row, col] = newwolf THEN BEGIN
	psh #island_002
	lda.w row_151,B
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w col_152,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (0,S)
	adj #2
	pha.w
	lda #2
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	beq $L_161
	lda #0
$L_161:
	cmp #1
	jne $L_160
$L_159:
;  380:             island[row, col] := wolf;
	psh #island_002
	lda.w row_151,B
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w col_152,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #0
	sta.w (0,S)
	adj #2
;  381:         END
;  382:         ELSE IF island[row, col] = newrabbit THEN BEGIN
	jmp $L_162
$L_160:
	psh #island_002
	lda.w row_151,B
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w col_152,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (0,S)
	adj #2
	pha.w
	lda #3
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	beq $L_165
	lda #0
$L_165:
	cmp #1
	jne $L_164
$L_163:
;  383:             island[row, col] := rabbit;
	psh #island_002
	lda.w row_151,B
	pha.w
	psh #22
	jsr _imul
	adj #4
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w col_152,B
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda #1
	sta.w (0,S)
	adj #2
;  384:         END;
$L_164:
$L_162:
;  385:         END;
	inc.w col_152,B
	lda.w col_152,B
	jmp $L_156
$L_158:
	dec.w col_152,B
	adj #2
;  386:     END;
	inc.w row_151,B
	lda.w row_151,B
	jmp $L_153
$L_155:
	dec.w row_151,B
	adj #2
;  387:     END {ResetIsland};
	txs.w
	plx.w
	rts
resetisland_150	ENDP

;  388: 
;  389: 
;  390: BEGIN {WolfIsland}

_main							;--- PROC
	phx.w						;--- Set DYNAMIC_LINK
	tsx.w						;--- Set Stack Frame Base
;  391: 
;  392:     Initialize;
	phx.w
	jsr initialize_013
	adj #2
;  393: 
;  394:     t   := 0;
	lda #0
	sta.w t_008,B
;  395:     xpt := 1;
	lda #1
	sta.w xpt_009,B
;  396:     read(seed);
	psh #seed_010
	jsr _iread
	sta.w (0,S)
	adj #2
;  397: 
;  398:     PrintIsland;
	phx.w
	jsr printisland_125
	adj #2
;  399: 
;  400:     {Loop once per time period.}
;  401:     REPEAT
$L_166:
;  402:     writeln;
	jsr _writeln
;  403: 
;  404:     t := t + 1;
	lda.w t_008
	pha.w
	lda #1
	clc
	adc.w 0,S
	adj #2
	sta.w t_008,B
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
	psh #printtimes_004
	lda.w xpt_009
	dec.w a
	asl.w a
	clc
	adc.w 0,S
	sta.w 0,S
	lda.w (0,S)
	adj #2
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	beq $L_170
	lda #0
$L_170:
	cmp #1
	jne $L_169
$L_168:
;  410:         PrintIsland;
	phx.w
	jsr printisland_125
	adj #2
;  411:         xpt := xpt + 1;
	lda.w xpt_009
	pha.w
	lda #1
	clc
	adc.w 0,S
	adj #2
	sta.w xpt_009,B
;  412:     END;
$L_169:
;  413:     UNTIL (numwolves = 0) OR (numrabbits = 0)
	lda.w numwolves_005
	pha.w
	lda #0
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	beq $L_171
	lda #0
$L_171:
	pha.w
	lda.w numrabbits_006
	pha.w
	lda #0
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	beq $L_172
	lda #0
$L_172:
;  414:       OR (xpt > numprinttimes);
	ora.w 0,S
	adj #2
	pha.w
	lda.w xpt_009
	pha.w
	lda.w numprinttimes_007
	cmp.w 0,S
	php
	adj #2
	lda #1
	plp
	blt $L_173
	lda #0
$L_173:
	ora.w 0,S
	adj #2
	cmp #1
	jne $L_166
$L_167:
;  415: 
;  416:     PrintIsland;
	phx.w
	jsr printisland_125
	adj #2
;  417: 
;  418: END {WolfIsland}.

	plx.w						;--- Pull Caller's BP from Program Stack
	dup x						;--- Save Caller BP
	plx.w						;--- Pull Caller's SP from Program Stack
	txs.w						;--- Restore Caller's SP
	rot x						;--- Restore Caller's BP
;
	rts

;---	END _main

	align 16					;--- Align data segment on 16 byte boundary
prog_end						;--- End of PROGRAM

	data						;--- Place in data segment
	org prog_end

data_begin

island_002	db	242 DUP(0)
foodunits_003	db	162 DUP(0)
printtimes_004	db	100 DUP(0)
numwolves_005	dw	0
numrabbits_006	dw	0
numprinttimes_007	dw	0
t_008	dw	0
xpt_009	dw	0
seed_010	dw	0
rowoffset_011	db	10 DUP(0)
coloffset_012	db	10 DUP(0)

data_end

$S_149	db	"r "
$S_144	db	"W "
$S_139	db	". "
$S_129	db	" : Wolf Island"
$S_103	db	" : Rabbit born at "
$S_087	db	" : Wolf born at "
$S_080	db	" : Rabbit eaten at "
$S_071	db	", "
$S_070	db	" : Wolf died at "
$S_069	db	"t ="

	end start
