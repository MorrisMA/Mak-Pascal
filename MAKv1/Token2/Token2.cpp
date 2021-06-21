////////////////////////////////////////////////////////////////////////////////
//
//  Program 2-2
//
//  Token2.cpp : Pascal Source Tokenizer
//
//  Recognizes Pascal tokens
//
//  Requires:   common  : .h;
//              error   : .h, .cpp;
//              scanner : .h, .cpp;
//
//  Usage:      token2 sourcefile
//
//              sourcefile  :   path and name of source file to tokenize
//
////////////////////////////////////////////////////////////////////////////////

#include "stdafx.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#include "common.h"
#include "scanner.h"
#include "error.h"

////////////////////////////////////////////////////////////////////////////////
//
//  Global Variable Declarations
//
////////////////////////////////////////////////////////////////////////////////

//  Strings for Token Codes

char *symbol_strings[] = {  
    "<NO TOKEN>", "<IDENTIFIER>", "<NUMBER>", "<STRING>",
    " ", "*", "(", ")", "-", "+", "=", "[", "]", ":", ";",
    "<", ">", ",", ".", "/", ":=", "<=", ">=", "<>", "..",
    "<END OF FILE>", "<ERROR>",
    "AND", "ARRAY", "BEGIN", "CASE", "CONST", "DIV", "DO", "DOWNTO",
    "ELSE", "END", "FILE", "FOR", "FUNCTION", "GOTO", "IF", "IN",
    "LABEL", "MOD", "NIL", "NOT", "OF", "OR", "PACKED", "PROCEDURE",
    "PROGRAM", "RECORD", "REPEAT", "SET", "THEN", "TO", "TYPE",
    "UNTIL", "VAR", "WHILE", "WITH"
};

////////////////////////////////////////////////////////////////////////////////
//
//  External Variable References
//
////////////////////////////////////////////////////////////////////////////////

extern TOKEN_CODE   token;
extern char         token_string[];
extern LITERAL      literal;

////////////////////////////////////////////////////////////////////////////////
//
//  External Function Prototypes
//
////////////////////////////////////////////////////////////////////////////////

void    init_scanner(char *name);
void    quit_scanner(void);
void    get_token(void);
void    print_line(char line[]);

void    error(ERROR_CODE code);

////////////////////////////////////////////////////////////////////////////////
//
//  Local Function Prototypes
//
////////////////////////////////////////////////////////////////////////////////

void    print_token(void);

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//
////////////////////////////////////////////////////////////////////////////////

int main(int argc, char* argv[])
{
    init_scanner(argv[1]);              // Initialize: open source file
    
    do {
        get_token();
        if(token == END_OF_FILE) {
            error(UNEXPECTED_END_OF_FILE);
            break;
        }

        print_token();
    } while (token != PERIOD);

    quit_scanner();

    getchar();

    return(0);
}

///////////////////////////////////////////////////////////////////////////////
//
//  Print Token
//
//  Print a line describing the current token
//
///////////////////////////////////////////////////////////////////////////////

void print_token(void)
{
    char    line[MAX_SOURCE_LINE_LENGTH + 32];
    char    *symbol_string = symbol_strings[token];

    switch(token) {
        case NUMBER :
            if(literal.type == INTEGER_LIT)
                sprintf(line, "     >> %-16s %d (integer)\n",
                              symbol_string, literal.value.real);
            else
                sprintf(line, "     >> %-16s %g (real)\n",
                              symbol_string, literal.value.real);
            break;

        case STRING :
            sprintf(line, "     >> %-16s %-s\n",
                          symbol_string, literal.value.string);
            break;

        default :
            sprintf(line, "     >> %-16s %-s\n",
                          symbol_string, token_string);
            break;
    }

    print_line(line);
}

