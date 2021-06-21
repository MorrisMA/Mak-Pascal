////////////////////////////////////////////////////////////////////////////////
//
//  Error Routines
//
//  error.cpp : Error Routines and Constants
//
//  Outputs error messages corresponding to the error code enumerations
//
//  Requires:   common  : .h;
//              error   : .h;
//   
//              stdlib  : .h;
//              stdio   : .h;
//
////////////////////////////////////////////////////////////////////////////////

#include <stdlib.h>
#include <stdio.h>

#include "error.h"
#include "common.h"

////////////////////////////////////////////////////////////////////////////////
//
//  External Variable References
//
////////////////////////////////////////////////////////////////////////////////

extern char     *tokenp;
extern BOOLEAN  print_flag;
extern char     source_buffer[];
extern char     *bufferp;

////////////////////////////////////////////////////////////////////////////////
//
//  Error Messages
//
////////////////////////////////////////////////////////////////////////////////

char *error_messages[] = {  
    "No error",
    "Syntax Error",
    "Too many syntax errors",
    "Failed to open source file",
    "Unexpected end of file",
    "Invalid number",
    "Invalid fraction",
    "Invalid fraction",
    "Too many digits",
    "Real literal out of range",
    "Integare literal out of range",
    "Missing right paranthesis",
    "Invalid expression",
    "Invalid assignment statement",
    "Missing identifier",
    "Missing := ",
    "Undefined identifier",
    "Stack overflow",
    "Invalid statement",
    "Unexpected token",
    "Missing ; ",
    "Missing DO",
    "Missing UNTIL",
    "Missing THEN",
    "Invalid FOR control variable",
    "Missing OF",
    "Invalid constant",
    "Missing constant",
    "Missing : ",
    "Missing END",
    "Missing TO or DOWNTO",
    "Redefined identifier",
    "Missing = ",
    "Invalid type",
    "Not a type identifier",
    "Invalid subrange type",
    "Not a constant identifier",
    "Missing .. ",
    "Incompatible types",
    "Invalid assignment target",
    "Invalid identifier usage",
    "Incompatible assignment",
    "Min limit greater than Max limit",
    "Missing [ ",
    "Missing ] ",
    "Invalid index type",
    "Missing BEGIN",
    "Missing period (.)",
    "Too many subscripts",
    "Invalid field",
    "Nesting too deep",
    "Missing PROGRAM",
    "Already specified in FORWARD",
    "Wrong number of actual parameters",
    "Invalid VAR parameter",
    "Not a RECORD variable",
    "Missing variable",
    "Code segment overflow",
    "Unimplemented feature",
};

////////////////////////////////////////////////////////////////////////////////
//
//  Global Variable Declarations
//
////////////////////////////////////////////////////////////////////////////////

int error_count = 0;        // Counter for number of syntax errors

////////////////////////////////////////////////////////////////////////////////
//
//  External Function Prototypes
//
////////////////////////////////////////////////////////////////////////////////

void print_line(char line[]);

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//
////////////////////////////////////////////////////////////////////////////////

void error(ERROR_CODE code)
{
    extern int buffer_offset;

    char    message_buffer[MAX_PRINT_LINE_LENGTH];
    char    *message = error_messages[code];
    int     offset   = buffer_offset - 2;

    //  Print an arrow/caret under the offending character in the source buffer

    if(print_flag) offset += 8;
    sprintf(message_buffer, "%*s^\n", offset, " ");
    
    if(print_flag) {
        print_line(message_buffer);
    } else {
        printf(message_buffer);
    }

    //  Print error message

    sprintf(message_buffer, "*** ERROR: %s\n", message);
    if(print_flag) {
        print_line(message_buffer);
    } else {
        printf(message_buffer);
    }

    *tokenp = '\0';
    ++error_count;

    if(error_count > MAX_SYNTAX_ERRORS) {
        sprintf(message_buffer, "Too many syntax errors. Aborted.\n");
        if(print_flag) {
            print_line(message_buffer);
        } else {
            printf(message_buffer);
        }

        exit(-TOO_MANY_SYNTAX_ERRORS);
    }
}
