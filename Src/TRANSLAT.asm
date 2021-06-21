;    1: PROGRAM NumberTranslator (input, output);
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
;    3: {   Translate a list of integers from numeric form into
;    4:     words.  The integers must not be negative nor be
;    5:     greater than the value of maxnumber.  The last
;    6:     integer in the list has the value of terminator.
;    7: }
;    8: 
;    9: CONST
;   10:     maxnumber  = 30000;	{maximum allowable number}
;   11:     terminator = 0;     {last number in list}
;   12: 
;   13: VAR
;   14:     number : integer; 	{number to be translated}
;   15: 
;   16: 
;   17: PROCEDURE Translate (n : integer);
;   18: 
;   19:     {Translate number n into words.}
;   20: 
;   21:     VAR
;   22: 	partbefore,    	{part before the comma}
;   23: 	partafter     	{part after the comma}
;   24: 	 : integer;
;   25: 
;   26: 
;   27:     PROCEDURE DoPart (part : integer);

n_004	EQU	<WORD PTR [bp+6]>
partbefore_005	EQU	<WORD PTR [bp-4]>
partafter_006	EQU	<WORD PTR [bp-8]>
;   28: 
;   29: 	{Translate a part of a number into words,
;   30: 	 where 1 <= part <= 999.}
;   31: 
;   32: 	VAR
;   33: 	    hundredsdigit,	{hundreds digit 0..9}
;   34: 	    tenspart,        	{tens part 0..99}
;   35: 	    tensdigit,       	{tens digit 0..9}
;   36: 	    onesdigit        	{ones digit 0..9}
;   37: 		: integer;
;   38: 
;   39: 
;   40: 	PROCEDURE DoOnes (digit : integer);

part_008	EQU	<WORD PTR [bp+6]>
hundredsdigit_009	EQU	<WORD PTR [bp-4]>
tenspart_010	EQU	<WORD PTR [bp-8]>
tensdigit_011	EQU	<WORD PTR [bp-12]>
onesdigit_012	EQU	<WORD PTR [bp-16]>
;   41: 
;   42: 	    {Translate a single ones digit into a word,
;   43: 	     where 1 <= digit <= 9.}
;   44: 
;   45: 	    BEGIN

digit_014	EQU	<WORD PTR [bp+6]>

doones_013	PROC

	push	bp
	mov		bp,sp
;   46: 		CASE digit OF
	mov		ax,WORD PTR digit_014
;   47: 		    1:  write (' one');
	cmp		ax,1
	jne		$L_017
$L_016:
	lea		ax,WORD PTR $S_018
	push	ax
	mov		ax,0
	push	ax
	mov		ax,4
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_015
$L_017:
;   48: 		    2:  write (' two');
	cmp		ax,2
	jne		$L_020
$L_019:
	lea		ax,WORD PTR $S_021
	push	ax
	mov		ax,0
	push	ax
	mov		ax,4
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_015
$L_020:
;   49: 		    3:  write (' three');
	cmp		ax,3
	jne		$L_023
$L_022:
	lea		ax,WORD PTR $S_024
	push	ax
	mov		ax,0
	push	ax
	mov		ax,6
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_015
$L_023:
;   50: 		    4:  write (' four');
	cmp		ax,4
	jne		$L_026
$L_025:
	lea		ax,WORD PTR $S_027
	push	ax
	mov		ax,0
	push	ax
	mov		ax,5
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_015
$L_026:
;   51: 		    5:  write (' five');
	cmp		ax,5
	jne		$L_029
$L_028:
	lea		ax,WORD PTR $S_030
	push	ax
	mov		ax,0
	push	ax
	mov		ax,5
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_015
$L_029:
;   52: 		    6:  write (' six');
	cmp		ax,6
	jne		$L_032
$L_031:
	lea		ax,WORD PTR $S_033
	push	ax
	mov		ax,0
	push	ax
	mov		ax,4
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_015
$L_032:
;   53: 		    7:  write (' seven');
	cmp		ax,7
	jne		$L_035
$L_034:
	lea		ax,WORD PTR $S_036
	push	ax
	mov		ax,0
	push	ax
	mov		ax,6
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_015
$L_035:
;   54: 		    8:  write (' eight');
	cmp		ax,8
	jne		$L_038
$L_037:
	lea		ax,WORD PTR $S_039
	push	ax
	mov		ax,0
	push	ax
	mov		ax,6
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_015
$L_038:
;   55: 		    9:  write (' nine');
	cmp		ax,9
	jne		$L_041
$L_040:
	lea		ax,WORD PTR $S_042
	push	ax
	mov		ax,0
	push	ax
	mov		ax,5
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_015
$L_041:
;   56: 		END;
$L_015:
;   57: 	    END {DoOnes};
	mov		sp,bp
	pop		bp
	ret		6

doones_013	ENDP
;   58: 
;   59: 
;   60: 	PROCEDURE DoTeens (teens : integer);
;   61: 
;   62: 	    {Translate the teens into a word,
;   63: 	     where 10 <= teens <= 19.}
;   64: 
;   65: 	    BEGIN

teens_044	EQU	<WORD PTR [bp+6]>

doteens_043	PROC

	push	bp
	mov		bp,sp
;   66: 		CASE teens OF
	mov		ax,WORD PTR teens_044
;   67: 		    10:  write (' ten');
	cmp		ax,10
	jne		$L_047
$L_046:
	lea		ax,WORD PTR $S_048
	push	ax
	mov		ax,0
	push	ax
	mov		ax,4
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_045
$L_047:
;   68: 		    11:  write (' eleven');
	cmp		ax,11
	jne		$L_050
$L_049:
	lea		ax,WORD PTR $S_051
	push	ax
	mov		ax,0
	push	ax
	mov		ax,7
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_045
$L_050:
;   69: 		    12:  write (' twelve');
	cmp		ax,12
	jne		$L_053
$L_052:
	lea		ax,WORD PTR $S_054
	push	ax
	mov		ax,0
	push	ax
	mov		ax,7
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_045
$L_053:
;   70: 		    13:  write (' thirteen');
	cmp		ax,13
	jne		$L_056
$L_055:
	lea		ax,WORD PTR $S_057
	push	ax
	mov		ax,0
	push	ax
	mov		ax,9
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_045
$L_056:
;   71: 		    14:  write (' fourteen');
	cmp		ax,14
	jne		$L_059
$L_058:
	lea		ax,WORD PTR $S_060
	push	ax
	mov		ax,0
	push	ax
	mov		ax,9
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_045
$L_059:
;   72: 		    15:  write (' fifteen');
	cmp		ax,15
	jne		$L_062
$L_061:
	lea		ax,WORD PTR $S_063
	push	ax
	mov		ax,0
	push	ax
	mov		ax,8
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_045
$L_062:
;   73: 		    16:  write (' sixteen');
	cmp		ax,16
	jne		$L_065
$L_064:
	lea		ax,WORD PTR $S_066
	push	ax
	mov		ax,0
	push	ax
	mov		ax,8
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_045
$L_065:
;   74: 		    17:  write (' seventeen');
	cmp		ax,17
	jne		$L_068
$L_067:
	lea		ax,WORD PTR $S_069
	push	ax
	mov		ax,0
	push	ax
	mov		ax,10
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_045
$L_068:
;   75: 		    18:  write (' eighteen');
	cmp		ax,18
	jne		$L_071
$L_070:
	lea		ax,WORD PTR $S_072
	push	ax
	mov		ax,0
	push	ax
	mov		ax,9
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_045
$L_071:
;   76: 		    19:  write (' nineteen');
	cmp		ax,19
	jne		$L_074
$L_073:
	lea		ax,WORD PTR $S_075
	push	ax
	mov		ax,0
	push	ax
	mov		ax,9
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_045
$L_074:
;   77: 		END;
$L_045:
;   78: 	    END {DoTeens};
	mov		sp,bp
	pop		bp
	ret		6

doteens_043	ENDP
;   79: 
;   80: 
;   81: 	PROCEDURE DoTens (digit : integer);
;   82: 
;   83: 	    {Translate a single tens digit into a word,
;   84: 	     where 2 <= digit <= 9.}
;   85: 
;   86: 	    BEGIN

digit_077	EQU	<WORD PTR [bp+6]>

dotens_076	PROC

	push	bp
	mov		bp,sp
;   87: 		CASE digit OF
	mov		ax,WORD PTR digit_077
;   88: 		    2:  write (' twenty');
	cmp		ax,2
	jne		$L_080
$L_079:
	lea		ax,WORD PTR $S_081
	push	ax
	mov		ax,0
	push	ax
	mov		ax,7
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_078
$L_080:
;   89: 		    3:  write (' thirty');
	cmp		ax,3
	jne		$L_083
$L_082:
	lea		ax,WORD PTR $S_084
	push	ax
	mov		ax,0
	push	ax
	mov		ax,7
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_078
$L_083:
;   90: 		    4:  write (' forty');
	cmp		ax,4
	jne		$L_086
$L_085:
	lea		ax,WORD PTR $S_087
	push	ax
	mov		ax,0
	push	ax
	mov		ax,6
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_078
$L_086:
;   91: 		    5:  write (' fifty');
	cmp		ax,5
	jne		$L_089
$L_088:
	lea		ax,WORD PTR $S_090
	push	ax
	mov		ax,0
	push	ax
	mov		ax,6
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_078
$L_089:
;   92: 		    6:  write (' sixty');
	cmp		ax,6
	jne		$L_092
$L_091:
	lea		ax,WORD PTR $S_093
	push	ax
	mov		ax,0
	push	ax
	mov		ax,6
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_078
$L_092:
;   93: 		    7:  write (' seventy');
	cmp		ax,7
	jne		$L_095
$L_094:
	lea		ax,WORD PTR $S_096
	push	ax
	mov		ax,0
	push	ax
	mov		ax,8
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_078
$L_095:
;   94: 		    8:  write (' eighty');
	cmp		ax,8
	jne		$L_098
$L_097:
	lea		ax,WORD PTR $S_099
	push	ax
	mov		ax,0
	push	ax
	mov		ax,7
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_078
$L_098:
;   95: 		    9:  write (' ninety');
	cmp		ax,9
	jne		$L_101
$L_100:
	lea		ax,WORD PTR $S_102
	push	ax
	mov		ax,0
	push	ax
	mov		ax,7
	push	ax
	call	_write_string
	add		sp,6
	jmp		$L_078
$L_101:
;   96: 		END;
$L_078:
;   97: 	    END {DoTens};
	mov		sp,bp
	pop		bp
	ret		6

dotens_076	ENDP
;   98: 
;   99: 
;  100: 	BEGIN {DoPart}

dopart_007	PROC

	push	bp
	mov		bp,sp
	sub		sp,16
;  101: 
;  102: 	    {Break up the number part.}
;  103: 	    hundredsdigit := part DIV 100;
	mov		ax,WORD PTR part_008
	push	ax
	mov		ax,100
	mov		cx,ax
	pop		ax
	sub		dx,dx
	idiv	cx
	mov		WORD PTR hundredsdigit_009,ax
;  104: 	    tenspart      := part MOD 100;
	mov		ax,WORD PTR part_008
	push	ax
	mov		ax,100
	mov		cx,ax
	pop		ax
	sub		dx,dx
	idiv	cx
	mov		ax,dx
	mov		WORD PTR tenspart_010,ax
;  105: 
;  106: 	    {Translate the hundreds digit.}
;  107: 	    IF hundredsdigit > 0 THEN BEGIN
	mov		ax,WORD PTR hundredsdigit_009
	push	ax
	mov		ax,0
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jg		$L_105
	sub		ax,ax
$L_105:
	cmp		ax,1
	je		$L_103
	jmp		$L_104
$L_103:
;  108: 		DoOnes (hundredsdigit);
	mov		ax,WORD PTR hundredsdigit_009
	push	ax
	push	bp
	call	doones_013
;  109: 		write (' hundred');
	lea		ax,WORD PTR $S_106
	push	ax
	mov		ax,0
	push	ax
	mov		ax,8
	push	ax
	call	_write_string
	add		sp,6
;  110: 	    END;
$L_104:
;  111: 
;  112: 	    {Translate the tens part.}
;  113: 	    IF  (tenspart >= 10)
	mov		ax,WORD PTR tenspart_010
	push	ax
	mov		ax,10
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jge		$L_109
	sub		ax,ax
$L_109:
;  114: 	    AND (tenspart <= 19) THEN BEGIN
	push	ax
	mov		ax,WORD PTR tenspart_010
	push	ax
	mov		ax,19
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jle		$L_110
	sub		ax,ax
$L_110:
	pop		dx
	and		ax,dx
	cmp		ax,1
	je		$L_107
	jmp		$L_108
$L_107:
;  115: 		DoTeens (tenspart);
	mov		ax,WORD PTR tenspart_010
	push	ax
	push	bp
	call	doteens_043
;  116: 	    END
;  117: 	    ELSE BEGIN
	jmp		$L_111
$L_108:
;  118: 		tensdigit := tenspart DIV 10;
	mov		ax,WORD PTR tenspart_010
	push	ax
	mov		ax,10
	mov		cx,ax
	pop		ax
	sub		dx,dx
	idiv	cx
	mov		WORD PTR tensdigit_011,ax
;  119: 		onesdigit := tenspart MOD 10;
	mov		ax,WORD PTR tenspart_010
	push	ax
	mov		ax,10
	mov		cx,ax
	pop		ax
	sub		dx,dx
	idiv	cx
	mov		ax,dx
	mov		WORD PTR onesdigit_012,ax
;  120: 
;  121: 		IF tensdigit > 0 THEN DoTens (tensdigit);
	mov		ax,WORD PTR tensdigit_011
	push	ax
	mov		ax,0
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jg		$L_114
	sub		ax,ax
$L_114:
	cmp		ax,1
	je		$L_112
	jmp		$L_113
$L_112:
	mov		ax,WORD PTR tensdigit_011
	push	ax
	push	bp
	call	dotens_076
$L_113:
;  122: 		IF onesdigit > 0 THEN DoOnes (onesdigit);
	mov		ax,WORD PTR onesdigit_012
	push	ax
	mov		ax,0
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jg		$L_117
	sub		ax,ax
$L_117:
	cmp		ax,1
	je		$L_115
	jmp		$L_116
$L_115:
	mov		ax,WORD PTR onesdigit_012
	push	ax
	push	bp
	call	doones_013
$L_116:
;  123: 	    END;
$L_111:
;  124: 	END {DoPart};
	mov		sp,bp
	pop		bp
	ret		6

dopart_007	ENDP
;  125: 
;  126: 
;  127:     BEGIN {Translate}

translate_003	PROC

	push	bp
	mov		bp,sp
	sub		sp,8
;  128: 
;  129: 	{Break up the number.}
;  130: 	partbefore := n DIV 1000;
	mov		ax,WORD PTR n_004
	push	ax
	mov		ax,1000
	mov		cx,ax
	pop		ax
	sub		dx,dx
	idiv	cx
	mov		WORD PTR partbefore_005,ax
;  131: 	partafter  := n MOD 1000;
	mov		ax,WORD PTR n_004
	push	ax
	mov		ax,1000
	mov		cx,ax
	pop		ax
	sub		dx,dx
	idiv	cx
	mov		ax,dx
	mov		WORD PTR partafter_006,ax
;  132: 
;  133: 	IF partbefore > 0 THEN BEGIN
	mov		ax,WORD PTR partbefore_005
	push	ax
	mov		ax,0
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jg		$L_120
	sub		ax,ax
$L_120:
	cmp		ax,1
	je		$L_118
	jmp		$L_119
$L_118:
;  134: 	    DoPart (partbefore);
	mov		ax,WORD PTR partbefore_005
	push	ax
	push	bp
	call	dopart_007
;  135: 	    write (' thousand');
	lea		ax,WORD PTR $S_121
	push	ax
	mov		ax,0
	push	ax
	mov		ax,9
	push	ax
	call	_write_string
	add		sp,6
;  136: 	END;
$L_119:
;  137: 	IF partafter > 0 THEN DoPart (partafter);
	mov		ax,WORD PTR partafter_006
	push	ax
	mov		ax,0
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jg		$L_124
	sub		ax,ax
$L_124:
	cmp		ax,1
	je		$L_122
	jmp		$L_123
$L_122:
	mov		ax,WORD PTR partafter_006
	push	ax
	push	bp
	call	dopart_007
$L_123:
;  138:     END {Translate};
	mov		sp,bp
	pop		bp
	ret		6

translate_003	ENDP
;  139: 
;  140: 
;  141: BEGIN {NumberTranslator}

_pascal_main	PROC

	push	bp
	mov		bp,sp
;  142: 
;  143:     {Loop to read, write, check, and translate the numbers.}
;  144:     REPEAT
$L_125:
;  145: 	read (number);
	lea		ax,WORD PTR number_002
	push	ax
	call	_read_integer
	pop		bx
	mov		WORD PTR [bx],ax
;  146: 	write (number:6, ' :');
	mov		ax,WORD PTR number_002
	push	ax
	mov		ax,6
	push	ax
	call	_write_integer
	add		sp,4
	lea		ax,WORD PTR $S_127
	push	ax
	mov		ax,0
	push	ax
	mov		ax,2
	push	ax
	call	_write_string
	add		sp,6
;  147: 
;  148: 	IF number < 0 THEN BEGIN
	mov		ax,WORD PTR number_002
	push	ax
	mov		ax,0
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jl		$L_130
	sub		ax,ax
$L_130:
	cmp		ax,1
	je		$L_128
	jmp		$L_129
$L_128:
;  149: 	    write (' ***** Error -- number < 0');
	lea		ax,WORD PTR $S_131
	push	ax
	mov		ax,0
	push	ax
	mov		ax,26
	push	ax
	call	_write_string
	add		sp,6
;  150: 	END
;  151: 	ELSE IF number > maxnumber THEN BEGIN
	jmp		$L_132
$L_129:
	mov		ax,WORD PTR number_002
	push	ax
	mov		ax,30000
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jg		$L_135
	sub		ax,ax
$L_135:
	cmp		ax,1
	je		$L_133
	jmp		$L_134
$L_133:
;  152: 	    write (' ***** Error -- number > ', maxnumber:1);
	lea		ax,WORD PTR $S_136
	push	ax
	mov		ax,0
	push	ax
	mov		ax,25
	push	ax
	call	_write_string
	add		sp,6
	mov		ax,30000
	push	ax
	mov		ax,1
	push	ax
	call	_write_integer
	add		sp,4
;  153: 	END
;  154: 	ELSE IF number = 0 THEN BEGIN
	jmp		$L_137
$L_134:
	mov		ax,WORD PTR number_002
	push	ax
	mov		ax,0
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_140
	sub		ax,ax
$L_140:
	cmp		ax,1
	je		$L_138
	jmp		$L_139
$L_138:
;  155: 	    write (' zero');
	lea		ax,WORD PTR $S_141
	push	ax
	mov		ax,0
	push	ax
	mov		ax,5
	push	ax
	call	_write_string
	add		sp,6
;  156: 	END
;  157: 	ELSE BEGIN
	jmp		$L_142
$L_139:
;  158: 	    Translate (number);
	mov		ax,WORD PTR number_002
	push	ax
	push	bp
	call	translate_003
;  159: 	END;
$L_142:
$L_137:
$L_132:
;  160: 
;  161: 	writeln;  {complete output line}
	call	_write_line
;  162:     UNTIL number = terminator;
	mov		ax,WORD PTR number_002
	push	ax
	mov		ax,0
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_143
	sub		ax,ax
$L_143:
	cmp		ax,1
	je		$L_126
	jmp		$L_125
$L_126:
;  163: END {NumberTranslator}.

	pop		bp
	ret	

_pascal_main	ENDP

	.DATA

number_002	DW	0
$S_141	DB	" zero"
$S_136	DB	" ***** Error -- number > "
$S_131	DB	" ***** Error -- number < 0"
$S_127	DB	" :"
$S_121	DB	" thousand"
$S_106	DB	" hundred"
$S_102	DB	" ninety"
$S_099	DB	" eighty"
$S_096	DB	" seventy"
$S_093	DB	" sixty"
$S_090	DB	" fifty"
$S_087	DB	" forty"
$S_084	DB	" thirty"
$S_081	DB	" twenty"
$S_075	DB	" nineteen"
$S_072	DB	" eighteen"
$S_069	DB	" seventeen"
$S_066	DB	" sixteen"
$S_063	DB	" fifteen"
$S_060	DB	" fourteen"
$S_057	DB	" thirteen"
$S_054	DB	" twelve"
$S_051	DB	" eleven"
$S_048	DB	" ten"
$S_042	DB	" nine"
$S_039	DB	" eight"
$S_036	DB	" seven"
$S_033	DB	" six"
$S_030	DB	" five"
$S_027	DB	" four"
$S_024	DB	" three"
$S_021	DB	" two"
$S_018	DB	" one"

	END
