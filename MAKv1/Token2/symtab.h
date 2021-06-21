////////////////////////////////////////////////////////////////////////////////
//
//  Symbol Table (Header)
//
//  File:   symtab.h
//
//  Module: symbol table
//
////////////////////////////////////////////////////////////////////////////////

#ifndef symtab_h
#define symtab_h

#include "common.h"

//  Type Definition : Value Union

typedef union {
    int     integer;
    float   real;
    char    character;
    char    *string;
} VALUE;

//  Type Definition : Definition Key Enumeration
//      Enumerates the various types of definitions to be represented

typedef enum {
    UNDEFINED,
    CONST_DEFN, TYPE_DEFN, VAR_DEFN, FIELD_DEFN,
    VALPARM_DEFN, VARPARAM_DEFN,
    PROG_DEFN, PROC_DEFN, FUNC_DEFN
} DEFN_KEY;

//  Type Definition : Pascal Routine Key Emumeration
//      Enumerates the various states of Pascal functions and procedures, and
//      the names of the standard Pascal functions, i.e. the Pascal library.

typedef enum {
    DECLARED, FORWARD,
    READ, READLN, WRITE, WRITELN,
    ABS, ARCTAN, CHR, COS, EOFF, EOLN, EXP, LN, ODD, ORD,
    PRED, ROUND, SIN, SQR, SQRT, SUCC, TRUNC
} ROUTINE_KEY;

//  Type Definition : Definition Structure

typedef struct {
    DEFN_KEY key;
    union {
        struct {
            VALUE value;
        } constant;

        struct {
            ROUTINE_KEY         key;
            int                 parm_count;
            int                 total_parm_size;
            int                 total_local_size;
            struct symtab_node  *parms;
            struct symtab_node  *locals;
            struct symtab_node  *local_symtab;
            char                *code_segment;
        } routine;

        struct {
            int                 offset;
            struct symtab_node  *record_idp;
        } data;
    } info;
} DEFN_STRUCT;

//  Type Definition : Symbol Table Node Structure

typedef struct symtab_node {
    struct symtab_node  *left;          // pointer to left subtree
    struct symtab_node  *right;         // pointer to right subtree
    struct symtab_node  *next;          // pointer for chaining nodes
    char                *name;          // pointer to name string for node
    char                *info;          // pointer to generic info for node
    DEFN_STRUCT         defn;           // definition structure
    int                 level;          // nesting level of definition
    int                 label_index;    // index for code label
} SYMTAB_NODE, *SYMTAB_NODE_PTR;

//  Symbol Table Function Prototypes

SYMTAB_NODE_PTR search_symtab(char *name, SYMTAB_NODE_PTR np);
SYMTAB_NODE_PTR enter_symtab(char *name, SYMTAB_NODE_PTR *npp);

#endif




