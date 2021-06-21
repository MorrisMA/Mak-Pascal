////////////////////////////////////////////////////////////////////////////////
//
//  Symbol Table Search and Insert Functions
//
//  symtab.c    : Functions to support symbol table searches and insertions
//
//  Recognizes Pascal tokens
//
//  Requires:   common  : .h;
//              error   : .h;
//              symtab  : .h;
//
//              stdlib  : .h;
//              stdio   : .h;
//              string  : .h;
//
////////////////////////////////////////////////////////////////////////////////

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "common.h"
#include "error.h"
#include "symtab.h"

////////////////////////////////////////////////////////////////////////////////
//
//  Globals
//
////////////////////////////////////////////////////////////////////////////////

SYMTAB_NODE_PTR symtab_root = NULL;     // Decl/init symbol table root pointer

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//
////////////////////////////////////////////////////////////////////////////////

//  Search Symbol Table
//      search the given symbol table for a name
//          if (the name is found) return a pointer to the node else return NULL

SYMTAB_NODE_PTR search_symtab(char *name, SYMTAB_NODE_PTR np)
{
    int cmp;

    //  Loop to check each node.
    //      if (node matches given name)
    //          return pointer
    //      else
    //          continue search down the left and right subtrees.

    while(np != NULL) {
        cmp = strcmp(name, np->name);
        if(cmp == 0) {
            return(np);
        } else {
            np = ((cmp < 0) ? np->left : np->right);    // follow subtree
        }
    }

    return(NULL);   // name not found
}

//  Insert name into Symbol Table
//      return pointer to the new entry/node

SYMTAB_NODE_PTR enter_symtab(char *name, SYMTAB_NODE_PTR *npp)
{
    int             cmp;
    SYMTAB_NODE_PTR new_nodep;
    SYMTAB_NODE_PTR np;

    //  Create the new node for name

    new_nodep       = alloc_struct(SYMTAB_NODE);
    new_nodep->name = alloc_bytes(strlen(name) + 1);

    strcpy(new_nodep->name, name);

    new_nodep->left     = new_nodep->right = new_nodep->next = NULL;
    new_nodep->info     = NULL;
    new_nodep->defn.key = UNDEFINED;

    //  Loop to search for the insertion point

    while((np = *npp) != NULL) {
        cmp = strcmp(name, np->name);
        npp = ((cmp < 0) ? (&np->left) : (&np->right));
    }

    *npp = new_nodep;   // Insert new node

    //  Exite and return pointer to new node

    return(new_nodep);
}
