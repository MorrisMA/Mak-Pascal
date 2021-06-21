////////////////////////////////////////////////////////////////////////////////
//
//  Error Routines (Header)
//
//  File :  error.h
//
//  Provides the common error enumerations and MAX_SYNTAX_ERRORS
//
////////////////////////////////////////////////////////////////////////////////

#ifndef error_h
#define error_h

////////////////////////////////////////////////////////////////////////////////
//
//  Constant Definitions
//
////////////////////////////////////////////////////////////////////////////////

#define MAX_SYNTAX_ERRORS   25

////////////////////////////////////////////////////////////////////////////////
//
//  Type Definitions
//
////////////////////////////////////////////////////////////////////////////////

typedef enum {
    NO_ERROR,
    SYNTAX_ERROR,
    TOO_MANY_SYNTAX_ERRORS,
    FAILED_SOURCE_FILE_OPEN,
    UNEXPECTED_END_OF_FILE,
    INVALID_NUMBER,
    INVALID_FRACTION,
    INVALID_EXPONENT,
    TOO_MANY_DIGITS,
    REAL_OUT_OF_RANGE,
    INTEGER_OUT_OF_RANGE,
    MISSING_RPAREN,
    INVALID_EXPRESSION,
    INVALID_ASSIGNMENT,
    MISSING_IDENTIFIER,
    MISSING_COLONEQUAL,
    UNDEFINED_IDENTIFIER,
    STACK_OVERFLOW,
    INVALID_STATEMENT,
    UNEXPECTED_TOKEN,
    MISSING_SEMICOLON,
    MISSING_DO,
    MISSING_UNTIL,
    MISSING_THEN,
    INVALID_FOR_CONTROL,
    MISSING_OF,
    INVALID_CONSTANT,
    MISSING_COLON,
    MISSING_END,
    MISSING_TO_OR_DOWNTO,
    REDEFINED_IDENTIFIER,
    MISSING_EQUAL,
    INVALID_TYPE,
    NOT_A_TYPE_IDENTIFIER,
    INVALID_SUBRANGE_TYPE,
    NOT_A_CONSTANT_IDENTIFIER,
    MISSING_DOTDOT,
    INCOMPATIBLE_TYPES,
    INVALID_TARGET,
    INVALID_IDENTIFIER_USAGE,
    MIN_GT_MAX,
    MISSING_LBRACKET,
    MISSING_RBRACKET,
    INVALID_INDEX_TYPE,
    MISSING_BEGIN,
    MISSING_PERIOD,
    TOO_MANY_SUBSCRIPTS,
    INVALID_FIELD,
    NESTING_TOO_DEEP,
    ALREADY_FORWARDED,
    WRONG_NUMBER_OF_PARMS,
    INVALID_VAR_PARM,
    NOT_A_RECORD_VARIABLE,
    CODE_SEGMENT_OVERFLOW,
    UNIMPLEMENTED_FEATURE
} ERROR_CODE;

#endif