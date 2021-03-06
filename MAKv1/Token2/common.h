////////////////////////////////////////////////////////////////////////////////
//
//  Common Routines
//
//  File :  common.h
//
//  Provides the common #define constants, enums, and macros used
//
////////////////////////////////////////////////////////////////////////////////

#ifndef common_h
#define common_h

////////////////////////////////////////////////////////////////////////////////
//
//  Constant Definitions
//
////////////////////////////////////////////////////////////////////////////////

#define FORM_FEED_CHAR          '\f'        // ASCII formfeed 0x0C

#define MAX_FILE_NAME_LENGTH    32
#define MAX_SOURCE_LINE_LENGTH  256
#define MAX_PRINT_LINE_LENGTH   80
#define MAX_LINES_PER_PAGE      50
#define DATE_STRING_LENGTH      26

#define MAX_TOKEN_STRING_LENGTH MAX_SOURCE_LINE_LENGTH
#define MAX_CODE_BUFFER_SIZE    4096
#define MAX_NESTING_LEVEL       16

////////////////////////////////////////////////////////////////////////////////
//
//  Type Definitions
//
////////////////////////////////////////////////////////////////////////////////

typedef enum {
    FALSE, TRUE
} BOOLEAN;

////////////////////////////////////////////////////////////////////////////////
//
//  Common Macros
//
////////////////////////////////////////////////////////////////////////////////

#define alloc_struct(type)          ((type *) malloc(sizeof(type)))
#define alloc_array(type, count)    ((type *) malloc(count * sizeof(type)))
#define alloc_bytes(length)         ((char *) malloc(length))

#endif