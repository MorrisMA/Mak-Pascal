///////////////////////////////////////////////////////////////////////////////
//
//  Program 1-1
//
//  List.cpp : Simple program listing utility
//
//  Prints the contents of a source file with line numbers and a page header
//
//  Usage:  list sourcefile
//
//          sourcefile  :   path and name of source file to list/print
//
///////////////////////////////////////////////////////////////////////////////

#include "stdafx.h"

#include <stdio.h>
#include <string.h>
#include <time.h>

///////////////////////////////////////////////////////////////////////////////
//
//  Constant Definitions
//
///////////////////////////////////////////////////////////////////////////////

#define FORM_FEED_CHAR          '\f'

#define MAX_FILE_NAME_LENGTH    32
#define MAX_SOURCE_LINE_LENGTH  256
#define MAX_PRINT_LINE_LENGTH   80
#define MAX_LINES_PER_PAGE      50
#define DATE_STRING_LENGTH      26

///////////////////////////////////////////////////////////////////////////////
//
//  Type Definitions
//
///////////////////////////////////////////////////////////////////////////////

typedef enum {
            FALSE, TRUE
        } BOOLEAN;

///////////////////////////////////////////////////////////////////////////////
//
//  Global Variable Definitions
//
///////////////////////////////////////////////////////////////////////////////

int line_number = 0;
int page_number = 0;
int level       = 0;
int line_count  = MAX_LINES_PER_PAGE;

char source_buffer[MAX_SOURCE_LINE_LENGTH];

char source_name[MAX_FILE_NAME_LENGTH];
char date[DATE_STRING_LENGTH];

FILE *source_file;

///////////////////////////////////////////////////////////////////////////////
//
//  Function Declarations
//
///////////////////////////////////////////////////////////////////////////////

BOOLEAN get_source_line();
void    init_lister(char *name);
void    print_line(char line[]);
void    print_page_header(void);

///////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//
///////////////////////////////////////////////////////////////////////////////

int main(int argc, char* argv[])
{
    char ch;

    init_lister(argv[1]);               // Initialize: open source file
    
    while(get_source_line());           // Read all source lines and print

    return(0);
}

///////////////////////////////////////////////////////////////////////////////
//
//  Initialize Lister
//
//  Opens the source file using the argument supplied on the command line
//  Sets the time and date that the listing is being created
//
///////////////////////////////////////////////////////////////////////////////

void init_lister(char *name)
{
    time_t  timer;

    strcpy(source_name, name);
    source_file = fopen(source_name, "r");      // Open source file - unchecked

    time(&timer);
    strcpy(date, asctime(localtime(&timer)));   // Set time and date
}

///////////////////////////////////////////////////////////////////////////////
//
//  Read Line from Source File
//
//  Allocates a temporary buffer to hold one 80 char source line
//      Adds additional 9 locations to hold the line number and nesting level
//  Reads the source file
//      Prints the line with the line number and level prepended
//          Uses sprintf() to hold the formatted output
//          Increments the line number
//  Returns FALSE when no more lines read from the source file
//
///////////////////////////////////////////////////////////////////////////////

BOOLEAN get_source_line(void)
{
    char print_buffer[MAX_SOURCE_LINE_LENGTH + 9];

    if((fgets(source_buffer, MAX_SOURCE_LINE_LENGTH, source_file)) != NULL) {
        ++line_number;
        sprintf(print_buffer, "%4d %d: %s", line_number, level, source_buffer);
        print_line(print_buffer);

        return(TRUE);
    } else {
        return(FALSE);
    }
}

///////////////////////////////////////////////////////////////////////////////
//
//  Print Line
//
//  Prints the print line provided by get_source_line()
//  Prints a single line header if the line count exceed MAX_LINES_PER_PAGE
//  Truncates the printed line at 80 characters
//      Truncation saves and restores the character at the end of the line
//
///////////////////////////////////////////////////////////////////////////////

void print_line(char line[])
{
    char save_ch;
    char *save_chp = NULL;

    if(++line_count > MAX_LINES_PER_PAGE) {
        print_page_header(); 
        line_count = 1;
    }

    if(strlen(line) > MAX_PRINT_LINE_LENGTH) {
        save_chp = &line[MAX_PRINT_LINE_LENGTH];
    }

    if(save_chp) {
        save_ch  = *save_chp;   // Save ch replaced by end of string marker
        save_chp = '\0';        // Insert end of string marker
    }

    printf("%s", line);

    if(save_chp) {
        *save_chp = save_ch;    // Restore ch replaced by end of string marker
    }
}

///////////////////////////////////////////////////////////////////////////////
//
//  Print Page Header
//
//  Advances the page using a FORM_FEED_CHAR
//  Prints a page header
//      Page header consists of page number, file name, date and 2 blank lines
//      Increments page number prior to printing
//
///////////////////////////////////////////////////////////////////////////////

void print_page_header(void)
{
    putchar(FORM_FEED_CHAR);
    printf("Page %4d  %s  %s\n\n", ++page_number, source_name, date);
}
