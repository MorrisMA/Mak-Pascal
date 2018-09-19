;    1: PROGRAM xref (input, output);
	.stk 1024
	.cod 512
STATIC_LINK .equ +5
RETURN_VALUE .equ -3
HIGH_RETURN_VALUE .equ -1
_start
	tsx.w		; Preserve original stack pointer
	lds.w #16383	; Initialize program stack pointer
	jmp _pc65_main
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
word_002	.equ +0
;   21:                firstnumberindex,    {head and tail of    }
;   22:                lastnumberindex      {  linked number list}
;   23:                    : numbertableindex;
firstnumberindex_003	.equ +20
lastnumberindex_004	.equ +22
;   24:                END;
;   25: 
;   26:     numberentrytype  = RECORD  {entry in number table}
;   27:                number                   {line number}
;   28:                    : linenumbertype;
number_005	.equ +0
;   29:                nextindex                {index of next   }
;   30:                    : numbertableindex;  {  in linked list}
nextindex_006	.equ +2
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
ch_017 .equ -5
nextchar_016	.sub
	phx.w
	tsx.w
	adj #-4
	adj #-2
;   58:     newline := eoln;
	jsr _eol
	sta.w newline_014
;   59:     IF newline THEN BEGIN
	lda.w newline_014
	cmp.w #1
	beq L_018
	jmp L_019
L_018
;   60:         readln;
	jsr _readln
;   61:         writeln;
	jsr _writeln
;   62:         linenumber := linenumber + 1;
	lda.w linenumber_011
	pha.w
	lda #1
	clc
	adc.w 1,S
	adj #2
	sta.w linenumber_011
;   63:         write(linenumber:5, ' : ');
	lda.w linenumber_011
	pha.w
	lda #5
	pha.w
	jsr _iwrite
	adj #4
	psh.w #S_020
	psh.w #0
	psh.w #3
	jsr _swrite
	adj #6
;   64:     END;
L_019
;   65:     IF newline OR eof THEN BEGIN
	lda.w newline_014
	pha.w
	jsr _eof
	ora.w 1,S
	adj #2
	cmp.w #1
	beq L_021
	jmp L_022
L_021
;   66:         ch := blank;
	lda #32
	sta ch_017
;   67:     END
;   68:     ELSE BEGIN
	jmp L_023
L_022
;   69:         read(ch);
	txa.w
	clc
	adc.w #ch_017
	pha.w
	jsr _cread
	pli
	sta 0,I++
;   70:         write(ch);
	lda ch_017,X
	pha.w
	psh.w #0
	jsr _cwrite
	adj #4
;   71:     END;
L_023
;   72:     nextchar := ch;
	lda ch_017,X
	tay
	tya
	sta.w RETURN_VALUE,X
;   73:     END;
	lda.w RETURN_VALUE,X
	txs.w
	plx.w
	rts
	.end nextchar_016
;   74: 
;   75: 
;   76: FUNCTION isletter (ch : char) : boolean;
;   77: 
;   78:     {Return true if the character is a letter, false otherwise.}
;   79: 
;   80:     BEGIN
ch_025 .equ +7
isletter_024	.sub
	phx.w
	tsx.w
	adj #-4
;   81:     isletter :=    ((ch >= 'a') AND (ch <= 'z'))
	lda ch_025,X
	pha.w
	lda #97
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	bge L_026
	lda #0
L_026
	pha.w
	lda ch_025,X
	pha.w
	lda #122
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	ble L_027
	lda #0
L_027
	and.w 1,S
	adj #2
;   82:             OR ((ch >= 'A') AND (ch <= 'Z'));
	pha.w
	lda ch_025,X
	pha.w
	lda #65
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	bge L_028
	lda #0
L_028
	pha.w
	lda ch_025,X
	pha.w
	lda #90
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	ble L_029
	lda #0
L_029
	and.w 1,S
	adj #2
	ora.w 1,S
	adj #2
	sta.w RETURN_VALUE,X
;   83:     END;
	lda.w RETURN_VALUE,X
	txs.w
	plx.w
	rts
	.end isletter_024
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
buffer_031 .equ +7
charcount_032 .equ -1
ch_033 .equ -3
readword_030	.sub
	phx.w
	tsx.w
	adj #-4
;   98:     gotword := false;
	lda #0
	sta.w gotword_015
;   99: 
;  100:     {Skip over any preceding non-letters.}
;  101:     IF NOT eof THEN BEGIN
	jsr _eof
	eor #1
	cmp.w #1
	beq L_034
	jmp L_035
L_034
;  102:         REPEAT
L_036
;  103:         ch := nextchar;
	lda.w STATIC_LINK,X
	pha.w
	jsr nextchar_016
	adj #2
	sta ch_033
;  104:         UNTIL eof OR isletter(ch);
	jsr _eof
	pha.w
	lda ch_033,X
	pha.w
	lda.w STATIC_LINK,X
	pha.w
	jsr isletter_024
	adj #4
	ora.w 1,S
	adj #2
	cmp.w #1
	beq L_037
	jmp L_036
L_037
;  105:     END;
L_035
;  106: 
;  107:     {Find a letter?}
;  108:     IF NOT eof THEN BEGIN
	jsr _eof
	eor #1
	cmp.w #1
	beq L_038
	jmp L_039
L_038
;  109:         charcount := 0;
	lda #0
	sta.w charcount_032,X
;  110: 
;  111:         {Place the word's letters into the buffer.
;  112:          Downshift uppercase letters.}
;  113:         WHILE isletter(ch) DO BEGIN
L_040
	lda ch_033,X
	pha.w
	lda.w STATIC_LINK,X
	pha.w
	jsr isletter_024
	adj #4
	cmp.w #1
	beq L_041
	jmp L_042
L_041
;  114:         IF charcount < maxwordlen THEN BEGIN
	lda.w charcount_032,X
	pha.w
	lda #20
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	blt L_045
	lda #0
L_045
	cmp.w #1
	beq L_043
	jmp L_044
L_043
;  115:             IF (ch >= 'A') AND (ch <= 'Z') THEN BEGIN
	lda ch_033,X
	pha.w
	lda #65
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	bge L_048
	lda #0
L_048
	pha.w
	lda ch_033,X
	pha.w
	lda #90
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	ble L_049
	lda #0
L_049
	and.w 1,S
	adj #2
	cmp.w #1
	beq L_046
	jmp L_047
L_046
;  116:             ch := chr(ord(ch) + (ord('a') - ord('A')));
	lda ch_033,X
	pha.w
	lda #97
	pha.w
	lda #65
	xma.w 1,S
	sec
	sbc.w 1,S
	adj #2
	clc
	adc.w 1,S
	adj #2
	sta ch_033
;  117:             END;
L_047
;  118:             charcount := charcount + 1;
	lda.w charcount_032,X
	pha.w
	lda #1
	clc
	adc.w 1,S
	adj #2
	sta.w charcount_032,X
;  119:             buffer[charcount] := ch;
	lda.w buffer_031,X
	pha.w
	lda.w charcount_032,X
	dec.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda ch_033,X
	pli
	sta 0,I++
;  120:         END;
L_044
;  121:         ch := nextchar;
	lda.w STATIC_LINK,X
	pha.w
	jsr nextchar_016
	adj #2
	sta ch_033
;  122:         END;
	jmp L_040
L_042
;  123: 
;  124:         {Pad the rest of the buffer with blanks.}
;  125:         FOR charcount := charcount + 1 TO maxwordlen DO BEGIN
	lda.w charcount_032,X
	pha.w
	lda #1
	clc
	adc.w 1,S
	adj #2
	sta.w charcount_032,X
L_050
	lda #20
	cmp.w charcount_032,X
	bge L_051
	jmp L_052
L_051
;  126:         buffer[charcount] := blank;
	lda.w buffer_031,X
	pha.w
	lda.w charcount_032,X
	dec.w a
	clc
	adc.w 1,S
	sta.w 1,S
	lda #32
	pli
	sta 0,I++
;  127:         END;
	inc.w charcount_032,X
	jmp L_050
L_052
	dec.w charcount_032,X
;  128: 
;  129:         gotword := true;
	lda #1
	sta.w gotword_015
;  130:     END;
L_039
;  131:     END;
	txs.w
	plx.w
	rts
	.end readword_030
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
lastnumberindex_054 .equ +7
appendlinenumber_053	.sub
	phx.w
	tsx.w
	adj #-4
;  142:         IF nextnumberindex < numbertablesize THEN BEGIN
	lda.w nextnumberindex_010
	pha.w
	lda.w #1000
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	blt L_057
	lda #0
L_057
	cmp.w #1
	beq L_055
	jmp L_056
L_055
;  143:         IF lastnumberindex <> 0 THEN BEGIN
	lda.w lastnumberindex_054,X
	pha.w
	lda #0
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	bne L_060
	lda #0
L_060
	cmp.w #1
	beq L_058
	jmp L_059
L_058
;  144:             numbertable[lastnumberindex].nextindex := nextnumberindex;
	psh.w #numbertable_008
	lda.w lastnumberindex_054,X
	asl.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pla.w
	clc
	adc.w #nextindex_006
	pha.w
	lda.w nextnumberindex_010
	pli
	sta.w 0,I++
;  145:         END;
L_059
;  146:         numbertable[nextnumberindex].number    := linenumber;
	psh.w #numbertable_008
	lda.w nextnumberindex_010
	asl.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pla.w
	clc
	adc.w #number_005
	pha.w
	lda.w linenumber_011
	pli
	sta.w 0,I++
;  147:         numbertable[nextnumberindex].nextindex := 0;
	psh.w #numbertable_008
	lda.w nextnumberindex_010
	asl.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pla.w
	clc
	adc.w #nextindex_006
	pha.w
	lda #0
	pli
	sta.w 0,I++
;  148:         appendlinenumber := nextnumberindex;
	lda.w nextnumberindex_010
	sta.w RETURN_VALUE,X
;  149:         nextnumberindex  := nextnumberindex + 1;
	lda.w nextnumberindex_010
	pha.w
	lda #1
	clc
	adc.w 1,S
	adj #2
	sta.w nextnumberindex_010
;  150:         END
;  151:         ELSE BEGIN
	jmp L_061
L_056
;  152:             numbertablefull  := true;
	lda #1
	sta.w numbertablefull_013
;  153:             appendlinenumber := 0;
	lda #0
	sta.w RETURN_VALUE,X
;  154:         END;
L_061
;  155:     END;
	lda.w RETURN_VALUE,X
	txs.w
	plx.w
	rts
	.end appendlinenumber_053
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
i_063 .equ -1
enterword_062	.sub
	phx.w
	tsx.w
	adj #-2
;  167:     {By the time we process a word at the end of an input line,
;  168:      linenumber has already been incremented, so temporarily
;  169:      decrement it.}
;  170:     IF newline THEN linenumber := linenumber - 1;
	lda.w newline_014
	cmp.w #1
	beq L_064
	jmp L_065
L_064
	lda.w linenumber_011
	pha.w
	lda #1
	xma.w 1,S
	sec
	sbc.w 1,S
	adj #2
	sta.w linenumber_011
L_065
;  171: 
;  172:     {Search to see if the word has previously been entered.}
;  173:     i := 1;
	lda #1
	sta.w i_063,X
;  174:     WHILE    wordtable[i].word
L_066
	psh.w #wordtable_007
	lda.w i_063,X
	dec.w a
	pha.w
	psh.w #24
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
;  175:           <> wordtable[nextwordindex].word DO BEGIN
	pla.w
	clc
	adc.w #word_002
	pha.w
	psh.w #wordtable_007
	lda.w nextwordindex_009
	dec.w a
	pha.w
	psh.w #24
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	pla.w
	clc
	adc.w #word_002
	pha.w
	psh.w #20
	jsr _cmpsb
	adj #+6
	php
	lda #1
	plp
	bne L_069
	lda #0
L_069
	cmp.w #1
	beq L_067
	jmp L_068
L_067
;  176:         i := i + 1;
	lda.w i_063,X
	pha.w
	lda #1
	clc
	adc.w 1,S
	adj #2
	sta.w i_063,X
;  177:     END;
	jmp L_066
L_068
;  178: 
;  179:     {Yes.  Update the previous entry.}
;  180:     IF i < nextwordindex THEN BEGIN
	lda.w i_063,X
	pha.w
	lda.w nextwordindex_009
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	blt L_072
	lda #0
L_072
	cmp.w #1
	beq L_070
	jmp L_071
L_070
;  181:         wordtable[i].lastnumberindex :=
	psh.w #wordtable_007
	lda.w i_063,X
	dec.w a
	pha.w
	psh.w #24
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	pla.w
	clc
	adc.w #lastnumberindex_004
	pha.w
;  182:         appendlinenumber(wordtable[i].lastnumberindex);
	psh.w #wordtable_007
	lda.w i_063,X
	dec.w a
	pha.w
	psh.w #24
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	pla.w
	clc
	adc.w #lastnumberindex_004
	pha.w
	pli
	lda.w 0,I++
	pha.w
	lda.w STATIC_LINK,X
	pha.w
	jsr appendlinenumber_053
	adj #4
	pli
	sta.w 0,I++
;  183:     END
;  184: 
;  185:     {No.  Initialize the entry at the end of the table.}
;  186:     ELSE IF nextwordindex < wordtablesize THEN BEGIN
	jmp L_073
L_071
	lda.w nextwordindex_009
	pha.w
	lda.w #500
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	blt L_076
	lda #0
L_076
	cmp.w #1
	beq L_074
	jmp L_075
L_074
;  187:         nextwordindex := nextwordindex + 1;
	lda.w nextwordindex_009
	pha.w
	lda #1
	clc
	adc.w 1,S
	adj #2
	sta.w nextwordindex_009
;  188:         wordtable[i].firstnumberindex := appendlinenumber(0);
	psh.w #wordtable_007
	lda.w i_063,X
	dec.w a
	pha.w
	psh.w #24
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	pla.w
	clc
	adc.w #firstnumberindex_003
	pha.w
	lda #0
	pha.w
	lda.w STATIC_LINK,X
	pha.w
	jsr appendlinenumber_053
	adj #4
	pli
	sta.w 0,I++
;  189:         wordtable[i].lastnumberindex :=
	psh.w #wordtable_007
	lda.w i_063,X
	dec.w a
	pha.w
	psh.w #24
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	pla.w
	clc
	adc.w #lastnumberindex_004
	pha.w
;  190:         wordtable[i].firstnumberindex;
	psh.w #wordtable_007
	lda.w i_063,X
	dec.w a
	pha.w
	psh.w #24
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	pla.w
	clc
	adc.w #firstnumberindex_003
	pha.w
	pli
	lda.w 0,I++
	pli
	sta.w 0,I++
;  191:     END
;  192: 
;  193:     {Oops.  Table overflow!}
;  194:     ELSE wordtablefull := true;
	jmp L_077
L_075
	lda #1
	sta.w wordtablefull_012
L_077
L_073
;  195: 
;  196:     IF newline THEN linenumber := linenumber + 1;
	lda.w newline_014
	cmp.w #1
	beq L_078
	jmp L_079
L_078
	lda.w linenumber_011
	pha.w
	lda #1
	clc
	adc.w 1,S
	adj #2
	sta.w linenumber_011
L_079
;  197:     END;
	txs.w
	plx.w
	rts
	.end enterword_062
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
i_081 .equ -1
j_082 .equ -3
temp_083 .equ -27
sortwords_080	.sub
	phx.w
	tsx.w
	adj #-28
;  209:     FOR i := 1 TO nextwordindex - 2 DO BEGIN
	lda #1
	sta.w i_081,X
L_084
	lda.w nextwordindex_009
	pha.w
	lda #2
	xma.w 1,S
	sec
	sbc.w 1,S
	adj #2
	cmp.w i_081,X
	bge L_085
	jmp L_086
L_085
;  210:         FOR j := i + 1 TO nextwordindex - 1 DO BEGIN
	lda.w i_081,X
	pha.w
	lda #1
	clc
	adc.w 1,S
	adj #2
	sta.w j_082,X
L_087
	lda.w nextwordindex_009
	pha.w
	lda #1
	xma.w 1,S
	sec
	sbc.w 1,S
	adj #2
	cmp.w j_082,X
	bge L_088
	jmp L_089
L_088
;  211:         IF wordtable[i].word > wordtable[j].word THEN BEGIN
	psh.w #wordtable_007
	lda.w i_081,X
	dec.w a
	pha.w
	psh.w #24
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	pla.w
	clc
	adc.w #word_002
	pha.w
	psh.w #wordtable_007
	lda.w j_082,X
	dec.w a
	pha.w
	psh.w #24
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	pla.w
	clc
	adc.w #word_002
	pha.w
	psh.w #20
	jsr _cmpsb
	adj #+6
	php
	lda #1
	plp
	bgt L_092
	lda #0
L_092
	cmp.w #1
	beq L_090
	jmp L_091
L_090
;  212:             temp := wordtable[i];
	txa.w
	clc
	adc.w #temp_083
	pha.w
	psh.w #wordtable_007
	lda.w i_081,X
	dec.w a
	pha.w
	psh.w #24
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	swp x
	lda #24
	plx.w
	ply.w
	mov #15
	swp x
;  213:             wordtable[i] := wordtable[j];
	psh.w #wordtable_007
	lda.w i_081,X
	dec.w a
	pha.w
	psh.w #24
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	psh.w #wordtable_007
	lda.w j_082,X
	dec.w a
	pha.w
	psh.w #24
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	swp x
	lda #24
	plx.w
	ply.w
	mov #15
	swp x
;  214:             wordtable[j] := temp;
	psh.w #wordtable_007
	lda.w j_082,X
	dec.w a
	pha.w
	psh.w #24
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	txa.w
	clc
	adc.w #temp_083
	pha.w
	swp x
	lda #24
	plx.w
	ply.w
	mov #15
	swp x
;  215:         END;
L_091
;  216:         END;
	inc.w j_082,X
	jmp L_087
L_089
	dec.w j_082,X
;  217:     END;
	inc.w i_081,X
	jmp L_084
L_086
	dec.w i_081,X
;  218:     END;
	txs.w
	plx.w
	rts
	.end sortwords_080
;  219: 
;  220: 
;  221: PROCEDURE printnumbers (i : numbertableindex);
;  222: 
;  223:     {Print a word's linked list of line numbers.}
;  224: 
;  225:     BEGIN
i_094 .equ +7
printnumbers_093	.sub
	phx.w
	tsx.w
;  226:     REPEAT
L_095
;  227:         write(numbertable[i].number:4);
	psh.w #numbertable_008
	lda.w i_094,X
	asl.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pla.w
	clc
	adc.w #number_005
	pha.w
	pli
	lda.w 0,I++
	pha.w
	lda #4
	pha.w
	jsr _iwrite
	adj #4
;  228:         i := numbertable[i].nextindex;
	psh.w #numbertable_008
	lda.w i_094,X
	asl.w a
	asl.w a
	clc
	adc.w 1,S
	sta.w 1,S
	pla.w
	clc
	adc.w #nextindex_006
	pha.w
	pli
	lda.w 0,I++
	sta.w i_094,X
;  229:     UNTIL i = 0;
	lda.w i_094,X
	pha.w
	lda #0
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_097
	lda #0
L_097
	cmp.w #1
	beq L_096
	jmp L_095
L_096
;  230:     writeln;
	jsr _writeln
;  231:     END;
	txs.w
	plx.w
	rts
	.end printnumbers_093
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
i_099 .equ -1
printxref_098	.sub
	phx.w
	tsx.w
	adj #-2
;  242:     writeln;
	jsr _writeln
;  243:     writeln;
	jsr _writeln
;  244:     writeln('Cross-reference');
	psh.w #S_100
	psh.w #0
	psh.w #15
	jsr _swrite
	adj #6
	jsr _writeln
;  245:     writeln('---------------');
	psh.w #S_101
	psh.w #0
	psh.w #15
	jsr _swrite
	adj #6
	jsr _writeln
;  246:     writeln;
	jsr _writeln
;  247:     sortwords;
	lda.w STATIC_LINK,X
	pha.w
	jsr sortwords_080
	adj #2
;  248:     FOR i := 1 TO nextwordindex - 1 DO BEGIN
	lda #1
	sta.w i_099,X
L_102
	lda.w nextwordindex_009
	pha.w
	lda #1
	xma.w 1,S
	sec
	sbc.w 1,S
	adj #2
	cmp.w i_099,X
	bge L_103
	jmp L_104
L_103
;  249:         write(wordtable[i].word);
	psh.w #wordtable_007
	lda.w i_099,X
	dec.w a
	pha.w
	psh.w #24
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	pla.w
	clc
	adc.w #word_002
	pha.w
	psh.w #0
	psh.w #20
	jsr _swrite
	adj #6
;  250:         printnumbers(wordtable[i].firstnumberindex);
	psh.w #wordtable_007
	lda.w i_099,X
	dec.w a
	pha.w
	psh.w #24
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	pla.w
	clc
	adc.w #firstnumberindex_003
	pha.w
	pli
	lda.w 0,I++
	pha.w
	lda.w STATIC_LINK,X
	pha.w
	jsr printnumbers_093
	adj #4
;  251:     END;
	inc.w i_099,X
	jmp L_102
L_104
	dec.w i_099,X
;  252:     END;
	txs.w
	plx.w
	rts
	.end printxref_098
;  253: 
;  254: 
;  255: BEGIN {xref}
_pc65_main	.sub
	phx.w
	tsx.w
;  256:     wordtablefull   := false;
	lda #0
	sta.w wordtablefull_012
;  257:     numbertablefull := false;
	lda #0
	sta.w numbertablefull_013
;  258:     nextwordindex   := 1;
	lda #1
	sta.w nextwordindex_009
;  259:     nextnumberindex := 1;
	lda #1
	sta.w nextnumberindex_010
;  260:     linenumber      := 1;
	lda #1
	sta.w linenumber_011
;  261:     write('    1 : ');
	psh.w #S_105
	psh.w #0
	psh.w #8
	jsr _swrite
	adj #6
;  262: 
;  263:     {First read the words.}
;  264:     WHILE NOT (eof OR wordtablefull OR numbertablefull) DO BEGIN
L_106
	jsr _eof
	pha.w
	lda.w wordtablefull_012
	ora.w 1,S
	adj #2
	pha.w
	lda.w numbertablefull_013
	ora.w 1,S
	adj #2
	eor #1
	cmp.w #1
	beq L_107
	jmp L_108
L_107
;  265:     readword(wordtable[nextwordindex].word);
	psh.w #wordtable_007
	lda.w nextwordindex_009
	dec.w a
	pha.w
	psh.w #24
	jsr _imul
	adj #4
	clc
	adc.w 1,S
	sta.w 1,S
	pla.w
	clc
	adc.w #word_002
	pha.w
	phx.w
	jsr readword_030
	adj #4
;  266:     IF gotword THEN enterword;
	lda.w gotword_015
	cmp.w #1
	beq L_109
	jmp L_110
L_109
	phx.w
	jsr enterword_062
	adj #2
L_110
;  267:     END;
	jmp L_106
L_108
;  268: 
;  269:     {Then print the cross reference listing if all went well.}
;  270:     IF wordtablefull THEN BEGIN
	lda.w wordtablefull_012
	cmp.w #1
	beq L_111
	jmp L_112
L_111
;  271:         writeln;
	jsr _writeln
;  272:     writeln('*** The word table is not large enough. ***');
	psh.w #S_113
	psh.w #0
	psh.w #43
	jsr _swrite
	adj #6
	jsr _writeln
;  273:     END
;  274:     ELSE IF numbertablefull THEN BEGIN
	jmp L_114
L_112
	lda.w numbertablefull_013
	cmp.w #1
	beq L_115
	jmp L_116
L_115
;  275:         writeln;
	jsr _writeln
;  276:     writeln('*** The number table is not large enough. ***');
	psh.w #S_117
	psh.w #0
	psh.w #45
	jsr _swrite
	adj #6
	jsr _writeln
;  277:     END
;  278:     ELSE BEGIN
	jmp L_118
L_116
;  279:     printxref;
	phx.w
	jsr printxref_098
	adj #2
;  280:     END;
L_118
L_114
;  281: 
;  282:     {Print final stats.}
;  283:     writeln;
	jsr _writeln
;  284:     writeln((nextwordindex - 1):5,   ' word entries.');
	lda.w nextwordindex_009
	pha.w
	lda #1
	xma.w 1,S
	sec
	sbc.w 1,S
	adj #2
	pha.w
	lda #5
	pha.w
	jsr _iwrite
	adj #4
	psh.w #S_119
	psh.w #0
	psh.w #14
	jsr _swrite
	adj #6
	jsr _writeln
;  285:     writeln((nextnumberindex - 1):5, ' line number entries.');
	lda.w nextnumberindex_010
	pha.w
	lda #1
	xma.w 1,S
	sec
	sbc.w 1,S
	adj #2
	pha.w
	lda #5
	pha.w
	jsr _iwrite
	adj #4
	psh.w #S_120
	psh.w #0
	psh.w #21
	jsr _swrite
	adj #6
	jsr _writeln
;  286: END {xref}.
;  287: 
	plx.w
	rts
	.end _pc65_main

	.dat

wordtable_007 .byt 12000
numbertable_008 .byt 4004
nextwordindex_009 .byt 2
nextnumberindex_010 .byt 2
linenumber_011 .byt 2
wordtablefull_012 .byt 2
numbertablefull_013 .byt 2
newline_014 .byt 2
gotword_015 .byt 2
S_120 .str " line number entries."
S_119 .str " word entries."
S_117 .str "*** The number table is not large enough. ***"
S_113 .str "*** The word table is not large enough. ***"
S_105 .str "    1 : "
S_101 .str "---------------"
S_100 .str "Cross-reference"
S_020 .str " : "

	.end
