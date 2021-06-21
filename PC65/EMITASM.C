//***************************************************************/
//                                                              */
//      E M I T   A S S E M B L Y   S T A T E M E N T S         */
//                                                              */
//      Routines for generating and emitting                    */
//      language statements.                                    */
//                                                              */
//      FILE:       emitasm.c                                   */
//                                                              */
//      MODULE:     code                                        */
//                                                              */
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

#include "symtab.h"
#include "code.h"

//////////////////////////////////////////////////////////////////
//  Globals                                                     //
//////////////////////////////////////////////////////////////////

int label_index = 0;

extern FILE *code_file;

    //**********************************************//
    //                                              //
    //      Write parts of assembly statements      //
    //                                              //
    //**********************************************//

//////////////////////////////////////////////////////////////////
//  label               Write a generic label constructed from  //
//                      the prefix and the label index.         //
//                                                              //
//                      Example:        $L_007                  //
//////////////////////////////////////////////////////////////////

void label(char *prefix, int index)
{
    fprintf(code_file, "%s_%03d\n", prefix, index);
}

