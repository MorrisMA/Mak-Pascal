	TITLE	C:\MAM\Pascal\PROG2_1\List\List.cpp
	.386P
include listing.inc
if @Version gt 510
.model FLAT
else
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT DWORD USE32 PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT DWORD USE32 PUBLIC 'BSS'
_BSS	ENDS
$$SYMBOLS	SEGMENT BYTE USE32 'DEBSYM'
$$SYMBOLS	ENDS
$$TYPES	SEGMENT BYTE USE32 'DEBTYP'
$$TYPES	ENDS
_TLS	SEGMENT DWORD USE32 PUBLIC 'TLS'
_TLS	ENDS
;	COMDAT ??_C@_01LHO@r?$AA@
CONST	SEGMENT DWORD USE32 PUBLIC 'CONST'
CONST	ENDS
;	COMDAT ??_C@_0L@MPCK@?$CF4d?5?$CFd?3?5?$CFs?$AA@
CONST	SEGMENT DWORD USE32 PUBLIC 'CONST'
CONST	ENDS
;	COMDAT ??_C@_02DILL@?$CFs?$AA@
CONST	SEGMENT DWORD USE32 PUBLIC 'CONST'
CONST	ENDS
;	COMDAT ??_C@_0BD@GOPO@Page?5?$CF4d?5?5?$CFs?5?5?$CFs?6?6?$AA@
CONST	SEGMENT DWORD USE32 PUBLIC 'CONST'
CONST	ENDS
;	COMDAT _main
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?init_lister@@YAXPAD@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?get_source_line@@YA?AW4BOOLEAN@@XZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?print_line@@YAXQAD@Z
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT ?print_page_header@@YAXXZ
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
FLAT	GROUP _DATA, CONST, _BSS
	ASSUME	CS: FLAT, DS: FLAT, SS: FLAT
endif
PUBLIC	?line_number@@3HA				; line_number
PUBLIC	?page_number@@3HA				; page_number
PUBLIC	?level@@3HA					; level
PUBLIC	?line_count@@3HA				; line_count
PUBLIC	?source_buffer@@3PADA				; source_buffer
PUBLIC	?source_name@@3PADA				; source_name
PUBLIC	?date@@3PADA					; date
PUBLIC	?source_file@@3PAU_iobuf@@A			; source_file
_BSS	SEGMENT
?line_number@@3HA DD 01H DUP (?)			; line_number
?page_number@@3HA DD 01H DUP (?)			; page_number
?level@@3HA DD	01H DUP (?)				; level
?source_buffer@@3PADA DB 0100H DUP (?)			; source_buffer
?source_name@@3PADA DB 020H DUP (?)			; source_name
?date@@3PADA DB	01aH DUP (?)				; date
	ALIGN	4

?source_file@@3PAU_iobuf@@A DD 01H DUP (?)		; source_file
_BSS	ENDS
_DATA	SEGMENT
?line_count@@3HA DD 032H				; line_count
_DATA	ENDS
PUBLIC	?get_source_line@@YA?AW4BOOLEAN@@XZ		; get_source_line
PUBLIC	?init_lister@@YAXPAD@Z				; init_lister
PUBLIC	_main
EXTRN	__chkesp:NEAR
;	COMDAT _main
_TEXT	SEGMENT
_argv$ = 12
_main	PROC NEAR					; COMDAT

; 81   : {

	push	ebp
	mov	ebp, esp
	sub	esp, 68					; 00000044H
	push	ebx
	push	esi
	push	edi
	lea	edi, DWORD PTR [ebp-68]
	mov	ecx, 17					; 00000011H
	mov	eax, -858993460				; ccccccccH
	rep stosd

; 82   :     char ch;
; 83   : 
; 84   :     init_lister(argv[1]);               // Initialize: open source file

	mov	eax, DWORD PTR _argv$[ebp]
	mov	ecx, DWORD PTR [eax+4]
	push	ecx
	call	?init_lister@@YAXPAD@Z			; init_lister
	add	esp, 4
$L941:

; 85   :     
; 86   :     while(get_source_line());           // Read all source lines and print

	call	?get_source_line@@YA?AW4BOOLEAN@@XZ	; get_source_line
	test	eax, eax
	je	SHORT $L942
	jmp	SHORT $L941
$L942:

; 87   : 
; 88   :     return(0);

	xor	eax, eax

; 89   : }

	pop	edi
	pop	esi
	pop	ebx
	add	esp, 68					; 00000044H
	cmp	ebp, esp
	call	__chkesp
	mov	esp, ebp
	pop	ebp
	ret	0
_main	ENDP
_TEXT	ENDS
PUBLIC	??_C@_01LHO@r?$AA@				; `string'
EXTRN	_fopen:NEAR
EXTRN	_strcpy:NEAR
EXTRN	_asctime:NEAR
EXTRN	_localtime:NEAR
EXTRN	_time:NEAR
;	COMDAT ??_C@_01LHO@r?$AA@
; File C:\MAM\Pascal\PROG2_1\List\List.cpp
CONST	SEGMENT
??_C@_01LHO@r?$AA@ DB 'r', 00H				; `string'
CONST	ENDS
;	COMDAT ?init_lister@@YAXPAD@Z
_TEXT	SEGMENT
_name$ = 8
_timer$ = -4
?init_lister@@YAXPAD@Z PROC NEAR			; init_lister, COMDAT

; 101  : {

	push	ebp
	mov	ebp, esp
	sub	esp, 68					; 00000044H
	push	ebx
	push	esi
	push	edi
	lea	edi, DWORD PTR [ebp-68]
	mov	ecx, 17					; 00000011H
	mov	eax, -858993460				; ccccccccH
	rep stosd

; 102  :     time_t  timer;
; 103  : 
; 104  :     strcpy(source_name, name);

	mov	eax, DWORD PTR _name$[ebp]
	push	eax
	push	OFFSET FLAT:?source_name@@3PADA		; source_name
	call	_strcpy
	add	esp, 8

; 105  :     source_file = fopen(source_name, "r");      // Open source file - unchecked

	push	OFFSET FLAT:??_C@_01LHO@r?$AA@		; `string'
	push	OFFSET FLAT:?source_name@@3PADA		; source_name
	call	_fopen
	add	esp, 8
	mov	DWORD PTR ?source_file@@3PAU_iobuf@@A, eax ; source_file

; 106  : 
; 107  :     time(&timer);

	lea	ecx, DWORD PTR _timer$[ebp]
	push	ecx
	call	_time
	add	esp, 4

; 108  :     strcpy(date, asctime(localtime(&timer)));   // Set time and date

	lea	edx, DWORD PTR _timer$[ebp]
	push	edx
	call	_localtime
	add	esp, 4
	push	eax
	call	_asctime
	add	esp, 4
	push	eax
	push	OFFSET FLAT:?date@@3PADA		; date
	call	_strcpy
	add	esp, 8

; 109  : }

	pop	edi
	pop	esi
	pop	ebx
	add	esp, 68					; 00000044H
	cmp	ebp, esp
	call	__chkesp
	mov	esp, ebp
	pop	ebp
	ret	0
?init_lister@@YAXPAD@Z ENDP				; init_lister
_TEXT	ENDS
PUBLIC	?print_line@@YAXQAD@Z				; print_line
PUBLIC	??_C@_0L@MPCK@?$CF4d?5?$CFd?3?5?$CFs?$AA@	; `string'
EXTRN	_fgets:NEAR
EXTRN	_sprintf:NEAR
;	COMDAT ??_C@_0L@MPCK@?$CF4d?5?$CFd?3?5?$CFs?$AA@
; File C:\MAM\Pascal\PROG2_1\List\List.cpp
CONST	SEGMENT
??_C@_0L@MPCK@?$CF4d?5?$CFd?3?5?$CFs?$AA@ DB '%4d %d: %s', 00H ; `string'
CONST	ENDS
;	COMDAT ?get_source_line@@YA?AW4BOOLEAN@@XZ
_TEXT	SEGMENT
_print_buffer$ = -268
?get_source_line@@YA?AW4BOOLEAN@@XZ PROC NEAR		; get_source_line, COMDAT

; 126  : {

	push	ebp
	mov	ebp, esp
	sub	esp, 332				; 0000014cH
	push	ebx
	push	esi
	push	edi
	lea	edi, DWORD PTR [ebp-332]
	mov	ecx, 83					; 00000053H
	mov	eax, -858993460				; ccccccccH
	rep stosd

; 127  :     char print_buffer[MAX_SOURCE_LINE_LENGTH + 9];
; 128  : 
; 129  :     if((fgets(source_buffer, MAX_SOURCE_LINE_LENGTH, source_file)) != NULL) {

	mov	eax, DWORD PTR ?source_file@@3PAU_iobuf@@A ; source_file
	push	eax
	push	256					; 00000100H
	push	OFFSET FLAT:?source_buffer@@3PADA	; source_buffer
	call	_fgets
	add	esp, 12					; 0000000cH
	test	eax, eax
	je	SHORT $L952

; 130  :         ++line_number;

	mov	ecx, DWORD PTR ?line_number@@3HA	; line_number
	add	ecx, 1
	mov	DWORD PTR ?line_number@@3HA, ecx	; line_number

; 131  :         sprintf(print_buffer, "%4d %d: %s", line_number, level, source_buffer);

	push	OFFSET FLAT:?source_buffer@@3PADA	; source_buffer
	mov	edx, DWORD PTR ?level@@3HA		; level
	push	edx
	mov	eax, DWORD PTR ?line_number@@3HA	; line_number
	push	eax
	push	OFFSET FLAT:??_C@_0L@MPCK@?$CF4d?5?$CFd?3?5?$CFs?$AA@ ; `string'
	lea	ecx, DWORD PTR _print_buffer$[ebp]
	push	ecx
	call	_sprintf
	add	esp, 20					; 00000014H

; 132  :         print_line(print_buffer);

	lea	edx, DWORD PTR _print_buffer$[ebp]
	push	edx
	call	?print_line@@YAXQAD@Z			; print_line
	add	esp, 4

; 133  : 
; 134  :         return(TRUE);

	mov	eax, 1
	jmp	SHORT $L954
$L952:

; 136  :         return(FALSE);

	xor	eax, eax
$L954:

; 138  : }

	pop	edi
	pop	esi
	pop	ebx
	add	esp, 332				; 0000014cH
	cmp	ebp, esp
	call	__chkesp
	mov	esp, ebp
	pop	ebp
	ret	0
?get_source_line@@YA?AW4BOOLEAN@@XZ ENDP		; get_source_line
_TEXT	ENDS
PUBLIC	?print_page_header@@YAXXZ			; print_page_header
PUBLIC	??_C@_02DILL@?$CFs?$AA@				; `string'
EXTRN	_printf:NEAR
EXTRN	_strlen:NEAR
;	COMDAT ??_C@_02DILL@?$CFs?$AA@
; File C:\MAM\Pascal\PROG2_1\List\List.cpp
CONST	SEGMENT
??_C@_02DILL@?$CFs?$AA@ DB '%s', 00H			; `string'
CONST	ENDS
;	COMDAT ?print_line@@YAXQAD@Z
_TEXT	SEGMENT
_line$ = 8
_save_ch$ = -4
_save_chp$ = -8
?print_line@@YAXQAD@Z PROC NEAR				; print_line, COMDAT

; 152  : {

	push	ebp
	mov	ebp, esp
	sub	esp, 72					; 00000048H
	push	ebx
	push	esi
	push	edi
	lea	edi, DWORD PTR [ebp-72]
	mov	ecx, 18					; 00000012H
	mov	eax, -858993460				; ccccccccH
	rep stosd

; 153  :     char save_ch;
; 154  :     char *save_chp = NULL;

	mov	DWORD PTR _save_chp$[ebp], 0

; 155  : 
; 156  :     if(++line_count > MAX_LINES_PER_PAGE) {

	mov	eax, DWORD PTR ?line_count@@3HA		; line_count
	add	eax, 1
	mov	DWORD PTR ?line_count@@3HA, eax		; line_count
	cmp	DWORD PTR ?line_count@@3HA, 50		; line_count, 00000032H
	jle	SHORT $L960

; 157  :         print_page_header(); 

	call	?print_page_header@@YAXXZ		; print_page_header

; 158  :         line_count = 1;

	mov	DWORD PTR ?line_count@@3HA, 1		; line_count
$L960:

; 160  : 
; 161  :     if(strlen(line) > MAX_PRINT_LINE_LENGTH) {

	mov	ecx, DWORD PTR _line$[ebp]
	push	ecx
	call	_strlen
	add	esp, 4
	cmp	eax, 80					; 00000050H
	jbe	SHORT $L961

; 162  :         save_chp = &line[MAX_PRINT_LINE_LENGTH];

	mov	edx, DWORD PTR _line$[ebp]
	add	edx, 80					; 00000050H
	mov	DWORD PTR _save_chp$[ebp], edx
$L961:

; 164  : 
; 165  :     if(save_chp) {

	cmp	DWORD PTR _save_chp$[ebp], 0
	je	SHORT $L962

; 166  :         save_ch  = *save_chp;   // Save ch replaced by end of string marker

	mov	eax, DWORD PTR _save_chp$[ebp]
	mov	cl, BYTE PTR [eax]
	mov	BYTE PTR _save_ch$[ebp], cl

; 167  :         save_chp = '\0';        // Insert end of string marker

	mov	DWORD PTR _save_chp$[ebp], 0
$L962:

; 169  : 
; 170  :     printf("%s", line);

	mov	edx, DWORD PTR _line$[ebp]
	push	edx
	push	OFFSET FLAT:??_C@_02DILL@?$CFs?$AA@	; `string'
	call	_printf
	add	esp, 8

; 171  : 
; 172  :     if(save_chp) {

	cmp	DWORD PTR _save_chp$[ebp], 0
	je	SHORT $L964

; 173  :         *save_chp = save_ch;    // Restore ch replaced by end of string marker

	mov	eax, DWORD PTR _save_chp$[ebp]
	mov	cl, BYTE PTR _save_ch$[ebp]
	mov	BYTE PTR [eax], cl
$L964:

; 175  : }

	pop	edi
	pop	esi
	pop	ebx
	add	esp, 72					; 00000048H
	cmp	ebp, esp
	call	__chkesp
	mov	esp, ebp
	pop	ebp
	ret	0
?print_line@@YAXQAD@Z ENDP				; print_line
_TEXT	ENDS
PUBLIC	??_C@_0BD@GOPO@Page?5?$CF4d?5?5?$CFs?5?5?$CFs?6?6?$AA@ ; `string'
EXTRN	__iob:BYTE
EXTRN	__flsbuf:NEAR
;	COMDAT ??_C@_0BD@GOPO@Page?5?$CF4d?5?5?$CFs?5?5?$CFs?6?6?$AA@
; File C:\MAM\Pascal\PROG2_1\List\List.cpp
CONST	SEGMENT
??_C@_0BD@GOPO@Page?5?$CF4d?5?5?$CFs?5?5?$CFs?6?6?$AA@ DB 'Page %4d  %s  '
	DB	'%s', 0aH, 0aH, 00H				; `string'
CONST	ENDS
;	COMDAT ?print_page_header@@YAXXZ
_TEXT	SEGMENT
?print_page_header@@YAXXZ PROC NEAR			; print_page_header, COMDAT

; 189  : {

	push	ebp
	mov	ebp, esp
	sub	esp, 68					; 00000044H
	push	ebx
	push	esi
	push	edi
	lea	edi, DWORD PTR [ebp-68]
	mov	ecx, 17					; 00000011H
	mov	eax, -858993460				; ccccccccH
	rep stosd

; 190  :     putchar(FORM_FEED_CHAR);

	mov	eax, DWORD PTR __iob+36
	sub	eax, 1
	mov	DWORD PTR __iob+36, eax
	cmp	DWORD PTR __iob+36, 0
	jl	SHORT $L991
	mov	ecx, DWORD PTR __iob+32
	mov	BYTE PTR [ecx], 12			; 0000000cH
	mov	edx, 12					; 0000000cH
	and	edx, 255				; 000000ffH
	mov	DWORD PTR -4+[ebp], edx
	mov	eax, DWORD PTR __iob+32
	add	eax, 1
	mov	DWORD PTR __iob+32, eax
	jmp	SHORT $L992
$L991:
	push	OFFSET FLAT:__iob+32
	push	12					; 0000000cH
	call	__flsbuf
	add	esp, 8
	mov	DWORD PTR -4+[ebp], eax
$L992:

; 191  :     printf("Page %4d  %s  %s\n\n", ++page_number, source_name, date);

	push	OFFSET FLAT:?date@@3PADA		; date
	push	OFFSET FLAT:?source_name@@3PADA		; source_name
	mov	ecx, DWORD PTR ?page_number@@3HA	; page_number
	add	ecx, 1
	mov	DWORD PTR ?page_number@@3HA, ecx	; page_number
	mov	edx, DWORD PTR ?page_number@@3HA	; page_number
	push	edx
	push	OFFSET FLAT:??_C@_0BD@GOPO@Page?5?$CF4d?5?5?$CFs?5?5?$CFs?6?6?$AA@ ; `string'
	call	_printf
	add	esp, 16					; 00000010H

; 192  : }

	pop	edi
	pop	esi
	pop	ebx
	add	esp, 68					; 00000044H
	cmp	ebp, esp
	call	__chkesp
	mov	esp, ebp
	pop	ebp
	ret	0
?print_page_header@@YAXXZ ENDP				; print_page_header
_TEXT	ENDS
END
