////////////////////////////////////////////////////////////////////////////////
//
//  Program 2-3
//
//  Compact.cpp : Pascal Source Compactor
//
//  Recognizes Pascal tokens
//
//  Requires:   common  : .h;
//              scanner : .h, .cpp;
//
//  Usage:      compact sourcefile
//
//              sourcefile  :   path and name of source file to compact
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
//  Constants/Defines
//
////////////////////////////////////////////////////////////////////////////////

#define MAX_OUTPUT_RECORD_LENGTH    80

////////////////////////////////////////////////////////////////////////////////
//
//  Type Definitions
//
////////////////////////////////////////////////////////////////////////////////

typedef enum {
    DELIMITER, NONDELIMITER
} TOKEN_CLASS;

////////////////////////////////////////////////////////////////////////////////
//
//  External Variable Declarations
//
////////////////////////////////////////////////////////////////////////////////

extern TOKEN_CODE   token;
extern char         token_string[];
extern BOOLEAN      print_flag;

////////////////////////////////////////////////////////////////////////////////
//
//  Global Variable Declarations
//
////////////////////////////////////////////////////////////////////////////////

int     record_length;                  // Length of output record
char    *recp;                          // Pointer into output record

char    output_record[MAX_OUTPUT_RECORD_LENGTH];

////////////////////////////////////////////////////////////////////////////////
//
//  Function Prototypes
//
////////////////////////////////////////////////////////////////////////////////

void init_scanner(char *name);
void quit_scanner(void);
void get_token(void);

TOKEN_CLASS token_class(void);
void append_blank(void);
void append_token(void);
void flush_output_record(void);

////////////////////////////////////////////////////////////////////////////////
//
//  Implementations
//
////////////////////////////////////////////////////////////////////////////////

void main(int argc, char* argv[])
{
    TOKEN_CLASS tkn_class;              // current token class
    TOKEN_CLASS prev_tkn_class;         // previous token class

    print_flag = FALSE;     // Turn off printing of source lines while reading
    init_scanner(argv[1]);  // Initialize the scanner: open source and read line

    //  Initialize the Compactor utility

    prev_tkn_class = DELIMITER;
    recp           = output_record;
    *recp          = '\0';
    record_length  = 0;

    //  Repeatedly process tokens using scanner until PERIOD or EOF found

    do {
        get_token();
        if(token == END_OF_FILE) {
            break;
        }

        tkn_class = token_class();

        //  Append blank to the output record is two consecutive NONDELIMITERs
        //      are found. After appending the blank, append the current token.

        if(    (prev_tkn_class == NONDELIMITER)
            && (     tkn_class == NONDELIMITER)) {
            append_blank();
        }
        append_token();

        prev_tkn_class = tkn_class;
    } while (token != PERIOD);

    //  Flush the last record if it is partially filled

    if(record_length > 0) {
        flush_output_record();
    }

    quit_scanner();
    
    getchar();
}

//  Return the token class of the current token

TOKEN_CLASS token_class(void)
{
    //  Non-delimiters: identifiers, numbers, and reserved words
    //  Delimiters:     strings and special symbols

    switch(token) {
        case IDENTIFIER : 
        case NUMBER     : return(NONDELIMITER);

    default : return((token < AND) ? DELIMITER : NONDELIMITER);
    }
}

//  Append a blank in the output record to separate NONDELIMITER tokens

void append_blank(void)
{
    if(++record_length >= (MAX_OUTPUT_RECORD_LENGTH - 1)) {
        flush_output_record();
    } else {
        strcat(output_record, " ");
    }
}

//  Append current token to the output record
//      if token length greater than available space, flush output record and
//      append current token to the beginning of the next output record

void append_token(void)
{
    int token_length;

    token_length = strlen(token_string);

    if((record_length + token_length) >= (MAX_OUTPUT_RECORD_LENGTH - 1)) {
        flush_output_record();
    }

    strcat(output_record, token_string);
    record_length += token_length;
}

//  flush output record

void flush_output_record(void)
{
    printf("%s\n", output_record);
    
    recp          = output_record;
    *recp         = '\0';
    record_length = 0;
}