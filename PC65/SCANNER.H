/****************************************************************/
/*                                                              */
/*      S C A N N E R   (Header)                                */
/*                                                              */
/*      FILE:       scanner.h                                   */
/*                                                              */
/*      MODULE:     scanner                                     */
/*                                                              */
/****************************************************************/
/*                                                              */
/*	PC86 - Pascal Compiler for Intel 8086 processor             */
/*                                                              */
/*      Copyright (c) 1991 by Ronald Mak                        */
/*      For instructional purposes only.  No warranties.        */
/*                                                              */
/*	PC65 - Pascal Compiler for M65C02A processor core           */
/*	Copyright (c) 2015-2016 by Michael A. Morris                */
/*	Released under GPLv3 by permission Ron Mak 13-Dec-2015      */
/*                                                              */
/****************************************************************/

#ifndef scanner_h
#define scanner_h

#include "common.h"

/*--------------------------------------------------------------*/
/*  Token codes                         */
/*--------------------------------------------------------------*/

typedef enum {
    NO_TOKEN, IDENTIFIER, NUMBER, STRING,
    UPARROW, STAR, LPAREN, RPAREN, MINUS, PLUS, EQUAL,
    LBRACKET, RBRACKET, COLON, SEMICOLON, LT, GT, COMMA, PERIOD,
    SLASH, COLONEQUAL, LE, GE, NE, DOTDOT, END_OF_FILE, ERROR,
    AND, ARRAY, BEGIN, CASE, CONST, DIV, DO, DOWNTO, ELSE, END,
    FFILE, FOR, FUNCTION, GOTO, IF, IN, LABEL, MOD, NIL, NOT,
    OF, OR, PACKED, PROCEDURE, PROGRAM, RECORD, REPEAT, SET,
    THEN, TO, TYPE, UNTIL, VAR, WHILE, WITH,
} TOKEN_CODE;

/*--------------------------------------------------------------*/
/*  Literal structure                                           */
/*--------------------------------------------------------------*/

typedef enum {
    INTEGER_LIT, REAL_LIT, STRING_LIT,
} LITERAL_TYPE;

typedef struct {
    LITERAL_TYPE type;
    union {
        int   integer;
        float real;
        char  string[MAX_SOURCE_LINE_LENGTH];
    } value;
} LITERAL;

/*--------------------------------------------------------------*/
/*  Functions                                                   */
/*--------------------------------------------------------------*/

BOOLEAN token_in();

#endif
