;    1: PROGRAM eratosthenes(output);
     .STACK  1024                   ; Set stack size

     .CODE                          ; place in CODE segment

STATIC_LINK         .EQ    +4       ;--- STATIC_LINK         EQU    <WORD PTR [bp+4]>
RETURN_VALUE        .EQ    -4       ;--- RETURN_VALUE        EQU    <WORD PTR [bp-4]>
HIGH_RETURN_VALUE   .EQ    -2       ;--- HIGH_RETURN_VALUE   EQU    <WORD PTR [bp-2]>

;    2:
;    3: CONST
;    4:     max = 1000;
;    5:
;    6: VAR
;    7:     sieve : ARRAY [1..max] OF BOOLEAN;
;    8:     i, j, limit, prime, factor : INTEGER;
;    9:
;   10: BEGIN

_pc65_main    .PROC

     phx.w                          ;---    push    bp
     tsx.w                          ;---    mov     bp,sp
;   11:     limit := max DIV 2;
     lda.w #1000                    ;---    mov     ax,1000
     pha.w                          ;---    push    ax
     lda #2                         ;---    mov     ax,2
     pha.w                          ;---    mov     cx,ax
                                    ;---    pop     ax
                                    ;---    cwd
     jsr _idiv                      ;---    idiv    cx
     adj #4
     sta.w limit_005                ;---    mov     WORD PTR limit_005,ax
;   12:     sieve[1] := FALSE;
     psh.w #sieve_002               ;---    lea     ax,WORD PTR sieve_002
                                    ;---    push    ax
     lda #1                         ;---    mov     ax,1
     dec.w a                        ;---    sub     ax,1
                                    ;---    mov     dx,2
                                    ;---    imul    dx
     asl.w a
                                    ;---    pop     dx
     clc                            ;---    add     dx,ax
     adc.w 0,S
     sta.w 0,S                      ;---    push    dx
     lda #0                         ;---    mov     ax,0
                                    ;---    pop     bx
     sta.w (0,S)                    ;---    mov     WORD PTR [bx],ax
     adj #2
;   13:
;   14:     FOR i := 2 TO max DO
     lda #2                         ;---    mov     ax,2
     sta.w i_003                    ;---    mov     WORD PTR i_003,ax
L_008
     lda.w #1000                    ;---    mov     ax,1000
     cmp.w i_003                    ;---    cmp     WORD PTR i_003,ax
     bge L_009                      ;---    jle     L_009
     jmp L_010                      ;---    jmp     L_010
L_009
;   15:         sieve[i] := TRUE;
     psh.w #sieve_002               ;---    lea     ax,WORD PTR sieve_002
                                    ;---    push    ax
     lda.w i_003                    ;---    mov     ax,WORD PTR i_003
     dec.w a                        ;---    sub     ax,1
                                    ;---    mov     dx,2
                                    ;---    imul    dx
     asl.w a
                                    ;---    pop     dx
     clc                            ;---    add     dx,ax
     adc.w 0,S
     sta.w 0,S                      ;---    push    dx
     lda #1                         ;---    mov     ax,1
                                    ;---    pop     bx
     sta.w (0,S)                    ;---    mov     WORD PTR [bx],ax
     adj #2
     inc.w i_003                    ;---    inc     WORD PTR i_003
     jmp L_008                      ;---    jmp     L_008
L_010
     dec.w i_003                    ;---    dec     WORD PTR i_003
