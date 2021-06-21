/****************************************************************/
/*                                                              */
/*	PC86 - Pascal Compiler for Intel 8086 processor             */
/*                                                              */
/*      Copyright (c) 1991 by Ronald Mak                        */
/*      For instructional purposes only.  No warranties.        */
/*                                                              */
/*	PC65 - Pascal Compiler for M65C02A processor core           */
/*	Copyright (c) 2015-2016 by Michael A. Morris                */
/*	Released under GPLv3 by permission Ron Mak 13-Dec-2015      */
/*                                                              */
/****************************************************************/

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
	if (argc < 3) {
		printf("Usage:\n\tPC65 <source filename> [<output filename>]\n");
		printf("Press <Enter> to continue.");
		getchar();
		return -1;
	} else {
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
}
