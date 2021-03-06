/****************************************************************/
/*                                                              */
/*      E M I T   C O D E   S E Q U E N C E S                   */
/*                                                              */
/*      Routines for emitting standard                          */
/*      assembly code sequences.                                */
/*                                                              */
/*      FILE:       emitcode.c                                  */
/*                                                              */
/*      MODULE:     code                                        */
/*                                                              */
/*      Copyright (c) 1991 by Ronald Mak                        */
/*      For instructional purposes only.  No warranties.        */
/*                                                              */
/****************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "symtab.h"
#include "code.h"

/*--------------------------------------------------------------*/
/*  Externals                                                   */
/*--------------------------------------------------------------*/

extern TYPE_STRUCT_PTR  integer_typep, real_typep,
			            boolean_typep, char_typep;

extern int level;

extern char     asm_buffer[];
extern char     *asm_bufferp;
extern FILE     *code_file;

/*--------------------------------------------------------------*/
/*  Globals                                                     */
/*--------------------------------------------------------------*/

SYMTAB_NODE_PTR  float_literal_list  = NULL;
SYMTAB_NODE_PTR  string_literal_list = NULL;

/*--------------------------------------------------------------*/
/*  Function Prototypes                                         */
/*--------------------------------------------------------------*/

extern void reg(REGISTER);
extern void _operator(INSTRUCTION);
extern void byte(SYMTAB_NODE_PTR);
extern void byte_indirect(REGISTER);
extern void word(SYMTAB_NODE_PTR);
extern void high_dword(SYMTAB_NODE_PTR);
extern void word_indirect(REGISTER);
extern void high_dword_indirect(REGISTER);
extern void name_lit(char *);
extern void integer_lit(int);
extern void char_lit(char);
extern void emit_text_equate(SYMTAB_NODE_PTR);


		/****************************************/
		/*                                      */
		/*      Emit prologues and epilogues    */
		/*                                      */
		/****************************************/

/*--------------------------------------------------------------*/
/*  emit_program_prologue       Emit the program prologue.      */
/*--------------------------------------------------------------*/

void emit_program_prologue()

{
    fprintf(code_file, "\tDOSSEG\n");
    fprintf(code_file, "\t.MODEL  small\n");
    fprintf(code_file, "\t.STACK  1024\n");
    fprintf(code_file, "\n");
    fprintf(code_file, "\t.CODE\n");
    fprintf(code_file, "\n");
    fprintf(code_file, "\tPUBLIC\t_pascal_main\n");
    fprintf(code_file, "\tINCLUDE\tpasextrn.inc\n");
    fprintf(code_file, "\n");

    /*
    --  Equates for stack frame components.
    */

    fprintf(code_file, "%s\t\tEQU\t<WORD PTR [bp+4]>\n", STATIC_LINK);
    fprintf(code_file, "%s\t\tEQU\t<WORD PTR [bp-4]>\n", RETURN_VALUE);
    fprintf(code_file, "%s\tEQU\t<WORD PTR [bp-2]>\n", HIGH_RETURN_VALUE);
    fprintf(code_file, "\n");
}

/*--------------------------------------------------------------*/
/*  emit_program_epilogue       Emit the program epilogue,      */
/*                              which includes the data         */
/*                              segment.                        */
/*--------------------------------------------------------------*/

void emit_program_epilogue(SYMTAB_NODE_PTR prog_idp)
{
    SYMTAB_NODE_PTR np;
    int             i, length;

    fprintf(code_file, "\n");
    fprintf(code_file, "\t.DATA\n");
    fprintf(code_file, "\n");

    /*
    --  Emit declarations for the program's global variables.
    */

    for (np = prog_idp->defn.info.routine.locals; np != NULL; np = np->next) {
	    fprintf(code_file, "%s_%03d\t", np->name, np->label_index);
	    if (np->typep == char_typep)
	        fprintf(code_file, "DB\t0\n");
	    else if (np->typep == real_typep)
	        fprintf(code_file, "DD\t0.0\n");
	    else if (np->typep->form == ARRAY_FORM)
	        fprintf(code_file, "DB\t%d DUP(0)\n", np->typep->size);
	    else if (np->typep->form == RECORD_FORM)
	        fprintf(code_file, "DB\t%d DUP(0)\n", np->typep->size);
	    else
	        fprintf(code_file, "DW\t0\n");
    }

    /*
    --  Emit declarations for the program's floating point literals.
    */

    for (np = float_literal_list; np != NULL; np = np->next)
	    fprintf(code_file, "%s_%03d\tDD\t%e\n",
                           FLOAT_LABEL_PREFIX,
			               np->label_index,
			               np->defn.info.constant.value.real);

    /*
    --  Emit declarations for the program's string literals.
    */

    for (np = string_literal_list; np != NULL; np = np->next) {
	    fprintf(code_file, "%s_%03d\tDB\t\"", 
                           STRING_LABEL_PREFIX,
			               np->label_index);

	length = strlen(np->name) - 2;
	for (i = 1; i <= length; ++i)
        fputc(np->name[i], code_file);
	    fprintf(code_file, "\"\n");
    }

    fprintf(code_file, "\n");
    fprintf(code_file, "\tEND\n");
}

/*--------------------------------------------------------------*/
/*  emit_main_prologue      Emit the prologue for the main      */
/*                          routine _pascal_main.               */
/*--------------------------------------------------------------*/

void emit_main_prologue()
{
    fprintf(code_file, "\n");
    fprintf(code_file, "_pascal_main\tPROC\n");
    fprintf(code_file, "\n");

    emit_1(PUSH, reg(BP));              /* dynamic link */
    fprintf(code_file, ";---\tsiz; phx;\n");
    emit_2(MOVE, reg(BP), reg(SP));     /* new stack frame base */
    fprintf(code_file, ";---\tsiz; tsx;\n");
}

/*--------------------------------------------------------------*/
/*  emit_main_epilogue      Emit the epilogue for the main      */
/*                          routine _pascal_main.               */
/*--------------------------------------------------------------*/

void emit_main_epilogue()
{
    fprintf(code_file, "\n");

    emit_1(POP, reg(BP));       /* restore caller's stack frame */
    fprintf(code_file, ";---\tsiz; plx;\n");
    emit(RETURN);               /* return */
    fprintf(code_file, ";---\trtn;\n");

    fprintf(code_file, "\n");
    fprintf(code_file, "_pascal_main\tENDP\n");
}

/*--------------------------------------------------------------*/
/*  emit_routine_prologue       Emit the prologue for a proce-  */
/*                              dure or a function.             */
/*--------------------------------------------------------------*/

void emit_routine_prologue(SYMTAB_NODE_PTR rtn_idp)
{
    fprintf(code_file, "\n");
    fprintf(code_file, "%s_%03d\tPROC\n", rtn_idp->name, rtn_idp->label_index);
    fprintf(code_file, "\n");

    /* dynamic link */
    emit_1(PUSH, reg(BP));              
    fprintf(code_file, ";---\tsiz; phx;\n");
    
    /* new stack frame base */
    emit_2(MOVE, reg(BP), reg(SP));     
    fprintf(code_file, ";---\tsiz; tsx;\n");

    /*
    --  Allocate stack space for a function's return value.
    */

    if (rtn_idp->defn.key == FUNC_DEFN) {
        emit_2(SUBTRACT, reg(SP), integer_lit(4));
        fprintf(code_file, ";---\tsiz; ldy #%d; adj;\n", -4);
    }
    /*
    --  Allocate stack space for the local variables.
    */

    if (rtn_idp->defn.info.routine.total_local_size > 0) {
	    emit_2(SUBTRACT,
               reg(SP),
               integer_lit(rtn_idp->defn.info.routine.total_local_size));
        fprintf(code_file, ";---\tsiz; ldy #%d; adj;\n", rtn_idp->defn.info.routine.total_local_size);
    }
}

/*--------------------------------------------------------------*/
/*  emit_routine_epilogue       Emit the epilogue for a proce-  */
/*                              dure or a function.             */
/*--------------------------------------------------------------*/

void emit_routine_epilogue(SYMTAB_NODE_PTR rtn_idp)
{
    /*
    --  Load a function's return value into the ax or dx:ax registers.
    */

    if (rtn_idp->defn.key == FUNC_DEFN) {
	    emit_2(MOVE, reg(AX), name_lit(RETURN_VALUE));
        fprintf(code_file, ";---\tsiz; lda %d,B;\n", -4);
        if (rtn_idp->typep == real_typep) {
	        emit_2(MOVE, reg(DX), name_lit(HIGH_RETURN_VALUE));
            fprintf(code_file, ";---\tdup; siz; lda %d,B;\n", -2);
        }
    }

    /* cut back to caller's stack */
    emit_2(MOVE, reg(SP), reg(BP));
    fprintf(code_file, ";---\tsiz; txs;\n");
    
    /* restore caller's stack frame */
    emit_1(POP, reg(BP));
    fprintf(code_file, ";---\tsiz; plx;\n");

    /* return and cut back stack */
    emit_1(RETURN, integer_lit(rtn_idp->defn.info.routine.total_parm_size + 2));
    fprintf(code_file, ";---\tsiz; ldy #%d;\n", rtn_idp->defn.info.routine.total_parm_size + 2);
    fprintf(code_file, ";---\trtn;\n");

    fprintf(code_file, "\n");
    fprintf(code_file, "%s_%03d\tENDP\n", rtn_idp->name, rtn_idp->label_index);
}

		/********************************/
		/*                              */
		/*      Emit equates and data   */
		/*                              */
		/********************************/

/*--------------------------------------------------------------*/
/*  emit_declarations   Emit the parameter and local variable   */
/*                      declarations for a procedure or a       */
/*                      function.                               */
/*--------------------------------------------------------------*/

void emit_declarations(SYMTAB_NODE_PTR rtn_idp)
{
    SYMTAB_NODE_PTR parm_idp = rtn_idp->defn.info.routine.parms;
    SYMTAB_NODE_PTR var_idp  = rtn_idp->defn.info.routine.locals;

    fprintf(code_file, "\n");

    /*
    --  Parameters.
    */

    while (parm_idp != NULL) {
	    emit_text_equate(parm_idp);
	    parm_idp = parm_idp->next;
    }

    /*
    --  Local variables.
    */

    while (var_idp != NULL) {
	    emit_text_equate(var_idp);
	    var_idp = var_idp->next;
    }
}

/*--------------------------------------------------------------*/
/*  emit_numeric_equate     Emit a numeric equate for a field   */
/*                          id and its offset.                  */
/*                                                              */
/*                          Example:   field_007 EQU 3          */
/*--------------------------------------------------------------*/

void emit_numeric_equate(SYMTAB_NODE_PTR idp)
{
    fprintf(code_file, "%s_%03d\tEQU\t%d\n",
		               idp->name,
                       idp->label_index,
		               idp->defn.info.data.offset);
    fprintf(code_file, ";---\t%s_%03d\tEQU\t%d\n",
	//	               idp->name,
    //                 idp->label_index,
	//	               idp->defn.info.data.offset);
}

/*--------------------------------------------------------------*/
/*  emit_text_equate        Emit a text equate for a para-      */
/*                          meter or a local variable id and    */
/*                          its stack frame offset.             */
/*                                                              */
/*                          Examples:  parm_007   EQU <bp+6>    */
/*                                     var_008    EQU <bp-10>   */
/*                                     dword_010  EQU <bp-14>   */
/*--------------------------------------------------------------*/

void emit_text_equate(SYMTAB_NODE_PTR idp)
{
    char *name       = idp->name;
    int  label_index = idp->label_index;
    int  offset      = idp->defn.info.data.offset;

    if (idp->typep == char_typep) {
	    fprintf(code_file, "%s_%03d\tEQU\t<[bp%+d]>\n",
			               name,
                           label_index,
                           offset);
        fprintf(code_file, ";---\t%s_%03d\tEQU\t%+d\n",
		//	                 name,
        //                   label_index,
        //                   offset);
    } else if (idp->typep == real_typep) {
	    fprintf(code_file, "%s_%03d\tEQU\t<[bp%+d]>\n",
			               name,
                           label_index,
                           offset);
	    fprintf(code_file, ";---\t%s_%03d\tEQU\t%+d\n",
		//	                 name,
        //                   label_index,
        //                   offset);
    } else {
	    fprintf(code_file, "%s_%03d\tEQU\t<[bp%+d]>\n",
			               name,
                           label_index,
                           offset);
	    fprintf(code_file, ";---\t%s_%03d\tEQU\t%+d\n",
		//	                 name,
        //                   label_index,
        //                   offset);
    }
}

		/********************************/
		/*                              */
		/*      Emit loads and pushes   */
		/*                              */
		/********************************/

/*--------------------------------------------------------------*/
/*  emit_load_value     Emit code to load a scalar value        */
/*                      into AX or DX:AX.                       */
/*--------------------------------------------------------------*/

void emit_load_value(SYMTAB_NODE_PTR var_idp, TYPE_STRUCT_PTR var_tp)
{
    int     var_level    = var_idp->level;
    BOOLEAN varparm_flag = var_idp->defn.key == VARPARM_DEFN;

    if (varparm_flag) {
	    /*
	    --  VAR formal parameter.
	    --  AX or DX:AX = value the address points to
	    */
	    emit_2(MOVE, reg(BX), word(var_idp));
        fprintf(code_file, ";---\t---\n");        
	    if (var_tp == char_typep) {
	        emit_2(SUBTRACT, reg(AX), reg(AX));
	        emit_2(MOVE, reg(AL), byte_indirect(BX));
            fprintf(code_file, ";---\t---\n");
            fprintf(code_file, ";---\tldy #0\n");        
            fprintf(code_file, ";---\tosx; lda (%s_%03d,B),Y;\n", var_idp->name, var_idp->label_index);        
        } else if (var_tp == real_typep) {
	        emit_2(MOVE, reg(AX), word_indirect(BX));
	        emit_2(MOVE, reg(DX), high_dword_indirect(BX)); // 15L16, mam, changed AX to DX
            fprintf(code_file, ";---\tldy #0\n");        
            fprintf(code_file, ";---\tosx; siz; lda (%s_%03d,B),Y;\n", var_idp->name, var_idp->label_index);        
            fprintf(code_file, ";---\tldy #2\n");        
            fprintf(code_file, ";---\tdup; osx; siz; lda (%s_%03d,B),Y;\n", var_idp->name, var_idp->label_index);        
        } else {
            emit_2(MOVE, reg(AX), word_indirect(BX));
            fprintf(code_file, ";---\tldy #0\n");        
            fprintf(code_file, ";---\tosx; siz; lda (%s_%03d,B),Y;\n", var_idp->name, var_idp->label_index);
        }
    } else if (var_level == 1) {
	    /*
	    --  Global variable:
	    --  AX or DX:AX = value
	    */
	    if (var_tp == char_typep) {
	        emit_2(SUBTRACT, reg(AX), reg(AX));
	        emit_2(MOVE, reg(AL), byte(var_idp));
            fprintf(code_file, ";---\t---\n");
            fprintf(code_file, ";---\tlda %s_%03d;\n", var_idp->name, var_idp->label_index);
        } else if (var_tp == real_typep) {
	        emit_2(MOVE, reg(AX), word(var_idp));
	        emit_2(MOVE, reg(DX), high_dword(var_idp));
            fprintf(code_file, ";---\tsiz; lda %s_%03d;\n", var_idp->name, var_idp->label_index);
            fprintf(code_file, ";---\tdup; siz; lda %s_%03d+2;\n", var_idp->name, var_idp->label_index);
        } else {
            emit_2(MOVE, reg(AX), word(var_idp));
            fprintf(code_file, ";---\tsiz; lda %s_%03d;\n", var_idp->name, var_idp->label_index);
        }
    } else if (var_level == level) {
	    /*
	    --  local parameter or variable:
	    --  AX or DX:AX = value
	    */
	    if (var_tp == char_typep) {
	        emit_2(SUBTRACT, reg(AX), reg(AX));
	        emit_2(MOVE, reg(AL), byte(var_idp));
            fprintf(code_file, ";---\t---\n");
            fprintf(code_file, ";---\tlda %s_%03d,B;\n", var_idp->name, var_idp->label_index);
        } else if (var_tp == real_typep) {
	        emit_2(MOVE, reg(AX), word(var_idp));
	        emit_2(MOVE, reg(DX), high_dword(var_idp));
            fprintf(code_file, ";---\tsiz; lda %s_%03d,B;\n", var_idp->name, var_idp->label_index);
            fprintf(code_file, ";---\tdup; siz; lda %s_%03d+2,B;\n", var_idp->name, var_idp->label_index);
        } else {
            emit_2(MOVE, reg(AX), word(var_idp));
            fprintf(code_file, ";---\tsiz; lda %s_%03d,B;\n", var_idp->name, var_idp->label_index);
        }
    } else {  /* var_level < level */  
	    /*
	    --  Nonlocal parameter or variable.
	    --  First locate the appropriate stack frame, then:
	    --  AX or DX:AX = value
	    */
	    int lev = var_level;

	    emit_2(MOVE, reg(BX), reg(BP));
        fprintf(code_file, ";---\toax; dup;\n");
	    do {
	        emit_2(MOVE, reg(BP), name_lit(STATIC_LINK));
            fprintf(code_file, ";---\tsiz; lda STATIC_LINK,B; siz; tax;\n");
	    } while (++lev < level);

	    if (var_tp == char_typep) {
	        emit_2(SUBTRACT, reg(AX), reg(AX));
	        emit_2(MOVE, reg(AL), byte(var_idp));
            fprintf(code_file, ";---\t---\n");
            fprintf(code_file, ";---\tlda %s_%03d,B;\n", var_idp->name, var_idp->label_index);
        } else if (var_tp == real_typep) {
	        emit_2(MOVE, reg(AX), word(var_idp));
	        emit_2(MOVE, reg(DX), high_dword(var_idp));
            fprintf(code_file, ";---\tsiz; lda %s_%03d,B;\n", var_idp->name, var_idp->label_index);
            fprintf(code_file, ";---\tdup; siz; lda %s_%03d+2,B;\n", var_idp->name, var_idp->label_index);
        } else {
            emit_2(MOVE, reg(AX), word(var_idp));
            fprintf(code_file, ";---\tsiz; lda %s_%03d,B;\n", var_idp->name, var_idp->label_index);
        }

	    emit_2(MOVE, reg(BP), reg(BX));
        fprintf(code_file, ";---\toax; rot;\n");
    }
}

/*--------------------------------------------------------------*/
/*  emit_push_operand   Emit code to push a scalar operand      */
/*                      value onto the stack.                   */
/*--------------------------------------------------------------*/

void emit_push_operand(TYPE_STRUCT_PTR tp)
{
    if ((tp->form == ARRAY_FORM) || (tp->form == RECORD_FORM))
        return;

    if (tp == real_typep) {
        emit_1(PUSH, reg(DX));
        emit_1(PUSH, reg(AX));
        fprintf(code_file, ";---\tsiz; pha;\n");
        fprintf(code_file, ";---\trot; siz; pha;\n");
    } else {
        emit_1(PUSH, reg(AX));
        fprintf(code_file, ";---\tsiz; pha;\n");
    }
}

/*--------------------------------------------------------------*/
/*  emit_push_address   Emit code to push an address onto the   */
/*                      stack.                                  */
/*--------------------------------------------------------------*/

void emit_push_address(SYMTAB_NODE_PTR var_idp)
{
    int     var_level    = var_idp->level;
    BOOLEAN varparm_flag = var_idp->defn.key == VARPARM_DEFN;

    if ((var_level == level) || (var_level == 1)) {
	    /*
        emit_2(varparm_flag ? MOVE : LOAD_ADDRESS, reg(AX), word(var_idp))
        */

        // var_level VAR Param   addressing mode    Comment
        //  level       y           BP-relative     VAR parameters ARE pointers
        //  level       n           BP-relative     LEA loads BP+offset
        //    1         n           absolute        LEA loads absolute

        if (varparm_flag) { 
            emit_2(MOVE, reg(AX), word(var_idp));
            emit_1(PUSH, reg(AX));
            fprintf(code_file, ";---\tsiz; lda %s_%03d,B\n", var_idp->name, var_idp->label_index);
            fprintf(code_file, ";---\tsiz; pha;\n");
        } else { 
            emit_2(LOAD_ADDRESS, reg(AX), word(var_idp));
            emit_1(PUSH, reg(AX));
            if (var_level == 1)
                fprintf(code_file, ";---\tpsh #%s_%03d\n", var_idp->name, var_idp->label_index);
            else
                fprintf(code_file, ";---\tsiz; txa; sec; siz; adc #%s_%03d; siz; pha\n", var_idp->name, var_idp->label_index);
            fprintf(code_file, ";---\t---\n");
        }
    } else {  /* var_level < level */
	    int lev = var_level;

	    emit_2(MOVE, reg(BX), reg(BP));
        fprintf(code_file, ";---\toax; dup;\n");
	    do {
	        emit_2(MOVE, reg(BP), name_lit(STATIC_LINK));
            fprintf(code_file, ";---\tsiz; lda %s,B; siz; tax;\n", STATIC_LINK);
	    } while (++lev < level);
        /*
        emit_2(varparm_flag ? MOVE : LOAD_ADDRESS, reg(AX), word(var_idp));
        */
        if (varparm_flag) {
            emit_2(MOVE, reg(AX), word(var_idp));
            emit_1(PUSH, reg(AX));
            fprintf(code_file, ";---\tsiz; lda off,B;\n");
            fprintf(code_file, ";---\tsiz; pha;\n");
        } else {
            emit_2(LOAD_ADDRESS, reg(AX), word(var_idp));
            emit_1(PUSH, reg(AX));
            fprintf(code_file, ";---\tsiz; txa; clc; siz; adc #off+1;\n");
            fprintf(code_file, ";---\tsiz; pha;\n");
        }
        emit_2(MOVE, reg(BP), reg(BX));
        fprintf(code_file, ";---\toax; rot;\n");
    }
}

/*--------------------------------------------------------------*/
/*  emit_push_return_value_address      Emit code to push the   */
/*                                      address of the function */
/*                                      return value in the     */
/*                                      stack frame.            */
/*--------------------------------------------------------------*/

void emit_push_return_value_address(SYMTAB_NODE_PTR var_idp)
{
    int lev = var_idp->level + 1;

    if (lev < level) {
	    /*
	    --  Find the appropriate stack frame.
	    */

	    emit_2(MOVE, reg(BX), reg(BP));
        fprintf(code_file, ";---\toax; dup;\n");
	    do {
	        emit_2(MOVE, reg(BP), name_lit(STATIC_LINK));
            fprintf(code_file, ";---\tsiz; lda STATIC_LINK,B; siz; tax;\n");
	    } while (++lev < level);

	    emit_2(LOAD_ADDRESS, reg(AX), name_lit(RETURN_VALUE));
	    emit_2(MOVE, reg(BP), reg(BX));
        emit_1(PUSH, reg(AX));
        fprintf(code_file, ";---\tsiz; txa; clc; siz; adc #RETURN_VALUE;\n");
        fprintf(code_file, ";---\toax; rot;\n");
        fprintf(code_file, ";---\tsiz; pha;\n");
    } else {
        emit_2(LOAD_ADDRESS, reg(AX), name_lit(RETURN_VALUE));
        emit_1(PUSH, reg(AX));
        fprintf(code_file, ";---\tsiz; txa; clc; siz; adc #RETURN_VALUE;\n");
        fprintf(code_file, ";---\tsiz; pha;\n");
    }
}

		/****************************************/
		/*                                      */
		/*      Emit miscellaneous code         */
		/*                                      */
		/****************************************/

/*--------------------------------------------------------------*/
/*  emit_promote_to_real        Emit code to convert integer    */
/*                              operands to real.               */
/*--------------------------------------------------------------*/

void emit_promote_to_real(TYPE_STRUCT_PTR tp1, TYPE_STRUCT_PTR tp2)
{
    if (tp2 == integer_typep) {
	    emit_1(CALL, name_lit(FLOAT_CONVERT));
        fprintf(code_file, ";---\tjsr _fconv;\n");
	    emit_2(ADD,  reg(SP), integer_lit(2));
        fprintf(code_file, ";---\tldy #2; adj;\n");
	    emit_1(PUSH, reg(DX));
        fprintf(code_file, ";---\tsiz; pha;\n");
	    emit_1(PUSH, reg(AX));                  /* ???_1 real_2 */
        fprintf(code_file, ";---\trot; siz; pha;\n");
    }

    if (tp1 == integer_typep) {
	    emit_1(POP,  reg(AX));
        fprintf(code_file, ";---\tsiz; pla;\n");
	    emit_1(POP,  reg(DX));
        fprintf(code_file, ";---\tdup; siz; pla;\n");
	    emit_1(POP,  reg(BX));
        fprintf(code_file, ";---\tsiz; ply;\n");
	    emit_1(PUSH, reg(DX));
        fprintf(code_file, ";---\tsiz; pha;\n");
	    emit_1(PUSH, reg(AX));
        fprintf(code_file, ";---\trot; siz; pha;\n");
	    emit_1(PUSH, reg(BX));                  /* real_2 integer_1 */
        fprintf(code_file, ";---\tsiz; phy;\n");

	    emit_1(CALL, name_lit(FLOAT_CONVERT));
        fprintf(code_file, ";---\tjsr _fconv;\n");
	    emit_2(ADD,  reg(SP), integer_lit(2));   /* real_2 real_1 */
        fprintf(code_file, ";---\tldy #2; adj;\n");

	    emit_1(POP,  reg(BX));
        fprintf(code_file, ";---\tsiz; ply;\n");
	    emit_1(POP,  reg(CX));
        fprintf(code_file, ";---\tdup; siz; ply;\n");
	    emit_1(PUSH, reg(DX));
        fprintf(code_file, ";---\tsiz; pha;\n");
	    emit_1(PUSH, reg(AX));
        fprintf(code_file, ";---\trot; siz; pha;\n");
	    emit_1(PUSH, reg(CX));
        fprintf(code_file, ";---\tsiz; phy;\n");
	    emit_1(PUSH, reg(BX));                  /* real_1 real_2 */
        fprintf(code_file, ";---\trot; siz; phy;\n");
    }
}
