/****************************************************************/
/*                                                              */
/*      S T A N D A R D   R O U T I N E   P A R S E R           */
/*                                                              */
/*      Parsing routines for calls to standard procedures and   */
/*      functions.                                              */
/*                                                              */
/*      FILE:       standard.c                                  */
/*                                                              */
/*      MODULE:     parser                                      */
/*                                                              */
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

#include "code.h"
#include "common.h"
#include "parser.h"
#include "pc65err.h"
#include "scanner.h"
#include "symtab.h"

#define DEFAULT_NUMERIC_FIELD_WIDTH     10
#define DEFAULT_PRECISION               2

/*--------------------------------------------------------------*/
/*  Externals                                                   */
/*--------------------------------------------------------------*/

extern TOKEN_CODE       token;
extern char             word_string[];
extern SYMTAB_NODE_PTR  symtab_display[];
extern int              level;
extern TYPE_STRUCT      dummy_type;

extern TYPE_STRUCT_PTR  integer_typep, real_typep,
			            boolean_typep, char_typep;

extern int              label_index;
extern char             asm_buffer[];
extern char             *asm_bufferp;
extern FILE             *code_file;

extern TOKEN_CODE       follow_parm_list[];
extern TOKEN_CODE       statement_end_list[];

/*--------------------------------------------------------------*/
/*  Function Prototypes                                         */
/*--------------------------------------------------------------*/

TYPE_STRUCT_PTR standard_routine_call(SYMTAB_NODE_PTR);
void read_readln(SYMTAB_NODE_PTR);
void write_writeln(SYMTAB_NODE_PTR);
TYPE_STRUCT_PTR eof_eoln(SYMTAB_NODE_PTR);
TYPE_STRUCT_PTR abs_sqr(SYMTAB_NODE_PTR);
TYPE_STRUCT_PTR arctan_cos_exp_ln_sin_sqrt(SYMTAB_NODE_PTR);
TYPE_STRUCT_PTR pred_succ(SYMTAB_NODE_PTR);
TYPE_STRUCT_PTR chr(void);
TYPE_STRUCT_PTR odd(void);
TYPE_STRUCT_PTR ord(void);
TYPE_STRUCT_PTR round_trunc(SYMTAB_NODE_PTR);

extern void get_token(void);
extern void synchronize(TOKEN_CODE *, TOKEN_CODE *, TOKEN_CODE *);
extern void label(char *, int);
extern void reg(REGISTER);
extern void _operator(INSTRUCTION);
extern void byte_indirect(REGISTER);
extern void word_indirect(REGISTER);
extern void high_dword_indirect(REGISTER);
extern void name_lit(char *);
extern void integer_lit(int);
extern void emit_push_operand(TYPE_STRUCT_PTR);
extern void actual_parm_list(SYMTAB_NODE_PTR, BOOLEAN);

extern void error(ERROR_CODE);

/*--------------------------------------------------------------*/
/*  standard_routine_call   Process a call to a standard        */
/*                          procedure or function.  Return a    */
/*                          pointer to the type structure of    */
/*                          the call.                           */
/*--------------------------------------------------------------*/

TYPE_STRUCT_PTR standard_routine_call(SYMTAB_NODE_PTR rtn_idp)
{
    switch (rtn_idp->defn.info.routine.key) {
	    case READ   :
	    case READLN :   read_readln(rtn_idp);   return(NULL);

	    case WRITE  :
	    case WRITELN:   write_writeln(rtn_idp); return(NULL);

	    case EOFF   :
	    case EOLN   :   return(eof_eoln(rtn_idp));

	    case ABS    :
	    case SQR    :   return(abs_sqr(rtn_idp));

	    case ARCTAN :
	    case COS    :
	    case EXP    :
	    case LN     :
	    case SIN    :
	    case SQRT   :   return(arctan_cos_exp_ln_sin_sqrt(rtn_idp));

	    case PRED   :
	    case SUCC   :   return(pred_succ(rtn_idp));

	    case CHR    :   return(chr());
	    case ODD    :   return(odd());
	    case ORD    :   return(ord());

	    case ROUND  :
	    case TRUNC  :   return(round_trunc(rtn_idp));

        default     :   return(NULL);  // mam, 15L04, added default clause
    }
}

/*--------------------------------------------------------------*/
/*  read_readln             Process a call to read or readln.   */
/*--------------------------------------------------------------*/

void read_readln(SYMTAB_NODE_PTR rtn_idp)
{
    TYPE_STRUCT_PTR actual_parm_tp;     /* actual parm type */

    /*
    --  Parameters are optional for readln.
    */

    if (token == LPAREN) {
	    /*
	    --  <id-list>
	    */
	    do {
	        get_token();

	        /*
	        --  Actual parms must be variables (but parse
	        --  an expression anyway for error recovery).
	        */

	        if (token == IDENTIFIER) {
		        SYMTAB_NODE_PTR idp;

		        search_and_find_all_symtab(idp);
		        actual_parm_tp = base_type(variable(idp, VARPARM_USE));

		        if (actual_parm_tp->form != SCALAR_FORM)
		            error(INCOMPATIBLE_TYPES);
		        else if (actual_parm_tp == integer_typep) {
                    fprintf(code_file, "\tjsr _iread\t;---");
		            emit_1(CALL, name_lit(READ_INTEGER));
                    fprintf(code_file,"\t\t\t\t\t;---");
		            emit_1(POP,  reg(BX));
                    fprintf(code_file, "\tsta.w (0,S)\t;---");
		            emit_2(MOVE, word_indirect(BX), reg(AX));
                    fprintf(code_file, "\tadj #%d\t;pop ops/params\n", 2);
                } else if (actual_parm_tp == real_typep) {
                    fprintf(code_file, "\tjsr _fread\t;---");
		            emit_1(CALL, name_lit(READ_REAL));
                    fprintf(code_file, "\t\t\t\t\t;---");
		            emit_1(POP,  reg(BX));
                    fprintf(code_file, "\tswp\t;---");
		            emit_2(MOVE, high_dword_indirect(BX), reg(DX));
                    fprintf(code_file, "\tldy #2\t;load offset to hi word\n");
                    fprintf(code_file, "\tsta.w (0,S),Y\t;store hi word\n");
                    fprintf(code_file, "\tswp\t;---");
		            emit_2(MOVE, word_indirect(BX), reg(AX));
                    fprintf(code_file, "\tsta.w (0,S)\t;store lo word\n");
                    fprintf(code_file, "\tadj #%d\t;pop ops/params\n", 2);
                } else if (actual_parm_tp == char_typep) {
                    fprintf(code_file, "\tjsr _cread\t;---");
		            emit_1(CALL, name_lit(READ_CHAR));
                    fprintf(code_file, "\t\t\t\t\t;---");
		            emit_1(POP,  reg(BX));
                    fprintf(code_file, "\tsta (0,S)\t;store byte---");
		            emit_2(MOVE, byte_indirect(BX), reg(AL));
                    fprintf(code_file, "\tadj #%d\t;pop ops/params\n", 2);
		        }
            } else {
		        actual_parm_tp = expression();
		        error(INVALID_VAR_PARM);
	        }

	        /*
	        --  Error synchronization:  Should be , or )
	        */

	        synchronize(follow_parm_list, statement_end_list, NULL);
	    } while (token == COMMA);

	    if_token_get_else_error(RPAREN, MISSING_RPAREN);
    } else if (rtn_idp->defn.info.routine.key == READ)
	    error(WRONG_NUMBER_OF_PARMS);

    if (rtn_idp->defn.info.routine.key == READLN) {
        fprintf(code_file, "\tjsr _readln\t;---");
	    emit_1(CALL, name_lit(READ_LINE));
    }
}

/*--------------------------------------------------------------*/
/*  write_writeln           Process a call to write or writeln. */
/*                          Each actual parameter can be:       */
/*                                                              */
/*                              <expr>                          */
/*                                                              */
/*                          or:                                 */
/*                                                              */
/*                              <epxr> : <expr>                 */
/*                                                              */
/*                          or:                                 */
/*                                                              */
/*                              <expr> : <expr> : <expr>        */
/*--------------------------------------------------------------*/

void write_writeln(SYMTAB_NODE_PTR rtn_idp)
{
    TYPE_STRUCT_PTR actual_parm_tp;     /* actual parm type */
    TYPE_STRUCT_PTR field_width_tp, precision_tp;

    /*
    --  Parameters are optional for writeln.
    */

    if (token == LPAREN) {
	    do {
	        /*
	        --  Value <expr>
	        */

	        get_token();
	        actual_parm_tp = base_type(expression());

	        /*
	        --  Push the scalar value to be written onto the stack.
	        --  A string value is already on the stack.
	        */

	        if (actual_parm_tp->form != ARRAY_FORM)
		        emit_push_operand(actual_parm_tp);

	        if ((actual_parm_tp->form != SCALAR_FORM)   &&
		        (actual_parm_tp       != boolean_typep) &&
		       ((actual_parm_tp->form != ARRAY_FORM) ||
		        (actual_parm_tp->info.array.elmt_typep != char_typep)))
		        error(INVALID_EXPRESSION);

	        /*
	        --  Optional field width <expr>
	        --  Push onto the stack.
	        */

	        if (token == COLON) {
		        get_token();
		        field_width_tp = base_type(expression());
                fprintf(code_file, "\tpha.w\t;---");
		        emit_1(PUSH, reg(AX));

		        if (field_width_tp != integer_typep)
		            error(INCOMPATIBLE_TYPES);

		        /*
		        --  Optional precision <expr>
		        --  Push onto the stack if the value to be printed
		        --  is of type real.
		        */

		        if (token == COLON) {
		            get_token();
		            precision_tp = base_type(expression());

                    if (actual_parm_tp == real_typep) {
                        fprintf(code_file, "\tpha.w\t;---");
			            emit_1(PUSH, reg(AX));
                    }

		            if (precision_tp != integer_typep)
			        error(INCOMPATIBLE_TYPES);
                } else if (actual_parm_tp == real_typep) {
                    fprintf(code_file, "\tpsh.w #%d\t;---", DEFAULT_PRECISION);
		            emit_2(MOVE, reg(AX), integer_lit(DEFAULT_PRECISION));
                    fprintf(code_file, "\t\t\t\t\t\t;---");
		            emit_1(PUSH, reg(AX));
		        }
            } else {
		        if (actual_parm_tp == integer_typep) {
                    fprintf(code_file, "\tpsh.w #%d\t;---", DEFAULT_NUMERIC_FIELD_WIDTH);
		            emit_2(MOVE, reg(AX), integer_lit(DEFAULT_NUMERIC_FIELD_WIDTH));
                    fprintf(code_file, "\t\t\t\t\t\t;---");
		            emit_1(PUSH, reg(AX));
                } else if (actual_parm_tp == real_typep) {
                    fprintf(code_file, "\tpsh.w #%d\t;---", DEFAULT_NUMERIC_FIELD_WIDTH);
		            emit_2(MOVE, reg(AX), integer_lit(DEFAULT_NUMERIC_FIELD_WIDTH));
                    fprintf(code_file, "\t\t\t\t\t\t;---");
		            emit_1(PUSH, reg(AX));
                    fprintf(code_file, "\tpsh.w #%d\t;---", DEFAULT_PRECISION);
		            emit_2(MOVE, reg(AX), integer_lit(DEFAULT_PRECISION));
                    fprintf(code_file, "\t\t\t\t\t\t;---");
		            emit_1(PUSH, reg(AX));
                } else {
                    fprintf(code_file, "\tpsh.w #%d\t;---", 0);
		            emit_2(MOVE, reg(AX), integer_lit(0));
                    fprintf(code_file, "\t\t\t\t\t\t;---");
		            emit_1(PUSH, reg(AX));
		        }
	        }

	        if (actual_parm_tp == integer_typep) {
                fprintf(code_file, "\tjsr _iwrite\t;---");
		        emit_1(CALL, name_lit(WRITE_INTEGER));
                fprintf(code_file, "\tadj #%d\t;---", 4);
		        emit_2(ADD, reg(SP), integer_lit(4));
            } else if (actual_parm_tp == real_typep) {
                fprintf(code_file, "\tjsr _fwrite\t;---");
		        emit_1(CALL, name_lit(WRITE_REAL));
                fprintf(code_file, "\tadj #%d\t;---", 8);
		        emit_2(ADD, reg(SP), integer_lit(8));
            } else if (actual_parm_tp == boolean_typep) {
                fprintf(code_file, "\tjsr _bwrite\t;---");
		        emit_1(CALL, name_lit(WRITE_BOOLEAN));
                fprintf(code_file, "\tadj #%d\t;---", 4);
		        emit_2(ADD, reg(SP), integer_lit(4));
            } else if (actual_parm_tp == char_typep) {
                fprintf(code_file, "\tjsr _cwrite\t;---");
		        emit_1(CALL, name_lit(WRITE_CHAR));
                fprintf(code_file, "\tadj #%d\t;---", 4);
		        emit_2(ADD, reg(SP), integer_lit(4));
            } else  /* string */  {
		        /*
		        --  Push the string length onto the stack.
		        */
                fprintf(code_file, "\tpsh.w #%d\t;---", actual_parm_tp->info.array.elmt_count);
		        emit_2(MOVE, reg(AX), integer_lit(actual_parm_tp->info.array.elmt_count));
                fprintf(code_file, "\t\t\t\t\t\t;---");
		        emit_1(PUSH, reg(AX));
                fprintf(code_file, "\tjsr _swrite\t;---");
		        emit_1(CALL, name_lit(WRITE_STRING));
                fprintf(code_file, "\tadj #%d\t;---", 6);
		        emit_2(ADD, reg(SP), integer_lit(6));
	        }

	        /*
	        --  Error synchronization:  Should be , or )
	        */

	        synchronize(follow_parm_list, statement_end_list, NULL);
	    } while (token == COMMA);

    	if_token_get_else_error(RPAREN, MISSING_RPAREN);
    } else if (rtn_idp->defn.info.routine.key == WRITE)
	    error(WRONG_NUMBER_OF_PARMS);

    if (rtn_idp->defn.info.routine.key == WRITELN) {
        fprintf(code_file, "\tjsr _writeln\t;---");
	    emit_1(CALL, name_lit(WRITE_LINE));
    }
}

/*--------------------------------------------------------------*/
/*  eof_eoln                Process a call to eof or to eoln.   */
/*                          No parameters => boolean result.    */
/*--------------------------------------------------------------*/

TYPE_STRUCT_PTR eof_eoln(SYMTAB_NODE_PTR rtn_idp)
{
    if (token == LPAREN) {
	    error(WRONG_NUMBER_OF_PARMS);
	    actual_parm_list(rtn_idp, FALSE);
    }

    if(rtn_idp->defn.info.routine.key == (EOFF)) {
        fprintf(code_file, "\tjsr _eof\t;---");
    } else {
        fprintf(code_file, "\tjsr _eol\t;---");
    }
    emit_1(CALL, name_lit(rtn_idp->defn.info.routine.key == (EOFF) ? STD_END_OF_FILE : STD_END_OF_LINE));
    
    return(boolean_typep);
}

/*--------------------------------------------------------------*/
/*  abs_sqr                 Process a call to abs or to sqr.    */
/*                          integer parm => integer result      */
/*                          real parm    => real result         */
/*--------------------------------------------------------------*/

TYPE_STRUCT_PTR abs_sqr(SYMTAB_NODE_PTR rtn_idp)
{
    TYPE_STRUCT_PTR parm_tp;            /* actual parameter type */
    TYPE_STRUCT_PTR result_tp;          /* result type */

    if (token == LPAREN) {
	    get_token();
	    parm_tp = base_type(expression());

	    if ((parm_tp != integer_typep) && (parm_tp != real_typep)) {
	        error(INCOMPATIBLE_TYPES);
	        result_tp = real_typep;
        } else
            result_tp = parm_tp;

	    if_token_get_else_error(RPAREN, MISSING_RPAREN);
    } else
        error(WRONG_NUMBER_OF_PARMS);

    switch (rtn_idp->defn.info.routine.key) {
	    case ABS :  if (parm_tp == integer_typep) {
		                int nonnegative_labelx = new_label_index();

                        fprintf(code_file, "\tcmp.w #%d\t;---", 0);
		                emit_2(COMPARE, reg(AX), integer_lit(0));
                        fprintf(code_file, "\tbge %s_%03d\t;---", STMT_LABEL_PREFIX, nonnegative_labelx);
		                emit_1(JUMP_GE, label(STMT_LABEL_PREFIX, nonnegative_labelx));
                        fprintf(code_file, "\teor.w #-1\t;---");
		                emit_1(NEGATE, reg(AX));
                        fprintf(code_file, "\tinc.w a\t;complete negation\n");
		                emit_label(STMT_LABEL_PREFIX, nonnegative_labelx);
                    } else {
		                emit_push_operand(parm_tp);
                        fprintf(code_file, "\tjsr _fabs\t;---");
		                emit_1(CALL, name_lit(STD_ABS));
                        fprintf(code_file, "\tadj #%d\t;---", 4);
		                emit_2(ADD, reg(SP), integer_lit(4));
	                }
	                break;

	    case SQR :  if (parm_tp == integer_typep) {
	    				fprintf(code_file, "\tpha.w\t;---");
		                emit_2(MOVE, reg(DX), reg(AX));
		                fprintf(code_file, "\tpha.w\t;---\n");
		                fprintf(code_file, "\tjsr _imul\t;---");
		                emit_1(MULTIPLY, reg(DX));
		                fprintf(code_file, "\tadj #%d\t;---\n", 4);
                    } else {
		                emit_push_operand(parm_tp);
		                emit_push_operand(parm_tp);
		                fprintf(code_file, "\tjsr _fmul\t;---");
		                emit_1(CALL, name_lit(FLOAT_MULTIPLY));
		                fprintf(code_file, "\tadj #%d\t;---", 8);
		                emit_2(ADD, reg(SP), integer_lit(8));
	                }
	                break;
	}
    return(result_tp);
}

/*--------------------------------------------------------------*/
/*  arctan_cos_exp_ln_sin_sqrt  Process a call to arctan, cos,  */
/*                              exp, ln, sin, or sqrt.          */
/*                              integer parm => real result     */
/*                              real_parm    => real result     */
/*--------------------------------------------------------------*/

TYPE_STRUCT_PTR arctan_cos_exp_ln_sin_sqrt(SYMTAB_NODE_PTR rtn_idp)
{
    TYPE_STRUCT_PTR parm_tp;            /* actual parameter type */
    char            *std_func_name;     /* name of standard func */

    if (token == LPAREN) {
	    get_token();
	    parm_tp = base_type(expression());

	    if ((parm_tp != integer_typep) && (parm_tp != real_typep))
	        error(INCOMPATIBLE_TYPES);

	    if_token_get_else_error(RPAREN, MISSING_RPAREN);
    } else
        error(WRONG_NUMBER_OF_PARMS);

    if (parm_tp == integer_typep) {
	    fprintf(code_file, "\tpha.w\t;---");
	    emit_1(PUSH, reg(AX));
	    fprintf(code_file, "\tjsr _fconv\t;---");
	    emit_1(CALL, name_lit(FLOAT_CONVERT));
	    fprintf(code_file, "\tadj #%d\t;---", 2 );
	    emit_2(ADD, reg(SP), integer_lit(2));
    }

    emit_push_operand(real_typep);
    switch (rtn_idp->defn.info.routine.key) {
	    case ARCTAN :   std_func_name = STD_ARCTAN;
	    				fprintf(code_file, "\tjsr _fatan\t;---");
	    				break;
	    case COS    :   std_func_name = STD_COS;
						fprintf(code_file, "\tjsr _fcos\t;---");
						break;
	    case EXP    :   std_func_name = STD_EXP;
						fprintf(code_file, "\tjsr _fexp\t;---");
						break;
	    case LN     :   std_func_name = STD_LN;
						fprintf(code_file, "\tjsr _fln\t;---");
						break;
	    case SIN    :   std_func_name = STD_SIN;
						fprintf(code_file, "\tjsr _fsin\t;---");
						break;
	    case SQRT   :   std_func_name = STD_SQRT;
						fprintf(code_file, "\tjsr _fsqrt\t;---");
						break;
    }
    emit_1(CALL, name_lit(std_func_name));
    fprintf(code_file, "\tadj #%d\t;---", 4);
    emit_2(ADD, reg(SP), integer_lit(4));

    return(real_typep);
}

/*--------------------------------------------------------------*/
/*  pred_succ               Process a call to pred or succ.     */
/*                          integer parm => integer result      */
/*                          enum parm    => enum result         */
/*--------------------------------------------------------------*/

TYPE_STRUCT_PTR pred_succ(SYMTAB_NODE_PTR rtn_idp)
{
    TYPE_STRUCT_PTR parm_tp;            /* actual parameter type */
    TYPE_STRUCT_PTR result_tp;          /* result type */

    if (token == LPAREN) {
	    get_token();
	    parm_tp = base_type(expression());

	    if ((parm_tp != integer_typep) && (parm_tp->form != ENUM_FORM)) {
	        error(INCOMPATIBLE_TYPES);
	        result_tp = integer_typep;
        } else result_tp = parm_tp;

	    if_token_get_else_error(RPAREN, MISSING_RPAREN);
    } else
        error(WRONG_NUMBER_OF_PARMS);

    if(rtn_idp->defn.info.routine.key == (PRED)) {
    	fprintf(code_file, "\tdec.w\t;---");
    } else {
    	fprintf(code_file, "\tinc.w\t'---");
    }

    emit_1(rtn_idp->defn.info.routine.key == (PRED) ? DECREMENT : INCREMENT, reg(AX));

    return(result_tp);
}

/*--------------------------------------------------------------*/
/*  chr                     Process a call to chr.              */
/*                          integer parm => character result    */
/*--------------------------------------------------------------*/

TYPE_STRUCT_PTR chr(void)
{
    TYPE_STRUCT_PTR parm_tp;            /* actual parameter type */

    if (token == LPAREN) {
	    get_token();
	    parm_tp = base_type(expression());

	    if (parm_tp != integer_typep)
            error(INCOMPATIBLE_TYPES);
	    if_token_get_else_error(RPAREN, MISSING_RPAREN);
    } else
        error(WRONG_NUMBER_OF_PARMS);

    return(char_typep);
}

/*--------------------------------------------------------------*/
/*  odd                     Process a call to odd.              */
/*                          integer parm => boolean result      */
/*--------------------------------------------------------------*/

TYPE_STRUCT_PTR odd(void)
{
    TYPE_STRUCT_PTR parm_tp;            /* actual parameter type */

    if (token == LPAREN) {
	    get_token();
	    parm_tp = base_type(expression());

	    if (parm_tp != integer_typep)
            error(INCOMPATIBLE_TYPES);
	    if_token_get_else_error(RPAREN, MISSING_RPAREN);
    } else
        error(WRONG_NUMBER_OF_PARMS);

    fprintf(code_file, "\tand.w #%d\t;---", 1);
    emit_2(AND_BITS, reg(AX), integer_lit(1));
    return(boolean_typep);
}

/*--------------------------------------------------------------*/
/*  ord                     Process a call to ord.              */
/*                          enumeration parm => integer result  */
/*--------------------------------------------------------------*/

TYPE_STRUCT_PTR ord(void)
{
    TYPE_STRUCT_PTR parm_tp;            /* actual parameter type */

    if (token == LPAREN) {
	    get_token();
	    parm_tp = base_type(expression());
            
	    if ((parm_tp->form != ENUM_FORM) && (parm_tp != char_typep)) /* 2/9/91 */
	        error(INCOMPATIBLE_TYPES);
	    if_token_get_else_error(RPAREN, MISSING_RPAREN);
    } else
        error(WRONG_NUMBER_OF_PARMS);

    return(integer_typep);
}

/*--------------------------------------------------------------*/
/*  round_trunc             Process a call to round or trunc.   */
/*                          real parm => integer result         */
/*--------------------------------------------------------------*/

TYPE_STRUCT_PTR round_trunc(SYMTAB_NODE_PTR rtn_idp)
{
    TYPE_STRUCT_PTR parm_tp;            /* actual parameter type */

    if (token == LPAREN) {
	    get_token();
	    parm_tp = base_type(expression());

	    if (parm_tp != real_typep)
            error(INCOMPATIBLE_TYPES);
	    if_token_get_else_error(RPAREN, MISSING_RPAREN);
    } else
        error(WRONG_NUMBER_OF_PARMS);

    emit_push_operand(parm_tp);
    if(rtn_idp->defn.info.routine.key == (ROUND)) {
        fprintf(code_file, "\tjsr _fround\t;---");
    } else {
        fprintf(code_file, "\tjsr _ftrunc\t;---");
    }
    emit_1(CALL, name_lit(rtn_idp->defn.info.routine.key == (ROUND) ? STD_ROUND : STD_TRUNC));
    fprintf(code_file, "\tadj #%d\t;---", 4);
    emit_2(ADD, reg(SP), integer_lit(4));

    return(integer_typep);
}

