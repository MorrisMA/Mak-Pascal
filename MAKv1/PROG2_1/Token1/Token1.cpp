////////////////////////////////////////////////////////////////////////////////
//
//  Program 2-21
//
//  Token2.cpp : Pascal Source Tokenizer
//
//  Recognizes Pascal tokens
//
//  Requires:   common  : .h;
//              error   : .h, .c;
//              scanner : .h, .c;
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

////////////////////////////////////////////////////////////////////////////////
//
//  Constant Definitions
//
////////////////////////////////////////////////////////////////////////////////

#define FORM_FEED_CHAR          '\f'        // ASCII formfeed 0x0C
#define EOF_CHAR                '\x7F'      // ASCII rubout 0x7F

#define MAX_FILE_NAME_LENGTH    32
#define MAX_SOURCE_LINE_LENGTH  256
#define MAX_PRINT_LINE_LENGTH   80
#define MAX_LINES_PER_PAGE      50
#define DATE_STRING_LENGTH      26

#define MAX_TOKEN_STRING_LENGTH MAX_SOURCE_LINE_LENGTH
#define MAX_CODE_BUFFER_SIZE    4096

#define MAX_INTEGER             32767
#define MAX_DIGIT_COUNT         20

////////////////////////////////////////////////////////////////////////////////
//
//  Type Definitions
//
////////////////////////////////////////////////////////////////////////////////

typedef enum {
    FALSE, TRUE
} BOOLEAN;

//  Character Codes

typedef enum {
    LETTER, DIGIT, SPECIAL, EOF_CODE
} CHAR_CODE;

//  Token Codes

typedef enum {
    NO_TOKEN, WORD, NUMBER, PERIOD, END_OF_FILE, ERROR
} TOKEN_CODE;

//  Strings for Token Codes

char *symbol_strings[] = {  
    "<NO TOKEN>",
    "<WORD>",
    "<NUMBER>",
    "<PERIOD>",
    "<END OF FILE>",
    "<ERROR>"
};

//  Literal Codes

typedef enum {
    INTEGER_LIT, STRING_LIT
} LITERAL_TYPE;

// Literal Structure

typedef struct {
    LITERAL_TYPE type;
    union {
        int     integer;
        char    string[MAX_SOURCE_LINE_LENGTH];
    } value;
} LITERAL;

////////////////////////////////////////////////////////////////////////////////
//
//  Global Variable Definitions
//
////////////////////////////////////////////////////////////////////////////////

char        ch;                 // Current input character
CHAR_CODE   ch_code;            // Mapped current input character
TOKEN_CODE  token;              // Current token code
LITERAL     literal;            // Value of literal
int         buffer_offset;      // Character offset into source buffer
int         level = 0;          // Current nesting level (proc/funct/block)
int         line_number = 0;    // Current line number - used for error reports

char        source_buffer[MAX_SOURCE_LINE_LENGTH];     // buf for source file
char        token_string[MAX_TOKEN_STRING_LENGTH];     // buf for token strings
char        *bufferp = source_buffer;                  // ptr to src file buf
char        *tokenp  = token_string;                   // ptr to token str buf

int         digit_count;                        // Number of digits in number
BOOLEAN     count_error;                        // Indicates digit_count error

int         page_number = 0;                    // Source file page number 
int         line_count  = MAX_LINES_PER_PAGE;   // Number of lines per page

char source_name[MAX_FILE_NAME_LENGTH];         // Name of source file
char date[DATE_STRING_LENGTH];                  // Current date and time

FILE *source_file;

//  define array and MACRO to convert ASCII character read from source file into
//      a CHAR_CODE for use in discrimating between type of characters in source
//      file.

CHAR_CODE   char_table[256];                    // Type of ASCII code read 

#define char_code(ch)   char_table[ch];         // MACRO to look up char code

////////////////////////////////////////////////////////////////////////////////
//
//  Function Declarations
//
////////////////////////////////////////////////////////////////////////////////

void    print_token(void);
void    init_scanner(char *name);
void    quit_scanner(void);
void    get_char(void);
void    skip_blanks(void);
void    get_token(void);
void    get_word(void);
void    get_number(void);
void    get_special(void);
void    open_source_file(char *name);
void    close_source_file(void);

BOOLEAN get_source_line(void);
void    print_line(char line[]);
void    init_page_header(char *name);
void    print_page_header(void);

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
            print_line("*** ERROR: Unexpected End-Of-File\n");
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
    char    line[MAX_PRINT_LINE_LENGTH];
    char    *symbol_string = symbol_strings[token];

    switch(token) {
        case NUMBER :
            sprintf(line, "     >> %-16s %d\n",
                          symbol_string, literal.value.integer);
            break;

        default :
            sprintf(line, "     >> %-16s %-s\n",
                          symbol_string, token_string);
            break;
    }

    print_line(line);
}

///////////////////////////////////////////////////////////////////////////////
//
//  Initialize Scanner
//
//  Opens the source file using the argument supplied on the command line
//  Sets the time and date that the listing is being created
//
///////////////////////////////////////////////////////////////////////////////

void init_scanner(char *name)
{
    int     ch;

    // Intialize the character code mapping table

    for(ch = 0;   ch <  256; ch++) char_table[ch] = (CHAR_CODE) SPECIAL;
    for(ch = '0'; ch <= '9'; ch++) char_table[ch] = (CHAR_CODE) DIGIT;
    for(ch = 'A'; ch <= 'Z'; ch++) char_table[ch] = (CHAR_CODE) LETTER;
    for(ch = 'a'; ch <= 'z'; ch++) char_table[ch] = (CHAR_CODE) LETTER;
    char_table[EOF_CHAR] = EOF_CODE;

    init_page_header(name);
    open_source_file(name);
}

////////////////////////////////////////////////////////////////////////////////
//
//  Quit Scanner
//
//  Terminate Scanner
//
////////////////////////////////////////////////////////////////////////////////

void quit_scanner(void)
{
    close_source_file();
}

////////////////////////////////////////////////////////////////////////////////
//
//  Character Processing Routines
//
////////////////////////////////////////////////////////////////////////////////


//  Get Character
//
//  Set ch to the next character in the source file line buffer
//      if at end of line, read another source line
//      if at end of file, set ch to EOF_CHAR and return

void get_char(void)
{
    if(*bufferp == '\0') {
        if(!get_source_line()) {
            ch = EOF_CHAR;
            return;
        }

        bufferp       = source_buffer;
        buffer_offset = 0;
    }

    ch       = *bufferp++;
    ch_code = char_code(ch);

    if((ch == '\n') || (ch == '\t')) ch = ' ';
}

//  Skip Blanks
//      Skip past any blanks at the current location in the source buffer, and
//      set ch to the next non-blank character

void skip_blanks(void)
{
    while(ch == ' ') get_char();
}

////////////////////////////////////////////////////////////////////////////////
//
//  Token Processing Routines
//
//  Note: after a token has been extracted from the source line buffer
//        ch is the first character after the token
//
////////////////////////////////////////////////////////////////////////////////

//  Get Token
//      Extract the next token from the source line buffer

void get_token(void)
{
    skip_blanks();
    tokenp = token_string;

    switch(ch_code) {
        case LETTER   : get_word();          break;
        case DIGIT    : get_number();        break;
        case EOF_CODE : token = END_OF_FILE; break;
        default       : get_special();       break;
    }
}

//  Get Word
//      Extract a word token and set token to IDENTIFIER

void get_word(void)
{
    while((ch_code == LETTER) || (ch_code == DIGIT)) {
        *tokenp++ = ch;     // store ch into token string buffer
        get_char();         // get next non-blank character
    }

    *tokenp = '\0';         // terminate token string
    token   = WORD;         // set token type
}

//  Get Number
//      Extract a number token, set literal to value, and set token to NUMBER
//

void get_number(void)
{
    int         nvalue = 0;         // value of the number
    int         digit_count = 0;    // init digit_count with max # digits/num
    BOOLEAN     count_error = FALSE;// init digit_count error indicator/flag

    do {
        *tokenp++ = ch;

        if(++digit_count <= MAX_DIGIT_COUNT) {
            nvalue = 10 * nvalue + (ch - '0');
        } else {
            count_error = TRUE;
        }

        get_char();
    } while(ch_code == DIGIT);

    if(count_error) {
        token = ERROR;
        return;
    }

    literal.type          = INTEGER_LIT;
    literal.value.integer = nvalue;

    *tokenp = '\0';
    token   = NUMBER;
}

//  Get Special
//      Extract special token. Only PERIOD is recognized by the scanner in this
//      version. All other special characters are considered ERRORS at this time

void get_special(void)
{
    *tokenp++ = ch;
    
    token = ((ch == '.') ? PERIOD : ERROR);
    
    get_char();
    *tokenp ='\0';
}

////////////////////////////////////////////////////////////////////////////////
//
//  Source File Routines
//
////////////////////////////////////////////////////////////////////////////////

//  Open Source File
//      Open the source file and fetch/read the first character

void open_source_file(char *name)
{
    if(name == NULL) {
        printf("*** ERROR: file name required\n");
        exit(-1);
    }

    if((source_file = fopen(name, "r")) == NULL) {
        printf("*** ERROR: failed to open source file\n");
        exit(-1);
    }

    bufferp = "";
    get_char();
}

//  Close Source File

void close_source_file(void)
{
    fclose(source_file);
}

////////////////////////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////////////////////////
//
//  Initialize Page Header
//
//  Initialize the fields of the page header
//
////////////////////////////////////////////////////////////////////////////////

void init_page_header(char *name)
{
    time_t  timer;

    strncpy(source_name, name, MAX_FILE_NAME_LENGTH - 1);

    time(&timer);
    strcpy(date, asctime(localtime(&timer)));   // Set time and date
}

////////////////////////////////////////////////////////////////////////////////
//
//  Print Page Header
//
//  Advances the page using a FORM_FEED_CHAR
//  Prints a page header
//      Page header consists of page number, file name, date and 2 blank lines
//      Increments page number prior to printing
//
////////////////////////////////////////////////////////////////////////////////

void print_page_header(void)
{
    putchar(FORM_FEED_CHAR);
    printf("Page %4d  %s  %s\n\n", ++page_number, source_name, date);
}