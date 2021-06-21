////////////////////////////////////////////////////////////////////////////////
//
//  Scanner
//
//  scanner.c   : Scanner for Pascal Tokens
//
//  Recognizes Pascal tokens
//
//  Requires:   scanner : .h;
//              error   : .h;
//              common  : .h;
//
//              stdlib  : .h;
//              stdio   : .h;
//              string  : .h;
//              time    : .h;
//              math    : .h;
//
////////////////////////////////////////////////////////////////////////////////

#include "stdafx.h"

#include <stdlib.h>

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include "common.h"
#include "error.h"
#include "scanner.h"

////////////////////////////////////////////////////////////////////////////////
//
//  Constant Definitions
//
////////////////////////////////////////////////////////////////////////////////

#define EOF_CHAR                    '\177'      // ASCII rubout 0x7F
#define TAB_SIZE                    8

#define MAX_INTEGER                 32767
#define MAX_DIGIT_COUNT             20
#define MAX_EXPONENT                37

#define MIN_RESERVED_WORD_LENGTH    2
#define MAX_RESERVED_WORD_LENGTH    9

////////////////////////////////////////////////////////////////////////////////
//
//  Type Definitions
//
////////////////////////////////////////////////////////////////////////////////

//  Character Codes

typedef enum {
    LETTER, DIGIT, QUOTE, SPECIAL, EOF_CODE
} CHAR_CODE;

//  Reserved Word Tables

typedef struct {
    char        *string;
    TOKEN_CODE  token_code;
} RW_STRUCT;

RW_STRUCT rw_2[] = {
    {"do", DO}, {"if", IF}, {"in", IN}, {"of", OF}, {"or", OR},
    {"to", TO}, {NULL, ((TOKEN_CODE) 0)}
};

RW_STRUCT rw_3[] = {
    {"and", AND}, {"div", DIV}, {"end", END}, {"for", FOR},
    {"mod", MOD}, {"nil", NIL}, {"not", NOT}, {"set", SET},
    {"var", VAR}, {NULL, ((TOKEN_CODE) 0)}
};

RW_STRUCT rw_4[] = {
    {"case", CASE}, {"else", ELSE}, {"file", FFILE},
    {"goto", GOTO}, {"then", THEN}, {"type", TYPE},
    {"with", WITH}, {NULL, ((TOKEN_CODE) 0)}
};

RW_STRUCT rw_5[] = {
    {"array", ARRAY}, {"begin", BEGIN}, {"const", CONST},
    {"label", LABEL}, {"until", UNTIL}, {"while", WHILE},
    {NULL, ((TOKEN_CODE) 0)}
};

RW_STRUCT rw_6[] = {
    {"downto", DOWNTO}, {"packed", PACKED}, {"record", RECORD},
    {"repeat", REPEAT}, {NULL, ((TOKEN_CODE) 0)}
};

RW_STRUCT rw_7[] = {
    {"program", PROGRAM}, {NULL, ((TOKEN_CODE) 0)}
};

RW_STRUCT rw_8[] = {
    {"function", FUNCTION}, {NULL, ((TOKEN_CODE) 0)}
};

RW_STRUCT rw_9[] = {
    {"procedure", PROCEDURE}, {NULL, ((TOKEN_CODE) 0)}
};

RW_STRUCT *rw_table[] = {
    NULL, NULL, rw_2, rw_3, rw_4, rw_5, rw_6, rw_7, rw_8, rw_9
};

////////////////////////////////////////////////////////////////////////////////
//
//  File Level Globals
//
////////////////////////////////////////////////////////////////////////////////

char        ch;                 // Current input character
CHAR_CODE   ch_code;            // Mapped current input character
TOKEN_CODE  token;              // Current token code
LITERAL     literal;            // Value of literal
int         buffer_offset;      // Character offset into source buffer
int         level = 0;          // Current nesting level (proc/funct/block)
int         line_number = 0;    // Current line number - used for error reports
BOOLEAN     print_flag = TRUE;  // When TRUE, print source lines

char        source_buffer[MAX_SOURCE_LINE_LENGTH];  // buf for source file
char        token_string[MAX_TOKEN_STRING_LENGTH];  // buf for token strings
char        word_string[MAX_TOKEN_STRING_LENGTH];   // tolower() word buffer    
char        *bufferp = source_buffer;               // ptr to src file buf
char        *tokenp  = token_string;                // ptr to token str buf

int         digit_count;                        // Number of digits in number
BOOLEAN     count_error;                        // Indicates digit_count error

int         page_number = 0;                    // Source file page number 
int         line_count  = MAX_LINES_PER_PAGE;   // Number of lines per page

char        source_name[MAX_FILE_NAME_LENGTH];  // Name of source file
char        date[DATE_STRING_LENGTH];           // Current date and time

FILE        *source_file;

//  define array and MACRO to convert ASCII character read from source file into
//      a CHAR_CODE for use in discrimating between type of characters in source
//      file.

CHAR_CODE   char_table[256];                    // Type of ASCII code read 

#define char_code(ch)   char_table[ch];         // MACRO to look up char code

////////////////////////////////////////////////////////////////////////////////
//
//  Local Function Prototypes
//
////////////////////////////////////////////////////////////////////////////////

void    init_scanner(char *name);
void    quit_scanner(void);

void    get_char(void);
void    skip_comment(void);
void    skip_blanks(void);

void    get_token(void);
void    get_word(void);
void    get_number(void);
void    get_string(void);
void    get_special(void);
void    downshift_word(void);
void    accumulate_value(float *valuep, ERROR_CODE code);
BOOLEAN is_reserved_word(void);

void    open_source_file(char *name);
void    close_source_file(void);
BOOLEAN get_source_line(void);

void    print_line(char line[]);
void    init_page_header(char *name);
void    print_page_header(void);

void    error(ERROR_CODE code);

////////////////////////////////////////////////////////////////////////////////
//
//  Function Implementations
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//  Initialize Scanner
//
//  Opens the source file using the argument supplied on the command line
//  Sets the time and date that the listing is being created
//
////////////////////////////////////////////////////////////////////////////////

void init_scanner(char *name)
{
    int     ch;

    // Intialize the character code mapping table

    for(ch = 0;   ch <  256; ch++) char_table[ch] = (CHAR_CODE) SPECIAL;
    for(ch = '0'; ch <= '9'; ch++) char_table[ch] = (CHAR_CODE) DIGIT;
    for(ch = 'A'; ch <= 'Z'; ch++) char_table[ch] = (CHAR_CODE) LETTER;
    for(ch = 'a'; ch <= 'z'; ch++) char_table[ch] = (CHAR_CODE) LETTER;
    char_table['\'']     = QUOTE;
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

    ch = *bufferp++; ch_code = char_code(ch);

    switch(ch) {
        case '\t' : buffer_offset += TAB_SIZE - buffer_offset % TAB_SIZE;
                    ch = ' '; ch_code = char_code(ch);
                    break;
        
        case '\n' : ++buffer_offset;
                    ch = ' '; ch_code = char_code(ch);
                    break;
        
        case '{'  : ++buffer_offset;
                    skip_comment();
                    ch = ' '; ch_code = char_code(ch);
                    break;

        default   : ++buffer_offset;
                    break;
    }
}

//  Skip Comment
//      Skip all characters until a matching '}' is found

void skip_comment(void)
{
    do {
        get_char();
    } while((ch != '}') && (ch != EOF_CHAR));
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
        case QUOTE    : get_string();        break;
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
    downshift_word();       // convert token string to lower case.

    if(!is_reserved_word()) {
        token = IDENTIFIER;
    }
}

//  Get Number
//      Extract a number token, set literal to value, and set token to NUMBER
//

void get_number(void)
{
    int     whole_count    = 0;     // # digits in integer/whole part
    int     decimal_offset = 0;     // # digits to shift right (fractional part)
    char    exponent_sign  = '+';   // default exponent sign
    int     exponent       = 0;     // exponent value
    float   nvalue         = 0;     // value of the number
    float   evalue         = 0;     // value of exponent
    BOOLEAN saw_dotdot     = FALSE; // detected .. in the input stream

    digit_count = 0;                // init digit_count with max # digits/num
    count_error = FALSE;            // init digit_count error indicator/flag
    token       = NO_TOKEN;         // token for numeric literals

    literal.type = INTEGER_LIT;     // default type for numeric literals

    accumulate_value(&nvalue, INVALID_NUMBER);
    if(token == ERROR) return;
    whole_count = digit_count;

    if(ch == '.') {
        get_char();

        if(ch == '.') {    // backup pointer because token ".."
            saw_dotdot = TRUE;
            --bufferp;
        } else {
            literal.type = REAL_LIT;    // Numeric literal real type
            *tokenp++ = '.';            // Place decimal point in the token buf
            
            // process the fractional part

            accumulate_value(&nvalue, INVALID_FRACTION);
            if(token == ERROR) return;
            decimal_offset = whole_count - digit_count;
        }
    }

    //  Extract exponent part, if any
    //      There cannot be an exponent if the '..' token was previously found

    if(!saw_dotdot && ((ch == 'E') || (ch == 'e'))) {
        literal.type = REAL_LIT;
        *tokenp++ = ch;
        get_char();

        //  Fetch the exponent's sign, if any

        if((ch == '+') || (ch == '-')) {
            *tokenp++ = exponent_sign = ch;
            get_char();
        }

        //  Extract the exponent value
        //      Accumulate in evalue

        accumulate_value(&evalue, INVALID_EXPONENT);
        if(token == ERROR) return;
        if(exponent_sign == '-') evalue = -evalue;
    }

    //  Check total number of digits processed
    //      If number of digits exceeds MAX_DIGIT_COUNT, literal is invalid

    if(count_error) {
        error(TOO_MANY_DIGITS);
        token = ERROR;
        return;
    }

    // Adjust the number's value using the decimal_offset and the exponent

    exponent = (int) evalue + decimal_offset;
    if(    ((exponent + whole_count) < -((float) MAX_EXPONENT))
        || ((exponent + whole_count) >  ((float) MAX_EXPONENT))) {
        error(REAL_OUT_OF_RANGE);
        token = ERROR;
        return;
    }

    if(exponent != 0) {
        nvalue *= (float) pow(10, exponent);
    }

    //  Set the numeric literal's value

    if(literal.type == INTEGER_LIT) {
        if(    (nvalue < -((float) MAX_INTEGER + 1.0))
            || (nvalue >   (float) MAX_INTEGER       )) {
            error(INTEGER_OUT_OF_RANGE);
            token = ERROR;
            return;
        }
        literal.value.integer = (int) nvalue;
    } else {
        literal.value.real = nvalue;
    }

    *tokenp = '\0';
    token   = NUMBER;
}

//  Get String
//      Extract string token. Set token to STRING
//      Note:   The quotes are stored as part of token_string,
//              but not in literal.value.string

void get_string(void)
{
    char *sp = literal.value.string;

    *tokenp++ = '\'';
    get_char();

    //  Extract the string

    while(ch != EOF_CHAR) {
        //  Two consecutive single quotes represent a single quote within the
        //      string
        if(ch == '\'') {
            *tokenp++ = ch;
            get_char();
            if(ch != '\'') break;
        }

        *tokenp++ = ch;
        *sp++     = ch;
        get_char();
    }

    *tokenp      = '\0';
    *sp          = '\0';
    token        = STRING;
    literal.type = STRING_LIT;
}

//  Get Special
//      Extract special token. Only PERIOD is recognized by the scanner in this
//      version. All other special characters are considered ERRORS at this time

void get_special(void)
{
    *tokenp++ = ch;
    
    switch(ch) {
        case '^' : token = CARET;       get_char(); break;
        case '*' : token = STAR;        get_char(); break;
        case '(' : token = LPAREN;      get_char(); break;
        case ')' : token = RPAREN;      get_char(); break;
        case '-' : token = MINUS;       get_char(); break;
        case '+' : token = PLUS;        get_char(); break;
        case '=' : token = EQUAL;       get_char(); break;
        case '[' : token = LBRACKET;    get_char(); break;
        case ']' : token = RBRACKET;    get_char(); break;
        case ';' : token = SEMICOLON;   get_char(); break;
        case ',' : token = COMMA;       get_char(); break;
        case '/' : token = SLASH;       get_char(); break;
        
        case ':' : get_char();      // Check for ':' or ':='
                   if(ch == '=') {
                       *tokenp++ = ch;
                       token     = COLONEQUAL;
                       get_char();
                   } else {
                       token = COLON;
                   }
                   break;
        
        case '<' : get_char();      // Check for '<' or '<='
                   if(ch == '=') {
                       *tokenp++ = ch;
                       token     = LE;
                       get_char();
                   } else {
                       token = LT;
                   }
                   break;

        case '>' : get_char();      // Check for '>' or '>='
                   if(ch == '>') {
                       *tokenp++ = ch;
                       token     = GE;
                       get_char();
                   } else {
                       token = GT;
                   }
                   break;
        
        case '.' : get_char();      // Check for '.' or '..'
                   if(ch == '.') {
                       *tokenp++ = ch;
                       token     = DOTDOT;
                       get_char();
                   } else {
                       token = PERIOD;
                   }
                   break;
        
        default : token = ERROR;
                  get_char();
                  break;
    }

    *tokenp ='\0';
}

//  Downshift Word
//      Converts uppercase letters to lowercase for processing by the tokenizer

void downshift_word(void)
{
    int     offset = 'a' - 'A';     // value to convert uppercase to lower case
    char    *wp    = word_string;
    char    *tp    = token_string;

    //  Copy word from token string into word string

    do {
        *wp++ = (((*tp >= 'A') && (*tp <= 'Z')) ? *tp + offset : *tp);
        ++tp;
    } while(*tp != '\0');

    *wp = '\0';
}

//  Accumulate Value
//      Compute the value of numeric literal using a floating point accumulator
//          Flag as an error if the first value is not a DIGIT
//          Accumulate value only for a digit_count <= MAX_DIGIT_COUNT
//              else stop accumulation, flag error, issue error message using
//              supplied error code, and return

void accumulate_value(float *valuep, ERROR_CODE error_code)
{
    float   value = *valuep;

    //  Flag as an error an attempt to convert a non-DIGIT to a value

    if(ch_code != DIGIT) {
        error(error_code);
        token = ERROR;
        return;
    }

    //  Accumulate value while digit_count <= MAX_DIGIT_COUNT

    do {
        *tokenp++ = ch;

        if(++digit_count <= MAX_DIGIT_COUNT) {
            value = 10 * value + (ch - '0');
        } else {
            count_error = TRUE;
        }

        get_char();
    } while(ch_code == DIGIT);

    *valuep = value;
}

//  Is Reserved Word
//      Checks the word_string against the reserved word list.
//          The reserved lists are sorted into separate lists of words ranging
//          from 2 characters to 9 characters. An array of pointers holds the
//          pointers to arrays of reserved words.

BOOLEAN is_reserved_word(void)
{
    int         word_length = strlen(word_string);  // Compute len current word
    RW_STRUCT   *rwp;

    //  Check if word_length has the correct range of lengths:
    //      MIN_RESERVED_WORD_LENGTH (2), MAX_RESERVED_WORD_LENGTH (9)

    if(    (word_length >= MIN_RESERVED_WORD_LENGTH)
        && (word_length <= MAX_RESERVED_WORD_LENGTH)) {
        
        // Yes, initialize rwp with pointer to the proper reserved word arrays

        for(rwp = rw_table[word_length]; rwp->string != NULL; ++rwp) {
            if(strcmp(word_string, rwp->string) == 0) {
                token = rwp->token_code;
                return(TRUE);
            }
        }
    }
    return(FALSE);
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
    if(    (name == NULL)
        || ((source_file = fopen(name, "r")) == NULL)) {
       error(FAILED_SOURCE_FILE_OPEN);
       exit(-FAILED_SOURCE_FILE_OPEN);
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
////////////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////////////
//
//  Print Line
//
//  Prints the print line provided by get_source_line()
//  Prints a single line header if the line count exceed MAX_LINES_PER_PAGE
//  Truncates the printed line at 80 characters
//      Truncation saves and restores the character at the end of the line
//
////////////////////////////////////////////////////////////////////////////////

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
