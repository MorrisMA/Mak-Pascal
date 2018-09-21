;    1: PROGRAM NumberTranslator (input, output);
	.stk 1024
	.cod 512
STATIC_LINK .equ +5
RETURN_VALUE .equ -3
HIGH_RETURN_VALUE .equ -1
_start
	tsx.w		; Preserve original stack pointer
	lds.w #_stk_top	; Initialize program stack pointer
	stz _bss_start
	ldx.w #_bss_start
	ldy.w #_bss_start+1
	lda.w #_stk_top
	sec
	sbc.w #_bss_start
	mov #15
	jmp _pc65_main
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
n_004 .equ +7
partbefore_005 .equ -1
partafter_006 .equ -3
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
part_008 .equ +7
hundredsdigit_009 .equ -1
tenspart_010 .equ -3
tensdigit_011 .equ -5
onesdigit_012 .equ -7
;   41: 
;   42:             {Translate a single ones digit into a word,
;   43:              where 1 <= digit <= 9.}
;   44: 
;   45:             BEGIN
digit_014 .equ +7
doones_013 .sub
	phx.w
	tsx.w
;   46:                 CASE digit OF
	lda.w digit_014,X
;   47:                     1:  write (' one');
	cmp.w #1
	bne L_017
L_016
	psh.w #S_018
	psh.w #0
	psh.w #4
	jsr _swrite
	adj #6
	jmp L_015
L_017
;   48:                     2:  write (' two');
	cmp.w #2
	bne L_020
L_019
	psh.w #S_021
	psh.w #0
	psh.w #4
	jsr _swrite
	adj #6
	jmp L_015
L_020
;   49:                     3:  write (' three');
	cmp.w #3
	bne L_023
L_022
	psh.w #S_024
	psh.w #0
	psh.w #6
	jsr _swrite
	adj #6
	jmp L_015
L_023
;   50:                     4:  write (' four');
	cmp.w #4
	bne L_026
L_025
	psh.w #S_027
	psh.w #0
	psh.w #5
	jsr _swrite
	adj #6
	jmp L_015
L_026
;   51:                     5:  write (' five');
	cmp.w #5
	bne L_029
L_028
	psh.w #S_030
	psh.w #0
	psh.w #5
	jsr _swrite
	adj #6
	jmp L_015
L_029
;   52:                     6:  write (' six');
	cmp.w #6
	bne L_032
L_031
	psh.w #S_033
	psh.w #0
	psh.w #4
	jsr _swrite
	adj #6
	jmp L_015
L_032
;   53:                     7:  write (' seven');
	cmp.w #7
	bne L_035
L_034
	psh.w #S_036
	psh.w #0
	psh.w #6
	jsr _swrite
	adj #6
	jmp L_015
L_035
;   54:                     8:  write (' eight');
	cmp.w #8
	bne L_038
L_037
	psh.w #S_039
	psh.w #0
	psh.w #6
	jsr _swrite
	adj #6
	jmp L_015
L_038
;   55:                     9:  write (' nine');
	cmp.w #9
	bne L_041
L_040
	psh.w #S_042
	psh.w #0
	psh.w #5
	jsr _swrite
	adj #6
	jmp L_015
L_041
;   56:                 END;
L_015
;   57:             END {DoOnes};
	txs.w
	plx.w
	rts
	.end doones_013
;   58: 
;   59: 
;   60:             PROCEDURE DoTeens (teens : integer);
;   61: 
;   62:             {Translate the teens into a word,
;   63:              where 10 <= teens <= 19.}
;   64: 
;   65:             BEGIN
teens_044 .equ +7
doteens_043 .sub
	phx.w
	tsx.w
;   66:                 CASE teens OF
	lda.w teens_044,X
;   67:                     10:  write (' ten');
	cmp.w #10
	bne L_047
L_046
	psh.w #S_048
	psh.w #0
	psh.w #4
	jsr _swrite
	adj #6
	jmp L_045
L_047
;   68:                     11:  write (' eleven');
	cmp.w #11
	bne L_050
L_049
	psh.w #S_051
	psh.w #0
	psh.w #7
	jsr _swrite
	adj #6
	jmp L_045
L_050
;   69:                     12:  write (' twelve');
	cmp.w #12
	bne L_053
L_052
	psh.w #S_054
	psh.w #0
	psh.w #7
	jsr _swrite
	adj #6
	jmp L_045
L_053
;   70:                     13:  write (' thirteen');
	cmp.w #13
	bne L_056
L_055
	psh.w #S_057
	psh.w #0
	psh.w #9
	jsr _swrite
	adj #6
	jmp L_045
L_056
;   71:                     14:  write (' fourteen');
	cmp.w #14
	bne L_059
L_058
	psh.w #S_060
	psh.w #0
	psh.w #9
	jsr _swrite
	adj #6
	jmp L_045
L_059
;   72:                     15:  write (' fifteen');
	cmp.w #15
	bne L_062
L_061
	psh.w #S_063
	psh.w #0
	psh.w #8
	jsr _swrite
	adj #6
	jmp L_045
L_062
;   73:                     16:  write (' sixteen');
	cmp.w #16
	bne L_065
L_064
	psh.w #S_066
	psh.w #0
	psh.w #8
	jsr _swrite
	adj #6
	jmp L_045
L_065
;   74:                     17:  write (' seventeen');
	cmp.w #17
	bne L_068
L_067
	psh.w #S_069
	psh.w #0
	psh.w #10
	jsr _swrite
	adj #6
	jmp L_045
L_068
;   75:                     18:  write (' eighteen');
	cmp.w #18
	bne L_071
L_070
	psh.w #S_072
	psh.w #0
	psh.w #9
	jsr _swrite
	adj #6
	jmp L_045
L_071
;   76:                     19:  write (' nineteen');
	cmp.w #19
	bne L_074
L_073
	psh.w #S_075
	psh.w #0
	psh.w #9
	jsr _swrite
	adj #6
	jmp L_045
L_074
;   77:                 END;
L_045
;   78:             END {DoTeens};
	txs.w
	plx.w
	rts
	.end doteens_043
;   79: 
;   80: 
;   81:             PROCEDURE DoTens (digit : integer);
;   82: 
;   83:                 {Translate a single tens digit into a word,
;   84:                  where 2 <= digit <= 9.}
;   85: 
;   86:             BEGIN
digit_077 .equ +7
dotens_076 .sub
	phx.w
	tsx.w
;   87:                 CASE digit OF
	lda.w digit_077,X
;   88:                     2:  write (' twenty');
	cmp.w #2
	bne L_080
L_079
	psh.w #S_081
	psh.w #0
	psh.w #7
	jsr _swrite
	adj #6
	jmp L_078
L_080
;   89:                     3:  write (' thirty');
	cmp.w #3
	bne L_083
L_082
	psh.w #S_084
	psh.w #0
	psh.w #7
	jsr _swrite
	adj #6
	jmp L_078
L_083
;   90:                     4:  write (' forty');
	cmp.w #4
	bne L_086
L_085
	psh.w #S_087
	psh.w #0
	psh.w #6
	jsr _swrite
	adj #6
	jmp L_078
L_086
;   91:                     5:  write (' fifty');
	cmp.w #5
	bne L_089
L_088
	psh.w #S_090
	psh.w #0
	psh.w #6
	jsr _swrite
	adj #6
	jmp L_078
L_089
;   92:                     6:  write (' sixty');
	cmp.w #6
	bne L_092
L_091
	psh.w #S_093
	psh.w #0
	psh.w #6
	jsr _swrite
	adj #6
	jmp L_078
L_092
;   93:                     7:  write (' seventy');
	cmp.w #7
	bne L_095
L_094
	psh.w #S_096
	psh.w #0
	psh.w #8
	jsr _swrite
	adj #6
	jmp L_078
L_095
;   94:                     8:  write (' eighty');
	cmp.w #8
	bne L_098
L_097
	psh.w #S_099
	psh.w #0
	psh.w #7
	jsr _swrite
	adj #6
	jmp L_078
L_098
;   95:                     9:  write (' ninety');
	cmp.w #9
	bne L_101
L_100
	psh.w #S_102
	psh.w #0
	psh.w #7
	jsr _swrite
	adj #6
	jmp L_078
L_101
;   96:                 END;
L_078
;   97:             END {DoTens};
	txs.w
	plx.w
	rts
	.end dotens_076
;   98: 
;   99:         BEGIN {DoPart}
dopart_007 .sub
	phx.w
	tsx.w
	adj #-8
;  100: 
;  101:             {Break up the number part.}
;  102:             hundredsdigit := part DIV 100;
	lda.w part_008,X
	pha.w
	lda #100
	pha.w
	jsr _idiv
	adj #4
	sta.w hundredsdigit_009,X
;  103:             tenspart      := part MOD 100;
	lda.w part_008,X
	pha.w
	lda #100
	pha.w
	jsr _idiv
	adj #4
	swp a
	sta.w tenspart_010,X
;  104: 
;  105:             {Translate the hundreds digit.}
;  106:             IF hundredsdigit > 0 THEN BEGIN
	lda.w hundredsdigit_009,X
	pha.w
	lda #0
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	bgt L_105
	lda #0
L_105
	cmp.w #1
	beq L_103
	jmp L_104
L_103
;  107:                 DoOnes (hundredsdigit);
	lda.w hundredsdigit_009,X
	pha.w
	phx.w
	jsr doones_013
	adj #4
;  108:                 write (' hundred');
	psh.w #S_106
	psh.w #0
	psh.w #8
	jsr _swrite
	adj #6
;  109:             END;
L_104
;  110: 
;  111:             {Translate the tens part.}
;  112:             IF  (tenspart >= 10) AND (tenspart <= 19) THEN BEGIN
	lda.w tenspart_010,X
	pha.w
	lda #10
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	bge L_109
	lda #0
L_109
	pha.w
	lda.w tenspart_010,X
	pha.w
	lda #19
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	ble L_110
	lda #0
L_110
	and.w 1,S
	adj #2
	cmp.w #1
	beq L_107
	jmp L_108
L_107
;  113:                 DoTeens (tenspart);
	lda.w tenspart_010,X
	pha.w
	phx.w
	jsr doteens_043
	adj #4
;  114:             END
;  115:             ELSE BEGIN
	jmp L_111
L_108
;  116:                 tensdigit := tenspart DIV 10;
	lda.w tenspart_010,X
	pha.w
	lda #10
	pha.w
	jsr _idiv
	adj #4
	sta.w tensdigit_011,X
;  117:                 onesdigit := tenspart MOD 10;
	lda.w tenspart_010,X
	pha.w
	lda #10
	pha.w
	jsr _idiv
	adj #4
	swp a
	sta.w onesdigit_012,X
;  118: 
;  119:                 IF tensdigit > 0 THEN DoTens (tensdigit);
	lda.w tensdigit_011,X
	pha.w
	lda #0
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	bgt L_114
	lda #0
L_114
	cmp.w #1
	beq L_112
	jmp L_113
L_112
	lda.w tensdigit_011,X
	pha.w
	phx.w
	jsr dotens_076
	adj #4
L_113
;  120:                 IF onesdigit > 0 THEN DoOnes (onesdigit);
	lda.w onesdigit_012,X
	pha.w
	lda #0
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	bgt L_117
	lda #0
L_117
	cmp.w #1
	beq L_115
	jmp L_116
L_115
	lda.w onesdigit_012,X
	pha.w
	phx.w
	jsr doones_013
	adj #4
L_116
;  121:             END;
L_111
;  122:         END {DoPart};
	txs.w
	plx.w
	rts
	.end dopart_007
;  123: 
;  124:     BEGIN {Translate}
translate_003 .sub
	phx.w
	tsx.w
	adj #-4
;  125: 
;  126:         {Break up the number.}
;  127:         partbefore := n DIV 1000;
	lda.w n_004,X
	pha.w
	lda.w #1000
	pha.w
	jsr _idiv
	adj #4
	sta.w partbefore_005,X
;  128:         partafter  := n MOD 1000;
	lda.w n_004,X
	pha.w
	lda.w #1000
	pha.w
	jsr _idiv
	adj #4
	swp a
	sta.w partafter_006,X
;  129: 
;  130:         IF partbefore > 0 THEN BEGIN
	lda.w partbefore_005,X
	pha.w
	lda #0
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	bgt L_120
	lda #0
L_120
	cmp.w #1
	beq L_118
	jmp L_119
L_118
;  131:             DoPart (partbefore);
	lda.w partbefore_005,X
	pha.w
	phx.w
	jsr dopart_007
	adj #4
;  132:             write (' thousand');
	psh.w #S_121
	psh.w #0
	psh.w #9
	jsr _swrite
	adj #6
;  133:         END;
L_119
;  134: 
;  135:         IF partafter > 0 THEN DoPart (partafter);
	lda.w partafter_006,X
	pha.w
	lda #0
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	bgt L_124
	lda #0
L_124
	cmp.w #1
	beq L_122
	jmp L_123
L_122
	lda.w partafter_006,X
	pha.w
	phx.w
	jsr dopart_007
	adj #4
L_123
;  136:     END {Translate};
	txs.w
	plx.w
	rts
	.end translate_003
;  137: 
;  138: 
;  139: BEGIN {NumberTranslator}
_pc65_main .sub
	phx.w
	tsx.w
;  140: 
;  141:     {Loop to read, write, check, and translate the numbers.}
;  142:     REPEAT
L_125
;  143:         read (number);
	psh.w #number_002
	jsr _iread
	pli
	sta.w 0,I++
;  144:         write (number:6, ' :');
	lda.w number_002
	pha.w
	lda #6
	pha.w
	jsr _iwrite
	adj #4
	psh.w #S_127
	psh.w #0
	psh.w #2
	jsr _swrite
	adj #6
;  145: 
;  146:         IF number < 0 THEN BEGIN
	lda.w number_002
	pha.w
	lda #0
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	blt L_130
	lda #0
L_130
	cmp.w #1
	beq L_128
	jmp L_129
L_128
;  147:             write (' ***** Error -- number < 0');
	psh.w #S_131
	psh.w #0
	psh.w #26
	jsr _swrite
	adj #6
;  148:         END
;  149:         ELSE IF number > maxnumber THEN BEGIN
	jmp L_132
L_129
	lda.w number_002
	pha.w
	lda.w #30000
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	bgt L_135
	lda #0
L_135
	cmp.w #1
	beq L_133
	jmp L_134
L_133
;  150:             write (' ***** Error -- number > ', maxnumber:1);
	psh.w #S_136
	psh.w #0
	psh.w #25
	jsr _swrite
	adj #6
	lda.w #30000
	pha.w
	lda #1
	pha.w
	jsr _iwrite
	adj #4
;  151:         END
;  152:         ELSE IF number = 0 THEN BEGIN
	jmp L_137
L_134
	lda.w number_002
	pha.w
	lda #0
	xma.w 1,S
	cmp.w 1,S
	adj #2
	php
	lda #1
	plp
	beq L_140
	lda #0
L_140
	cmp.w #1
	beq L_138
	jmp L_139
L_138
;  153:             write (' zero');
	psh.w #S_141
	psh.w #0
	psh.w #5
	jsr _swrite
	adj #6
;  154:         END
;  155:         ELSE BEGIN
	jmp L_142
L_139
;  156:             Translate (number);
	lda.w number_002
	pha.w
	phx.w
	jsr translate_003
	adj #4
;  157:         END;
L_142
L_137
L_132
;  158: 
;  159:         writeln;  {complete output line}
	jsr _writeln
;  160:     UNTIL number = terminator;
	lda.w number_002
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
	beq L_126
	jmp L_125
L_126
;  161: END {NumberTranslator}.
	plx.w
	rts
	.end _pc65_main

	.dat

S_141 .str " zero"
S_136 .str " ***** Error -- number > "
S_131 .str " ***** Error -- number < 0"
S_127 .str " :"
S_121 .str " thousand"
S_106 .str " hundred"
S_102 .str " ninety"
S_099 .str " eighty"
S_096 .str " seventy"
S_093 .str " sixty"
S_090 .str " fifty"
S_087 .str " forty"
S_084 .str " thirty"
S_081 .str " twenty"
S_075 .str " nineteen"
S_072 .str " eighteen"
S_069 .str " seventeen"
S_066 .str " sixteen"
S_063 .str " fifteen"
S_060 .str " fourteen"
S_057 .str " thirteen"
S_054 .str " twelve"
S_051 .str " eleven"
S_048 .str " ten"
S_042 .str " nine"
S_039 .str " eight"
S_036 .str " seven"
S_033 .str " six"
S_030 .str " five"
S_027 .str " four"
S_024 .str " three"
S_021 .str " two"
S_018 .str " one"
_bss_start .byt 1
number_002 .wrd 1
_bss_end .byt 1
_stk .byt 1023
_stk_top .byt 1

	.end
