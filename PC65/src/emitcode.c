//**************************************************************//
//                                                              //
//      E M I T   C O D E   S E Q U E N C E S                   //
//                                                              //
//      Routines for emitting standard                          //
//      assembly code sequences.                                //
//                                                              //
//      FILE:       emitcode.c                                  //
//                                                              //
//      MODULE:     code                                        //
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

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "code.h"
#include "symtab.h"

//////////////////////////////////////////////////////////////////
//  Externals                                                   //
//////////////////////////////////////////////////////////////////

extern TYPE_STRUCT_PTR  integer_typep;
extern TYPE_STRUCT_PTR  real_typep;
//extern TYPE_STRUCT_PTR  boolean_typep;
extern TYPE_STRUCT_PTR  char_typep;

extern int level;

extern FILE     *code_file;

//////////////////////////////////////////////////////////////////
//  Globals                                                     //
//////////////////////////////////////////////////////////////////

SYMTAB_NODE_PTR  float_literal_list  = NULL;
SYMTAB_NODE_PTR  string_literal_list = NULL;

//////////////////////////////////////////////////////////////////
//  Function Prototypes                                         //
//////////////////////////////////////////////////////////////////

void emit_text_equate(SYMTAB_NODE_PTR);

		//**************************************//
		//                                      //
		//      Emit prologues and epilogues    //
		//                                      //
		//**************************************//

//////////////////////////////////////////////////////////////////
//  emit_program_prologue       Emit the program prologue.      //
//////////////////////////////////////////////////////////////////

void emit_program_prologue()

{
	int stk_size = 1024;

	fprintf(code_file, "\t.stk %d\n", stk_size);
    fprintf(code_file, "\t.cod %d\n", PGM_BASE);
    //
    //  Equates for stack frame components.
    //
    fprintf(code_file, "%s .equ %+d\n", STATIC_LINK, STATIC_LINK_OFF);
    fprintf(code_file, "%s .equ %+d\n", RETURN_VALUE, RETURN_VALUE_OFF);
    fprintf(code_file, "%s .equ %+d\n", HIGH_RETURN_VALUE, HIGH_RTN_VALUE_OFF);
    //
    //	Initialize stack and jump to main
    //
    fprintf(code_file, "_start\n");
    fprintf(code_file, "\ttsx.w\t\t; Preserve original stack pointer\n");
    fprintf(code_file, "\tlds.w #%d\t; Initialize program stack pointer\n", TOP_RAM);
    fprintf(code_file, "\tjmp _pc65_main\n");
}

//////////////////////////////////////////////////////////////////
//  emit_program_epilogue       Emit the program epilogue,      //
//                              which includes the data         //
//                              segment.                        //
//////////////////////////////////////////////////////////////////

void emit_program_epilogue(SYMTAB_NODE_PTR prog_idp)
{
    SYMTAB_NODE_PTR np;
    int             i, length;

    fprintf(code_file, "\n");
    fprintf(code_file, "\t.dat\n");
    fprintf(code_file, "\n");

    //
    //  Emit declarations for the program's string literals.
    //

    for (np = string_literal_list; np != NULL; np = np->next) {
	    fprintf(code_file, "%s_%03d .str \"", STRING_LABEL_PREFIX, np->label_index);

		length = strlen(np->name) - 2;
		for (i = 1; i <= length; ++i) {
			fputc(np->name[i], code_file);
		}
	    fprintf(code_file, "\"\n");
    }

    //
    //  Emit declarations for the program's floating point literals.
    //

    for (np = float_literal_list; np != NULL; np = np->next)
	    fprintf(code_file, "%s_%03d .flt %e\n",
                           FLOAT_LABEL_PREFIX,
			               np->label_index,
			               np->defn.info.constant.value.real);
    //
    //  Emit declarations for the program's global variables.
    //

    fprintf(code_file, "_bss_start\n");
    for (np = prog_idp->defn.info.routine.locals; np != NULL; np = np->next) {
	    fprintf(code_file, "%s_%03d ", np->name, np->label_index);
	    if (np->typep == char_typep)
	        fprintf(code_file, ".byt 1\n");
	    else if (np->typep == real_typep)
	        fprintf(code_file, ".flt 1\n");
	    else if (np->typep->form == ARRAY_FORM)
	        fprintf(code_file, ".byt %d\n", np->typep->size);
	    else if (np->typep->form == RECORD_FORM)
	        fprintf(code_file, ".byt %d\n", np->typep->size);
	    else
	        fprintf(code_file, ".wrd 1\n");
    }
    fprintf(code_file, "_bss_end\n");

    fprintf(code_file, "\n");
    fprintf(code_file, "\t.end\n");
}

//////////////////////////////////////////////////////////////////
//  emit_main_prologue      Emit the prologue for the main      //
//                          routine _pascal_main.               //
//////////////////////////////////////////////////////////////////

void emit_main_prologue()
{
    fprintf(code_file, "_pc65_main\t.sub\n");
    fprintf(code_file, "\tphx.w\n");
    fprintf(code_file, "\ttsx.w\n");
}

//////////////////////////////////////////////////////////////////
//  emit_main_epilogue      Emit the epilogue for the main      //
//                          routine _pascal_main.               //
//////////////////////////////////////////////////////////////////

void emit_main_epilogue()
{
    fprintf(code_file, "\tplx.w\n");
    fprintf(code_file, "\trts\n");
    fprintf(code_file, "\t.end _pc65_main\n");
}

//////////////////////////////////////////////////////////////////
//  emit_routine_prologue       Emit the prologue for a proce-  //
//                              dure or a function.             //
//////////////////////////////////////////////////////////////////

void emit_routine_prologue(SYMTAB_NODE_PTR rtn_idp)
{
    fprintf(code_file, "%s_%03d\t.sub\n", rtn_idp->name, rtn_idp->label_index);

    // dynamic link //
    
    fprintf(code_file, "\tphx.w\n");

    // new stack frame base //

    fprintf(code_file, "\ttsx.w\n");

    //
    //  Allocate stack space for a function's return value.
    //

    if (rtn_idp->defn.key == FUNC_DEFN) {
        fprintf(code_file, "\tadj #%d\n", -4);
    }

    //
    //  Allocate stack space for the local variables.
    //

    if (rtn_idp->defn.info.routine.total_local_size > 0) {
        fprintf(code_file, "\tadj #%d\n", -rtn_idp->defn.info.routine.total_local_size);
    }
}

//////////////////////////////////////////////////////////////////
//  emit_routine_epilogue       Emit the epilogue for a proce-  //
//                              dure or a function.             //
//////////////////////////////////////////////////////////////////

void emit_routine_epilogue(SYMTAB_NODE_PTR rtn_idp)
{
    //
    //  Load a function's return value into the ax or dx:ax registers.
    //

    if (rtn_idp->defn.key == FUNC_DEFN) {
        if (rtn_idp->typep == real_typep) {
            fprintf(code_file, "\tlda.w %s,X\t;emit_routine_epilogue\n", HIGH_RETURN_VALUE);
	        fprintf(code_file, "\tswp a\n");
        }
        fprintf(code_file, "\tlda.w %s,X\n", RETURN_VALUE);
    }

    // cut back to caller's stack //
    
    fprintf(code_file, "\ttxs.w\n");

    // restore caller's stack frame //

    fprintf(code_file, "\tplx.w\n");

    // return and cut back stack //

    fprintf(code_file, "\trts\n");

    fprintf(code_file, "\t.end %s_%03d\n", rtn_idp->name, rtn_idp->label_index);
}

		//******************************//
		//                              //
		//      Emit equates and data   //
		//                              //
		//******************************//

//////////////////////////////////////////////////////////////////
//  emit_declarations   Emit the parameter and local variable   //
//                      declarations for a procedure or a       //
//                      function.                               //
//////////////////////////////////////////////////////////////////

void emit_declarations(SYMTAB_NODE_PTR rtn_idp)
{
    SYMTAB_NODE_PTR parm_idp = rtn_idp->defn.info.routine.parms;
    SYMTAB_NODE_PTR var_idp  = rtn_idp->defn.info.routine.locals;

    //
    //  Parameters.
    //

    while (parm_idp != NULL) {
	    emit_text_equate(parm_idp);
	    parm_idp = parm_idp->next;
    }

    //
    //  Local variables.
    //

    while (var_idp != NULL) {
	    emit_text_equate(var_idp);
	    var_idp = var_idp->next;
    }
}

//////////////////////////////////////////////////////////////////
//  emit_numeric_equate     Emit a numeric equate for a field   //
//                          id and its offset.                  //
//                                                              //
//                          Example:   field_007 EQU 3          //
//////////////////////////////////////////////////////////////////

void emit_numeric_equate(SYMTAB_NODE_PTR idp)
{
    fprintf(code_file, "%s_%03d\t.equ %+d\n",
	  	               idp->name,
                       idp->label_index,
	  	               idp->defn.info.data.offset);
}

//////////////////////////////////////////////////////////////////
//  emit_text_equate        Emit a text equate for a para-      //
//                          meter or a local variable id and    //
//                          its stack frame offset.             //
//                                                              //
//                          Examples:  parm_007   EQU <bp+6>    //
//                                     var_008    EQU <bp-10>   //
//                                     dword_010  EQU <bp-14>   //
//////////////////////////////////////////////////////////////////

void emit_text_equate(SYMTAB_NODE_PTR idp)
{
    char *name       = idp->name;
    int  label_index = idp->label_index;
    int  offset      = idp->defn.info.data.offset;

    if (idp->typep == char_typep) {
        fprintf(code_file, "%s_%03d .equ %+d\n",
		                   name,
                           label_index,
                           offset);
    } else if (idp->typep == real_typep) {
	    fprintf(code_file, "%s_%03d .equ %+d\n",
		                   name,
                           label_index,
                           offset);
    } else {
	    fprintf(code_file, "%s_%03d .equ %+d\n",
		                   name,
                           label_index,
                           offset);
    }
}

		//******************************//
		//                              //
		//      Emit loads and pushes   //
		//                              //
		//******************************//

//////////////////////////////////////////////////////////////////
//  emit_load_value     Emit code to load a scalar value        //
//                      into AX or DX:AX.                       //
//////////////////////////////////////////////////////////////////

void emit_load_value(SYMTAB_NODE_PTR var_idp, TYPE_STRUCT_PTR var_tp)
{
    int     var_level    = var_idp->level;
    BOOLEAN varparm_flag = var_idp->defn.key == VARPARM_DEFN;

    if (varparm_flag) {
	    //
	    //  VAR formal parameter.
	    //  AX or DX:AX = value the address points to
	    //
	    if (var_tp == char_typep) {
            fprintf(code_file, "\tlda (%s_%03d,X)\n", var_idp->name, var_idp->label_index);
        } else if (var_tp == real_typep) {
            //fprintf(code_file, "\tldy #2\n");
            //fprintf(code_file, "\tlda.w (%s_%03d,X),Y\t; ***** Check Addressing Mode\n", var_idp->name, var_idp->label_index);
            //fprintf(code_file, "\tswp a\n");
            //fprintf(code_file, "\tlda.w (%s_%03d,X)\n", var_idp->name, var_idp->label_index);
            fprintf(code_file, "\ttxa.w\n");
            fprintf(code_file, "\tclc\n");
            fprintf(code_file, "\tadc.w #%s_%03d\n", var_idp->name, var_idp->label_index);
            fprintf(code_file, "\ttai\n");
            fprintf(code_file, "\tlda.w 0,I++\n");
            fprintf(code_file, "\ttai\n");
            fprintf(code_file, "\tlda.w 0,I++\n");
            fprintf(code_file, "\tswp a\n");
            fprintf(code_file, "\tlda.w 0,I++\n");
            fprintf(code_file, "\tswp a\n");
        } else {
            fprintf(code_file, "\tlda.w (%s_%03d,X)\n", var_idp->name, var_idp->label_index);
        }
    } else if (var_level == 1) {
	    //
	    //  Global variable:
	    //  AX or DX:AX = value
	    //
	    if (var_tp == char_typep) {
            fprintf(code_file, "\tlda %s_%03d\n", var_idp->name, var_idp->label_index);
        } else if (var_tp == real_typep) {
            fprintf(code_file, "\tlda.w %s_%03d+2\t;emit_load_value\n", var_idp->name, var_idp->label_index);
            fprintf(code_file, "\tswp a\n");
            fprintf(code_file, "\tlda.w %s_%03d\n", var_idp->name, var_idp->label_index);
        } else {
            fprintf(code_file, "\tlda.w %s_%03d\n", var_idp->name, var_idp->label_index);
        }
    } else if (var_level == level) {
	    //
	    //  local parameter or variable:
	    //  AX or DX:AX = value
	    //
	    if (var_tp == char_typep) {
            fprintf(code_file, "\tlda %s_%03d,X\n", var_idp->name, var_idp->label_index);
        } else if (var_tp == real_typep) {
            fprintf(code_file, "\tlda.w %s_%03d+2,X\t;emit_load_value\n", var_idp->name, var_idp->label_index);
            fprintf(code_file, "\tswp a\n");
            fprintf(code_file, "\tlda.w %s_%03d,X\n", var_idp->name, var_idp->label_index);
        } else {
            fprintf(code_file, "\tlda.w %s_%03d,X\n", var_idp->name, var_idp->label_index);
        }
    } else {  // var_level < level //  
	    //
	    //  Nonlocal parameter or variable.
	    //  First locate the appropriate stack frame, then:
	    //  AX or DX:AX = value
	    //
	    int lev = var_level;

        fprintf(code_file, "\tswp x\n");
	    do {
            fprintf(code_file, "\tlda.xw %s,X\n", STATIC_LINK);
	    } while (++lev < level);

	    if (var_tp == char_typep) {
            fprintf(code_file, "\tlda %s_%03d,X\n", var_idp->name, var_idp->label_index);
        } else if (var_tp == real_typep) {
            fprintf(code_file, "\tlda.w %s_%03d+2,X\t;emit_load_value\n", var_idp->name, var_idp->label_index);
            fprintf(code_file, "\tswp a\n");
            fprintf(code_file, "\tlda.w %s_%03d,X\n", var_idp->name, var_idp->label_index);
        } else {
            fprintf(code_file, "\tlda.w %s_%03d,X\n", var_idp->name, var_idp->label_index);
        }
        fprintf(code_file, "\tswp x\n");
    }
}

//////////////////////////////////////////////////////////////////
//  emit_push_operand   Emit code to push a scalar operand      //
//                      value onto the stack.                   //
//////////////////////////////////////////////////////////////////

void emit_push_operand(TYPE_STRUCT_PTR tp)
{
    if ((tp->form == ARRAY_FORM) || (tp->form == RECORD_FORM))
        return;

    if (tp == real_typep) {
        fprintf(code_file, "\tswp a\n");
        fprintf(code_file, "\tpha.w\n");
        fprintf(code_file, "\tswp a\n");
        fprintf(code_file, "\tpha.w\n");
    } else {
        fprintf(code_file, "\tpha.w\n");
    }
}

//////////////////////////////////////////////////////////////////
//  emit_push_address   Emit code to push an address onto the   //
//                      stack.                                  //
//////////////////////////////////////////////////////////////////

void emit_push_address(SYMTAB_NODE_PTR var_idp)
{
    int     var_level    = var_idp->level;
    BOOLEAN varparm_flag = var_idp->defn.key == VARPARM_DEFN;

    if ((var_level == level) || (var_level == 1)) {
        // var_level VAR Param   addressing mode    Comment
        //  level       y           BP-relative     VAR parameters ARE pointers
        //  level       n           BP-relative     LEA loads BP+offset
        //    1         n           absolute        LEA loads absolute

        if (varparm_flag) { 
            fprintf(code_file, "\tlda.w %s_%03d,X\n", var_idp->name, var_idp->label_index);
            fprintf(code_file, "\tpha.w\n");
        } else { 
            if (var_level == 1) {
                fprintf(code_file, "\tpsh.w #%s_%03d\n", var_idp->name, var_idp->label_index);
            } else {
            	//
            	// Calculate address of local variable as an offset from BP
            	//
                fprintf(code_file, "\ttxa.w\n");
                fprintf(code_file, "\tclc\n");
                fprintf(code_file, "\tadc.w #%s_%03d\n", var_idp->name, var_idp->label_index);
                fprintf(code_file, "\tpha.w\n");
            }
        }
    } else {  // var_level < level //
	    int lev = var_level;

        fprintf(code_file, "\tswp x\n");
        //
	    do {
            fprintf(code_file, "\tlda.w %s,X\n", STATIC_LINK);
            fprintf(code_file, "\ttax\n");
	    } while (++lev < level);
        //
        // emit_2(varparm_flag ? MOVE : LOAD_ADDRESS, reg(AX), word(var_idp));
        //
        if (varparm_flag) {
            fprintf(code_file, "\tlda.w %s_%03d,X\n", var_idp->name, var_idp->label_index);
            fprintf(code_file, "\tpha.w\n");
        } else {
        	//
        	// Calculate address of local variable as an offset from BP
        	//
            fprintf(code_file, "\tclc\n");
            fprintf(code_file, "\tadc.w #%s_%03d\n", var_idp->name, var_idp->label_index);
            fprintf(code_file, "\tpha.w\n");
        }
        //
        fprintf(code_file, "\tswp x\n");
    }
}

//////////////////////////////////////////////////////////////////
//  emit_push_return_value_address      Emit code to push the   //
//                                      address of the function //
//                                      return value in the     //
//                                      stack frame.            //
//////////////////////////////////////////////////////////////////

void emit_push_return_value_address(SYMTAB_NODE_PTR var_idp)
{
    int lev = var_idp->level + 1;

    if (lev < level) {
	    //
	    //  Find the appropriate stack frame.
	    //
        fprintf(code_file, "\tswp x\n");
        //
	    do {
            fprintf(code_file, "\tlda.w %s,X\n", STATIC_LINK);
            fprintf(code_file, "\ttax.w\n");
	    } while (++lev < level);
    	//
    	// Calculate address of local variable as an offset from BP
    	//
        fprintf(code_file, "\tclc\n");
        fprintf(code_file, "\tadc.w #%s\n", RETURN_VALUE);
        fprintf(code_file, "\tpha.w\n");
        //
        fprintf(code_file, "\tswp x\n");
    } else {
    	//
    	// Calculate address of local variable as an offset from BP
    	//
        fprintf(code_file, "\ttxa.w\n");
        fprintf(code_file, "\tclc\n");
        fprintf(code_file, "\tadc.w #%s\n", RETURN_VALUE);
        fprintf(code_file, "\tpha.w\n");
    }
}

		//**************************************//
		//                                      //
		//      Emit miscellaneous code         //
		//                                      //
		//**************************************//

//////////////////////////////////////////////////////////////////
//  emit_promote_to_real        Emit code to convert integer    //
//                              operands to real.               //
//////////////////////////////////////////////////////////////////

void emit_promote_to_real(TYPE_STRUCT_PTR tp1, TYPE_STRUCT_PTR tp2)
{
    if (tp2 == integer_typep) {
        //
    	// Promote parameter #2 from integer to real
    	//
		fprintf(code_file, "\tjsr _fconv\n");
        fprintf(code_file, "\tadj #%d\n", 2);
        //
        // Push real parameter #2
        //
        fprintf(code_file, "\tswp a\n");
        fprintf(code_file, "\tpha.w\n");
        fprintf(code_file, "\tswp a\n");
        fprintf(code_file, "\tpha.w\n");
    }

    if (tp1 == integer_typep) {
    	//
    	// Pull real parameter #2 and hold in ATOS (hi) and ANOS (lo)
        //
    	fprintf(code_file, "\tpla.w\n");
        fprintf(code_file, "\tswp a\n");
        fprintf(code_file, "\tpla.w\n");
        //
        // Pull integer parameter #1 and hold in YTOS
        //
        fprintf(code_file, "\tply.w\n");
        //
        // Push real parameter #2 back onto the stack temporarily
        //
        fprintf(code_file, "\tpha.w\n");
        fprintf(code_file, "\tswp a\n");
        fprintf(code_file, "\tpha.w\n");
        //
        // Push real parameter #1 onto stack and promote to real
        //
        fprintf(code_file, "\tphy.w\n");
        fprintf(code_file, "\tjsr _fconv\n");
        fprintf(code_file, "\tadj #%d\n", 2);
        //
        // Pull real parameter #2 from stack into YTOS (hi) and YNOS (lo)
        //
        fprintf(code_file, "\tply.w\n");
        fprintf(code_file, "\tswp y\n");
        fprintf(code_file, "\tply.w\n");
        //
        // Push promoted real parameter #1 onto stack
        //
        fprintf(code_file, "\tswp a\n");
        fprintf(code_file, "\tpha.w\n");
        fprintf(code_file, "\tswp a\n");
        fprintf(code_file, "\tpha.w\n");
        //
        fprintf(code_file, "\tphy.w\n");
        fprintf(code_file, "\tswp y\n");
        fprintf(code_file, "\tphy.w\n");
    }
}
