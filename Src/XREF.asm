;    1: PROGRAM xref (input, output);
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
word_002	EQU	0
;   21:                firstnumberindex,    {head and tail of    }
;   22:                lastnumberindex      {  linked number list}
;   23:                    : numbertableindex;
firstnumberindex_003	EQU	20
lastnumberindex_004	EQU	22
;   24:                END;
;   25: 
;   26:     numberentrytype  = RECORD  {entry in number table}
;   27:                number                   {line number}
;   28:                    : linenumbertype;
number_005	EQU	0
;   29:                nextindex                {index of next   }
;   30:                    : numbertableindex;  {  in linked list}
nextindex_006	EQU	2
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

ch_017	EQU	<BYTE PTR [bp-6]>

nextchar_016	PROC

	push	bp
	mov		bp,sp
	sub		sp,4
	sub		sp,2
;   58:     newline := eoln;
	call	_std_end_of_line
	mov		WORD PTR newline_014,ax
;   59:     IF newline THEN BEGIN
	mov		ax,WORD PTR newline_014
	cmp		ax,1
	je		$L_018
	jmp		$L_019
$L_018:
;   60:         readln;
	call	_read_line
;   61:         writeln;
	call	_write_line
;   62:         linenumber := linenumber + 1;
	mov		ax,WORD PTR linenumber_011
	push	ax
	mov		ax,1
	pop		dx
	add		ax,dx
	mov		WORD PTR linenumber_011,ax
;   63:         write(linenumber:5, ' : ');
	mov		ax,WORD PTR linenumber_011
	push	ax
	mov		ax,5
	push	ax
	call	_write_integer
	add		sp,4
	lea		ax,WORD PTR $S_020
	push	ax
	mov		ax,0
	push	ax
	mov		ax,3
	push	ax
	call	_write_string
	add		sp,6
;   64:     END;
$L_019:
;   65:     IF newline OR eof THEN BEGIN
	mov		ax,WORD PTR newline_014
	push	ax
	call	_std_end_of_file
	pop		dx
	or		ax,dx
	cmp		ax,1
	je		$L_021
	jmp		$L_022
$L_021:
;   66:         ch := blank;
	mov		ax,' '
	mov		BYTE PTR ch_017,al
;   67:     END
;   68:     ELSE BEGIN
	jmp		$L_023
$L_022:
;   69:         read(ch);
	lea		ax,WORD PTR ch_017
	push	ax
	call	_read_char
	pop		bx
	mov		BYTE PTR [bx],al
;   70:         write(ch);
	sub		ax,ax
	mov		al,BYTE PTR ch_017
	push	ax
	mov		ax,0
	push	ax
	call	_write_char
	add		sp,4
;   71:     END;
$L_023:
;   72:     nextchar := ch;
	lea		ax,$RETURN_VALUE
	push	ax
	sub		ax,ax
	mov		al,BYTE PTR ch_017
	pop		bx
	mov		BYTE PTR [bx],al
;   73:     END;
	mov		ax,$RETURN_VALUE
	mov		sp,bp
	pop		bp
	ret		2

nextchar_016	ENDP
;   74: 
;   75: 
;   76: FUNCTION isletter (ch : char) : boolean;
;   77: 
;   78:     {Return true if the character is a letter, false otherwise.}
;   79: 
;   80:     BEGIN

ch_025	EQU	<BYTE PTR [bp+6]>

isletter_024	PROC

	push	bp
	mov		bp,sp
	sub		sp,4
;   81:     isletter :=    ((ch >= 'a') AND (ch <= 'z'))
	lea		ax,$RETURN_VALUE
	push	ax
	sub		ax,ax
	mov		al,BYTE PTR ch_025
	push	ax
	mov		ax,'a'
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jge		$L_026
	sub		ax,ax
$L_026:
	push	ax
	sub		ax,ax
	mov		al,BYTE PTR ch_025
	push	ax
	mov		ax,'z'
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jle		$L_027
	sub		ax,ax
$L_027:
	pop		dx
	and		ax,dx
;   82:             OR ((ch >= 'A') AND (ch <= 'Z'));
	push	ax
	sub		ax,ax
	mov		al,BYTE PTR ch_025
	push	ax
	mov		ax,'A'
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jge		$L_028
	sub		ax,ax
$L_028:
	push	ax
	sub		ax,ax
	mov		al,BYTE PTR ch_025
	push	ax
	mov		ax,'Z'
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jle		$L_029
	sub		ax,ax
$L_029:
	pop		dx
	and		ax,dx
	pop		dx
	or		ax,dx
	pop		bx
	mov		WORD PTR [bx],ax
;   83:     END;
	mov		ax,$RETURN_VALUE
	mov		sp,bp
	pop		bp
	ret		4

isletter_024	ENDP
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

buffer_031	EQU	<WORD PTR [bp+6]>
charcount_032	EQU	<WORD PTR [bp-2]>
ch_033	EQU	<BYTE PTR [bp-4]>

readword_030	PROC

	push	bp
	mov		bp,sp
	sub		sp,4
;   98:     gotword := false;
	mov		ax,0
	mov		WORD PTR gotword_015,ax
;   99: 
;  100:     {Skip over any preceding non-letters.}
;  101:     IF NOT eof THEN BEGIN
	call	_std_end_of_file
	xor		ax,1
	cmp		ax,1
	je		$L_034
	jmp		$L_035
$L_034:
;  102:         REPEAT
$L_036:
;  103:         ch := nextchar;
	push	$STATIC_LINK
	call	nextchar_016
	mov		BYTE PTR ch_033,al
;  104:         UNTIL eof OR isletter(ch);
	call	_std_end_of_file
	push	ax
	sub		ax,ax
	mov		al,BYTE PTR ch_033
	push	ax
	push	$STATIC_LINK
	call	isletter_024
	pop		dx
	or		ax,dx
	cmp		ax,1
	je		$L_037
	jmp		$L_036
$L_037:
;  105:     END;
$L_035:
;  106: 
;  107:     {Find a letter?}
;  108:     IF NOT eof THEN BEGIN
	call	_std_end_of_file
	xor		ax,1
	cmp		ax,1
	je		$L_038
	jmp		$L_039
$L_038:
;  109:         charcount := 0;
	mov		ax,0
	mov		WORD PTR charcount_032,ax
;  110: 
;  111:         {Place the word's letters into the buffer.
;  112:          Downshift uppercase letters.}
;  113:         WHILE isletter(ch) DO BEGIN
$L_040:
	sub		ax,ax
	mov		al,BYTE PTR ch_033
	push	ax
	push	$STATIC_LINK
	call	isletter_024
	cmp		ax,1
	je		$L_041
	jmp		$L_042
$L_041:
;  114:         IF charcount < maxwordlen THEN BEGIN
	mov		ax,WORD PTR charcount_032
	push	ax
	mov		ax,20
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jl		$L_045
	sub		ax,ax
$L_045:
	cmp		ax,1
	je		$L_043
	jmp		$L_044
$L_043:
;  115:             IF (ch >= 'A') AND (ch <= 'Z') THEN BEGIN
	sub		ax,ax
	mov		al,BYTE PTR ch_033
	push	ax
	mov		ax,'A'
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jge		$L_048
	sub		ax,ax
$L_048:
	push	ax
	sub		ax,ax
	mov		al,BYTE PTR ch_033
	push	ax
	mov		ax,'Z'
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jle		$L_049
	sub		ax,ax
$L_049:
	pop		dx
	and		ax,dx
	cmp		ax,1
	je		$L_046
	jmp		$L_047
$L_046:
;  116:             ch := chr(ord(ch) + (ord('a') - ord('A')));
	sub		ax,ax
	mov		al,BYTE PTR ch_033
	push	ax
	mov		ax,'a'
	push	ax
	mov		ax,'A'
	pop		dx
	sub		dx,ax
	mov		ax,dx
	pop		dx
	add		ax,dx
	mov		BYTE PTR ch_033,al
;  117:             END;
$L_047:
;  118:             charcount := charcount + 1;
	mov		ax,WORD PTR charcount_032
	push	ax
	mov		ax,1
	pop		dx
	add		ax,dx
	mov		WORD PTR charcount_032,ax
;  119:             buffer[charcount] := ch;
	mov		ax,WORD PTR buffer_031
	push	ax
	mov		ax,WORD PTR charcount_032
	sub		ax,1
	pop		dx
	add		dx,ax
	push	dx
	sub		ax,ax
	mov		al,BYTE PTR ch_033
	pop		bx
	mov		BYTE PTR [bx],al
;  120:         END;
$L_044:
;  121:         ch := nextchar;
	push	$STATIC_LINK
	call	nextchar_016
	mov		BYTE PTR ch_033,al
;  122:         END;
	jmp		$L_040
$L_042:
;  123: 
;  124:         {Pad the rest of the buffer with blanks.}
;  125:         FOR charcount := charcount + 1 TO maxwordlen DO BEGIN
	mov		ax,WORD PTR charcount_032
	push	ax
	mov		ax,1
	pop		dx
	add		ax,dx
	mov		WORD PTR charcount_032,ax
$L_050:
	mov		ax,20
	cmp		WORD PTR charcount_032,ax
	jle		$L_051
	jmp		$L_052
$L_051:
;  126:         buffer[charcount] := blank;
	mov		ax,WORD PTR buffer_031
	push	ax
	mov		ax,WORD PTR charcount_032
	sub		ax,1
	pop		dx
	add		dx,ax
	push	dx
	mov		ax,' '
	pop		bx
	mov		BYTE PTR [bx],al
;  127:         END;
	inc		WORD PTR charcount_032
	jmp		$L_050
$L_052:
	dec		WORD PTR charcount_032
;  128: 
;  129:         gotword := true;
	mov		ax,1
	mov		WORD PTR gotword_015,ax
;  130:     END;
$L_039:
;  131:     END;
	mov		sp,bp
	pop		bp
	ret		4

readword_030	ENDP
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

lastnumberindex_054	EQU	<WORD PTR [bp+6]>

appendlinenumber_053	PROC

	push	bp
	mov		bp,sp
	sub		sp,4
;  142:         IF nextnumberindex < numbertablesize THEN BEGIN
	mov		ax,WORD PTR nextnumberindex_010
	push	ax
	mov		ax,1000
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jl		$L_057
	sub		ax,ax
$L_057:
	cmp		ax,1
	je		$L_055
	jmp		$L_056
$L_055:
;  143:         IF lastnumberindex <> 0 THEN BEGIN
	mov		ax,WORD PTR lastnumberindex_054
	push	ax
	mov		ax,0
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jne		$L_060
	sub		ax,ax
$L_060:
	cmp		ax,1
	je		$L_058
	jmp		$L_059
$L_058:
;  144:             numbertable[lastnumberindex].nextindex := nextnumberindex;
	lea		ax,WORD PTR numbertable_008
	push	ax
	mov		ax,WORD PTR lastnumberindex_054
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		ax
	add		ax,nextindex_006
	push	ax
	mov		ax,WORD PTR nextnumberindex_010
	pop		bx
	mov		WORD PTR [bx],ax
;  145:         END;
$L_059:
;  146:         numbertable[nextnumberindex].number    := linenumber;
	lea		ax,WORD PTR numbertable_008
	push	ax
	mov		ax,WORD PTR nextnumberindex_010
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		ax
	add		ax,number_005
	push	ax
	mov		ax,WORD PTR linenumber_011
	pop		bx
	mov		WORD PTR [bx],ax
;  147:         numbertable[nextnumberindex].nextindex := 0;
	lea		ax,WORD PTR numbertable_008
	push	ax
	mov		ax,WORD PTR nextnumberindex_010
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		ax
	add		ax,nextindex_006
	push	ax
	mov		ax,0
	pop		bx
	mov		WORD PTR [bx],ax
;  148:         appendlinenumber := nextnumberindex;
	lea		ax,$RETURN_VALUE
	push	ax
	mov		ax,WORD PTR nextnumberindex_010
	pop		bx
	mov		WORD PTR [bx],ax
;  149:         nextnumberindex  := nextnumberindex + 1;
	mov		ax,WORD PTR nextnumberindex_010
	push	ax
	mov		ax,1
	pop		dx
	add		ax,dx
	mov		WORD PTR nextnumberindex_010,ax
;  150:         END
;  151:         ELSE BEGIN
	jmp		$L_061
$L_056:
;  152:             numbertablefull  := true;
	mov		ax,1
	mov		WORD PTR numbertablefull_013,ax
;  153:             appendlinenumber := 0;
	lea		ax,$RETURN_VALUE
	push	ax
	mov		ax,0
	pop		bx
	mov		WORD PTR [bx],ax
;  154:         END;
$L_061:
;  155:     END;
	mov		ax,$RETURN_VALUE
	mov		sp,bp
	pop		bp
	ret		4

appendlinenumber_053	ENDP
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

i_063	EQU	<WORD PTR [bp-2]>

enterword_062	PROC

	push	bp
	mov		bp,sp
	sub		sp,2
;  167:     {By the time we process a word at the end of an input line,
;  168:      linenumber has already been incremented, so temporarily
;  169:      decrement it.}
;  170:     IF newline THEN linenumber := linenumber - 1;
	mov		ax,WORD PTR newline_014
	cmp		ax,1
	je		$L_064
	jmp		$L_065
$L_064:
	mov		ax,WORD PTR linenumber_011
	push	ax
	mov		ax,1
	pop		dx
	sub		dx,ax
	mov		ax,dx
	mov		WORD PTR linenumber_011,ax
$L_065:
;  171: 
;  172:     {Search to see if the word has previously been entered.}
;  173:     i := 1;
	mov		ax,1
	mov		WORD PTR i_063,ax
;  174:     WHILE    wordtable[i].word
$L_066:
	lea		ax,WORD PTR wordtable_007
	push	ax
	mov		ax,WORD PTR i_063
	sub		ax,1
	mov		dx,24
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
;  175:           <> wordtable[nextwordindex].word DO BEGIN
	pop		ax
	add		ax,word_002
	push	ax
	lea		ax,WORD PTR wordtable_007
	push	ax
	mov		ax,WORD PTR nextwordindex_009
	sub		ax,1
	mov		dx,24
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		ax
	add		ax,word_002
	push	ax
	cld
	mov		cx,20
	pop		di
	pop		si
	mov		ax,ds
	mov		es,ax
	repe	cmpsb
	mov		ax,1
	jne		$L_069
	sub		ax,ax
$L_069:
	cmp		ax,1
	je		$L_067
	jmp		$L_068
$L_067:
;  176:         i := i + 1;
	mov		ax,WORD PTR i_063
	push	ax
	mov		ax,1
	pop		dx
	add		ax,dx
	mov		WORD PTR i_063,ax
;  177:     END;
	jmp		$L_066
$L_068:
;  178: 
;  179:     {Yes.  Update the previous entry.}
;  180:     IF i < nextwordindex THEN BEGIN
	mov		ax,WORD PTR i_063
	push	ax
	mov		ax,WORD PTR nextwordindex_009
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jl		$L_072
	sub		ax,ax
$L_072:
	cmp		ax,1
	je		$L_070
	jmp		$L_071
$L_070:
;  181:         wordtable[i].lastnumberindex :=
	lea		ax,WORD PTR wordtable_007
	push	ax
	mov		ax,WORD PTR i_063
	sub		ax,1
	mov		dx,24
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		ax
	add		ax,lastnumberindex_004
	push	ax
;  182:         appendlinenumber(wordtable[i].lastnumberindex);
	lea		ax,WORD PTR wordtable_007
	push	ax
	mov		ax,WORD PTR i_063
	sub		ax,1
	mov		dx,24
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		ax
	add		ax,lastnumberindex_004
	push	ax
	pop		bx
	mov		ax,WORD PTR [bx]
	push	ax
	push	$STATIC_LINK
	call	appendlinenumber_053
	pop		bx
	mov		WORD PTR [bx],ax
;  183:     END
;  184: 
;  185:     {No.  Initialize the entry at the end of the table.}
;  186:     ELSE IF nextwordindex < wordtablesize THEN BEGIN
	jmp		$L_073
$L_071:
	mov		ax,WORD PTR nextwordindex_009
	push	ax
	mov		ax,500
	pop		dx
	cmp		dx,ax
	mov		ax,1
	jl		$L_076
	sub		ax,ax
$L_076:
	cmp		ax,1
	je		$L_074
	jmp		$L_075
$L_074:
;  187:         nextwordindex := nextwordindex + 1;
	mov		ax,WORD PTR nextwordindex_009
	push	ax
	mov		ax,1
	pop		dx
	add		ax,dx
	mov		WORD PTR nextwordindex_009,ax
;  188:         wordtable[i].firstnumberindex := appendlinenumber(0);
	lea		ax,WORD PTR wordtable_007
	push	ax
	mov		ax,WORD PTR i_063
	sub		ax,1
	mov		dx,24
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		ax
	add		ax,firstnumberindex_003
	push	ax
	mov		ax,0
	push	ax
	push	$STATIC_LINK
	call	appendlinenumber_053
	pop		bx
	mov		WORD PTR [bx],ax
;  189:         wordtable[i].lastnumberindex :=
	lea		ax,WORD PTR wordtable_007
	push	ax
	mov		ax,WORD PTR i_063
	sub		ax,1
	mov		dx,24
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		ax
	add		ax,lastnumberindex_004
	push	ax
;  190:         wordtable[i].firstnumberindex;
	lea		ax,WORD PTR wordtable_007
	push	ax
	mov		ax,WORD PTR i_063
	sub		ax,1
	mov		dx,24
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		ax
	add		ax,firstnumberindex_003
	push	ax
	pop		bx
	mov		ax,WORD PTR [bx]
	pop		bx
	mov		WORD PTR [bx],ax
;  191:     END
;  192: 
;  193:     {Oops.  Table overflow!}
;  194:     ELSE wordtablefull := true;
	jmp		$L_077
$L_075:
	mov		ax,1
	mov		WORD PTR wordtablefull_012,ax
$L_077:
$L_073:
;  195: 
;  196:     IF newline THEN linenumber := linenumber + 1;
	mov		ax,WORD PTR newline_014
	cmp		ax,1
	je		$L_078
	jmp		$L_079
$L_078:
	mov		ax,WORD PTR linenumber_011
	push	ax
	mov		ax,1
	pop		dx
	add		ax,dx
	mov		WORD PTR linenumber_011,ax
$L_079:
;  197:     END;
	mov		sp,bp
	pop		bp
	ret		2

enterword_062	ENDP
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

i_081	EQU	<WORD PTR [bp-2]>
j_082	EQU	<WORD PTR [bp-4]>
temp_083	EQU	<WORD PTR [bp-28]>

sortwords_080	PROC

	push	bp
	mov		bp,sp
	sub		sp,28
;  209:     FOR i := 1 TO nextwordindex - 2 DO BEGIN
	mov		ax,1
	mov		WORD PTR i_081,ax
$L_084:
	mov		ax,WORD PTR nextwordindex_009
	push	ax
	mov		ax,2
	pop		dx
	sub		dx,ax
	mov		ax,dx
	cmp		WORD PTR i_081,ax
	jle		$L_085
	jmp		$L_086
$L_085:
;  210:         FOR j := i + 1 TO nextwordindex - 1 DO BEGIN
	mov		ax,WORD PTR i_081
	push	ax
	mov		ax,1
	pop		dx
	add		ax,dx
	mov		WORD PTR j_082,ax
$L_087:
	mov		ax,WORD PTR nextwordindex_009
	push	ax
	mov		ax,1
	pop		dx
	sub		dx,ax
	mov		ax,dx
	cmp		WORD PTR j_082,ax
	jle		$L_088
	jmp		$L_089
$L_088:
;  211:         IF wordtable[i].word > wordtable[j].word THEN BEGIN
	lea		ax,WORD PTR wordtable_007
	push	ax
	mov		ax,WORD PTR i_081
	sub		ax,1
	mov		dx,24
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		ax
	add		ax,word_002
	push	ax
	lea		ax,WORD PTR wordtable_007
	push	ax
	mov		ax,WORD PTR j_082
	sub		ax,1
	mov		dx,24
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		ax
	add		ax,word_002
	push	ax
	cld
	mov		cx,20
	pop		di
	pop		si
	mov		ax,ds
	mov		es,ax
	repe	cmpsb
	mov		ax,1
	jg		$L_092
	sub		ax,ax
$L_092:
	cmp		ax,1
	je		$L_090
	jmp		$L_091
$L_090:
;  212:             temp := wordtable[i];
	lea		ax,WORD PTR temp_083
	push	ax
	lea		ax,WORD PTR wordtable_007
	push	ax
	mov		ax,WORD PTR i_081
	sub		ax,1
	mov		dx,24
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		cx,24
	pop		si
	pop		di
	mov		ax,ds
	mov		es,ax
	cld
	rep	movsb
;  213:             wordtable[i] := wordtable[j];
	lea		ax,WORD PTR wordtable_007
	push	ax
	mov		ax,WORD PTR i_081
	sub		ax,1
	mov		dx,24
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	lea		ax,WORD PTR wordtable_007
	push	ax
	mov		ax,WORD PTR j_082
	sub		ax,1
	mov		dx,24
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	mov		cx,24
	pop		si
	pop		di
	mov		ax,ds
	mov		es,ax
	cld
	rep	movsb
;  214:             wordtable[j] := temp;
	lea		ax,WORD PTR wordtable_007
	push	ax
	mov		ax,WORD PTR j_082
	sub		ax,1
	mov		dx,24
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	lea		ax,WORD PTR temp_083
	push	ax
	mov		cx,24
	pop		si
	pop		di
	mov		ax,ds
	mov		es,ax
	cld
	rep	movsb
;  215:         END;
$L_091:
;  216:         END;
	inc		WORD PTR j_082
	jmp		$L_087
$L_089:
	dec		WORD PTR j_082
;  217:     END;
	inc		WORD PTR i_081
	jmp		$L_084
$L_086:
	dec		WORD PTR i_081
;  218:     END;
	mov		sp,bp
	pop		bp
	ret		2

sortwords_080	ENDP
;  219: 
;  220: 
;  221: PROCEDURE printnumbers (i : numbertableindex);
;  222: 
;  223:     {Print a word's linked list of line numbers.}
;  224: 
;  225:     BEGIN

i_094	EQU	<WORD PTR [bp+6]>

printnumbers_093	PROC

	push	bp
	mov		bp,sp
;  226:     REPEAT
$L_095:
;  227:         write(numbertable[i].number:4);
	lea		ax,WORD PTR numbertable_008
	push	ax
	mov		ax,WORD PTR i_094
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		ax
	add		ax,number_005
	push	ax
	pop		bx
	mov		ax,WORD PTR [bx]
	push	ax
	mov		ax,4
	push	ax
	call	_write_integer
	add		sp,4
;  228:         i := numbertable[i].nextindex;
	lea		ax,WORD PTR numbertable_008
	push	ax
	mov		ax,WORD PTR i_094
	mov		dx,4
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		ax
	add		ax,nextindex_006
	push	ax
	pop		bx
	mov		ax,WORD PTR [bx]
	mov		WORD PTR i_094,ax
;  229:     UNTIL i = 0;
	mov		ax,WORD PTR i_094
	push	ax
	mov		ax,0
	pop		dx
	cmp		dx,ax
	mov		ax,1
	je		$L_097
	sub		ax,ax
$L_097:
	cmp		ax,1
	je		$L_096
	jmp		$L_095
$L_096:
;  230:     writeln;
	call	_write_line
;  231:     END;
	mov		sp,bp
	pop		bp
	ret		4

printnumbers_093	ENDP
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

i_099	EQU	<WORD PTR [bp-2]>

printxref_098	PROC

	push	bp
	mov		bp,sp
	sub		sp,2
;  242:     writeln;
	call	_write_line
;  243:     writeln;
	call	_write_line
;  244:     writeln('Cross-reference');
	lea		ax,WORD PTR $S_100
	push	ax
	mov		ax,0
	push	ax
	mov		ax,15
	push	ax
	call	_write_string
	add		sp,6
	call	_write_line
;  245:     writeln('---------------');
	lea		ax,WORD PTR $S_101
	push	ax
	mov		ax,0
	push	ax
	mov		ax,15
	push	ax
	call	_write_string
	add		sp,6
	call	_write_line
;  246:     writeln;
	call	_write_line
;  247:     sortwords;
	push	$STATIC_LINK
	call	sortwords_080
;  248:     FOR i := 1 TO nextwordindex - 1 DO BEGIN
	mov		ax,1
	mov		WORD PTR i_099,ax
$L_102:
	mov		ax,WORD PTR nextwordindex_009
	push	ax
	mov		ax,1
	pop		dx
	sub		dx,ax
	mov		ax,dx
	cmp		WORD PTR i_099,ax
	jle		$L_103
	jmp		$L_104
$L_103:
;  249:         write(wordtable[i].word);
	lea		ax,WORD PTR wordtable_007
	push	ax
	mov		ax,WORD PTR i_099
	sub		ax,1
	mov		dx,24
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		ax
	add		ax,word_002
	push	ax
	mov		ax,0
	push	ax
	mov		ax,20
	push	ax
	call	_write_string
	add		sp,6
;  250:         printnumbers(wordtable[i].firstnumberindex);
	lea		ax,WORD PTR wordtable_007
	push	ax
	mov		ax,WORD PTR i_099
	sub		ax,1
	mov		dx,24
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		ax
	add		ax,firstnumberindex_003
	push	ax
	pop		bx
	mov		ax,WORD PTR [bx]
	push	ax
	push	$STATIC_LINK
	call	printnumbers_093
;  251:     END;
	inc		WORD PTR i_099
	jmp		$L_102
$L_104:
	dec		WORD PTR i_099
;  252:     END;
	mov		sp,bp
	pop		bp
	ret		2

printxref_098	ENDP
;  253: 
;  254: 
;  255: BEGIN {xref}

_pascal_main	PROC

	push	bp
	mov		bp,sp
;  256:     wordtablefull   := false;
	mov		ax,0
	mov		WORD PTR wordtablefull_012,ax
;  257:     numbertablefull := false;
	mov		ax,0
	mov		WORD PTR numbertablefull_013,ax
;  258:     nextwordindex   := 1;
	mov		ax,1
	mov		WORD PTR nextwordindex_009,ax
;  259:     nextnumberindex := 1;
	mov		ax,1
	mov		WORD PTR nextnumberindex_010,ax
;  260:     linenumber      := 1;
	mov		ax,1
	mov		WORD PTR linenumber_011,ax
;  261:     write('    1 : ');
	lea		ax,WORD PTR $S_105
	push	ax
	mov		ax,0
	push	ax
	mov		ax,8
	push	ax
	call	_write_string
	add		sp,6
;  262: 
;  263:     {First read the words.}
;  264:     WHILE NOT (eof OR wordtablefull OR numbertablefull) DO BEGIN
$L_106:
	call	_std_end_of_file
	push	ax
	mov		ax,WORD PTR wordtablefull_012
	pop		dx
	or		ax,dx
	push	ax
	mov		ax,WORD PTR numbertablefull_013
	pop		dx
	or		ax,dx
	xor		ax,1
	cmp		ax,1
	je		$L_107
	jmp		$L_108
$L_107:
;  265:     readword(wordtable[nextwordindex].word);
	lea		ax,WORD PTR wordtable_007
	push	ax
	mov		ax,WORD PTR nextwordindex_009
	sub		ax,1
	mov		dx,24
	imul	dx
	pop		dx
	add		dx,ax
	push	dx
	pop		ax
	add		ax,word_002
	push	ax
	push	bp
	call	readword_030
;  266:     IF gotword THEN enterword;
	mov		ax,WORD PTR gotword_015
	cmp		ax,1
	je		$L_109
	jmp		$L_110
$L_109:
	push	bp
	call	enterword_062
$L_110:
;  267:     END;
	jmp		$L_106
$L_108:
;  268: 
;  269:     {Then print the cross reference listing if all went well.}
;  270:     IF wordtablefull THEN BEGIN
	mov		ax,WORD PTR wordtablefull_012
	cmp		ax,1
	je		$L_111
	jmp		$L_112
$L_111:
;  271:         writeln;
	call	_write_line
;  272:     writeln('*** The word table is not large enough. ***');
	lea		ax,WORD PTR $S_113
	push	ax
	mov		ax,0
	push	ax
	mov		ax,43
	push	ax
	call	_write_string
	add		sp,6
	call	_write_line
;  273:     END
;  274:     ELSE IF numbertablefull THEN BEGIN
	jmp		$L_114
$L_112:
	mov		ax,WORD PTR numbertablefull_013
	cmp		ax,1
	je		$L_115
	jmp		$L_116
$L_115:
;  275:         writeln;
	call	_write_line
;  276:     writeln('*** The number table is not large enough. ***');
	lea		ax,WORD PTR $S_117
	push	ax
	mov		ax,0
	push	ax
	mov		ax,45
	push	ax
	call	_write_string
	add		sp,6
	call	_write_line
;  277:     END
;  278:     ELSE BEGIN
	jmp		$L_118
$L_116:
;  279:     printxref;
	push	bp
	call	printxref_098
;  280:     END;
$L_118:
$L_114:
;  281: 
;  282:     {Print final stats.}
;  283:     writeln;
	call	_write_line
;  284:     writeln((nextwordindex - 1):5,   ' word entries.');
	mov		ax,WORD PTR nextwordindex_009
	push	ax
	mov		ax,1
	pop		dx
	sub		dx,ax
	mov		ax,dx
	push	ax
	mov		ax,5
	push	ax
	call	_write_integer
	add		sp,4
	lea		ax,WORD PTR $S_119
	push	ax
	mov		ax,0
	push	ax
	mov		ax,14
	push	ax
	call	_write_string
	add		sp,6
	call	_write_line
;  285:     writeln((nextnumberindex - 1):5, ' line number entries.');
	mov		ax,WORD PTR nextnumberindex_010
	push	ax
	mov		ax,1
	pop		dx
	sub		dx,ax
	mov		ax,dx
	push	ax
	mov		ax,5
	push	ax
	call	_write_integer
	add		sp,4
	lea		ax,WORD PTR $S_120
	push	ax
	mov		ax,0
	push	ax
	mov		ax,21
	push	ax
	call	_write_string
	add		sp,6
	call	_write_line
;  286: END {xref}.
;  287: 

	pop		bp
	ret	

_pascal_main	ENDP

	.DATA

wordtable_007	DB	12000 DUP(0)
numbertable_008	DB	4004 DUP(0)
nextwordindex_009	DW	0
nextnumberindex_010	DW	0
linenumber_011	DW	0
wordtablefull_012	DW	0
numbertablefull_013	DW	0
newline_014	DW	0
gotword_015	DW	0
$S_120	DB	" line number entries."
$S_119	DB	" word entries."
$S_117	DB	"*** The number table is not large enough. ***"
$S_113	DB	"*** The word table is not large enough. ***"
$S_105	DB	"    1 : "
$S_101	DB	"---------------"
$S_100	DB	"Cross-reference"
$S_020	DB	" : "

	END
