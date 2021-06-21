////////////////////////////////////////////////////////////////////////////////
//
//  Program 3-1 : Pascal Cross-Reference Utility
//
//  List all identifiers within a source file alphabetically, and annotate each
//  with the line numbers of the lines that reference the indentifiers.
//
//  File : xref.cpp
//
//  Requires :  common  : .h;
//              scanner : .h, .cpp;
//              symtab  : .h, .cpp;
//
//              stdlib  : .h;
//              stdio   : .h;
//
//  Usage :     xref sourcefile
//
//              sourcefile  :   name of file to cross-reference
//
////////////////////////////////////////////////////////////////////////////////

#include    "stdafx.h"

#include    <stdlib.h>
#include    <stdio.h>
#include    <string.h>

#include    "common.h"
#include    "error.h"
#include    "scanner.h"
#include    "symtab.h"

////////////////////////////////////////////////////////////////////////////////
//
//  Globals
//
////////////////////////////////////////////////////////////////////////////////

#define MAX_LINENUMS_PER_LINE   10

////////////////////////////////////////////////////////////////////////////////
//
//  Type Definitions
//
////////////////////////////////////////////////////////////////////////////////

typedef struct line_item {
    struct line_item    *next;
    int                 line_number;
} LINENUM_ITEM, *LINENUM_ITEM_PTR;

typedef struct {
    LINENUM_ITEM_PTR    first_linenum, last_linenum;
} LINENUM_HEADER, *LINENUM_HEADER_PTR;

////////////////////////////////////////////////////////////////////////////////
//
//  External Variable References
//
////////////////////////////////////////////////////////////////////////////////

extern int              line_number;
extern TOKEN_CODE       token;
extern char             word_string[];

extern SYMTAB_NODE_PTR  symtab_root;

////////////////////////////////////////////////////////////////////////////////
//
//  Function Prototypes
//
////////////////////////////////////////////////////////////////////////////////

void init_scanner(char *name);
void quit_scanner(void);
void get_token(void);

void record_line_number(SYMTAB_NODE_PTR np, int number);
void print_xref(SYMTAB_NODE_PTR np);

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//
////////////////////////////////////////////////////////////////////////////////

void main(int argc, char* argv[])
{
    SYMTAB_NODE_PTR     np;
    LINENUM_HEADER_PTR  hp;

    init_scanner(argv[1]);

    //  Process tokens until EOF or PERIOD

    do {
        get_token();
        if(token == END_OF_FILE) break;

        //  Enter/Insert each identifier into the symbol table if it is not in
        //      the symbol table, and record the current line number in the
        //      symbol table.

        if(token == IDENTIFIER) {
            np = search_symtab(word_string, symtab_root);
            if(np == NULL) {
                np = enter_symtab(word_string, &symtab_root);
                hp = alloc_struct(LINENUM_HEADER);
                hp->first_linenum = hp->last_linenum = NULL;
                np->info = (char *) hp;
            }
            record_line_number(np, line_number);
        }
    } while(token != PERIOD);

    //  Print out the cross-reference listing

    printf("\n\nCross-Reference");
    printf(  "\n---------------\n");
    print_xref(symtab_root);

    quit_scanner();

    getchar();
}

//  Record Line Number into the Symbol Table entry

void record_line_number(SYMTAB_NODE_PTR np, int number)
{
    LINENUM_ITEM_PTR    ip;
    LINENUM_HEADER_PTR  hp;

    //  Create a new line number item

    ip              = alloc_struct(LINENUM_ITEM);
    ip->line_number = number;
    ip->next        = NULL;

    //  Link to the end of the list for this IDENTIFIER's symbol table entry

    hp = (LINENUM_HEADER_PTR) np->info;
    if(hp->first_linenum == NULL) {
        hp->first_linenum = hp->last_linenum = ip;
    } else {
        (hp->last_linenum)->next = ip;
        hp->last_linenum = ip;
    }
}

//  Print Cross-Reference

void print_xref(SYMTAB_NODE_PTR np)
{
    int                 n;
    LINENUM_ITEM_PTR    ip;
    LINENUM_HEADER_PTR  hp;

    if(np == NULL) return;

    //  Print the left subtree;

    print_xref(np->left);

    //  then print the root of the subtree with at most MAX_LINENUMS_PER_LINE

    printf("\n%-16s  ", np->name);
    n  = ((strlen(np->name) > 16) ? 0 : MAX_LINENUMS_PER_LINE);
    hp = (LINENUM_HEADER_PTR) np->info;
    for(ip = hp->first_linenum; ip != NULL; ip = ip->next) {
        if(n == 0) {
            printf("\n%-16s  ", " ");
            n = MAX_LINENUMS_PER_LINE;
        }
        printf(" %4d", ip->line_number);
        --n;
    }
    printf("\n");

    //  Finally, print the right subtree

    print_xref(np->right);
}
