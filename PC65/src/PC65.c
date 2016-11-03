/*
 ============================================================================
 Name        : PC65.c
 Author      : Michael A. Morris
 Version     :
 Copyright   : Copyright 2016 - GPLv3
 Description : Hello World in C, Ansi-style
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>

#include "code.h"
#include "common.h"
#include "parser.h"
#include "pc65err.h"
#include "scanner.h"
#include "symtab.h"

//----------------------------------------------------------------------------//
//  Globals                                                                   //
//----------------------------------------------------------------------------//

FILE *code_file;    //  ASCII file for the emitted assembly code

//----------------------------------------------------------------------------//
//  Function Prototypes                                                       //
//----------------------------------------------------------------------------//

extern void init_scanner(char *);
extern void get_token(void);

extern void program(void);


//--------------------------------------------------------------//
//  main                Initialize the scanner and call         //
//                      routine program.                        //
//--------------------------------------------------------------//

int main(int argc, char *argv[])
{
    //
    //  Open the code file.  If no code file name was given,
    //  use the standard output file.
    //

    code_file = (argc == 3) ? fopen(argv[2], "w") : stdout;

    //
    //  Initialize the scanner.
    //

    init_scanner(argv[1]);

    //
    //  Process a program.
    //

    get_token();
    program();

    return 0;
}

//int main(void) {
//	puts("!!!Hello World!!!"); /* prints !!!Hello World!!! */
//	return EXIT_SUCCESS;
//}
