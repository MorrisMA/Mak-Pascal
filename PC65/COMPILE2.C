//**************************************************************//
//                                                              //
//      Program 14-1:  Pascal Compiler II                       //
//                                                              //
//      Compile Pascal programs.                                //
//                                                              //
//      FILE:       compile2.c                                  //
//                                                              //
//      REQUIRES:   Modules parser, symbol table, scanner,      //
//                          code, error                         //
//                                                              //
//      USAGE:      compile2 sourcefile objectfile              //
//                                                              //
//          sourcefile      [input] source file containing the  //
//                                  the statements to compile   //
//                                                              //
//          objectfile      [output] object file to contain the //
//                                   generated assembly code    //
//                                                              //
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

#include "stdafx.h"

#include <stdio.h>

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

void main(int argc, char *argv[])
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
}
