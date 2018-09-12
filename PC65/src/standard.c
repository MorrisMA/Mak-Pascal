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
	    case READLN :
	    	read_readln(rtn_idp);
	    	return(NULL);

	    case WRITE  :
	    case WRITELN:
	    	write_writeln(rtn_idp);
	    	return(NULL);

	    case EOFF :
	    case EOLN :
	    	return(eof_eoln(rtn_idp));

	    case ABS :
	    case SQR :
	    	return(abs_sqr(rtn_idp));

	    case ARCTAN :
	    case COS    :
	    case EXP    :
	    case LN     :
	    case SIN    :
	    case SQRT   :
	    	return(arctan_cos_exp_ln_sin_sqrt(rtn_idp));

	    case PRED :
	    case SUCC :
	    	return(pred_succ(rtn_idp));

	    case CHR :
	    	return(chr());

	    case ODD :
	    	return(odd());

	    case ORD :
	    	return(ord());

	    case ROUND :
	    case TRUNC :
	    	return(round_trunc(rtn_idp));

        default :
        	return(NULL);  // mam, 15L04, added default clause
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

		        if (actual_parm_tp->form != SCALAR_FORM) {
		            error(INCOMPATIBLE_TYPES);
		        } else if (actual_parm_tp == integer_typep) {
                    fprintf(code_file, "\tjsr _iread\n");
                    //fprintf(code_file, "\tsta.w (1,S)\n");
                    //fprintf(code_file, "\tadj #%d\n", 2);
                    fprintf(code_file, "\tpli\n");
                    fprintf(code_file, "\tsta.w 0,I++\n");
                } else if (actual_parm_tp == real_typep) {
                    fprintf(code_file, "\tjsr _fread\n");
                    //fprintf(code_file, "\tswp a\n");
                    //fprintf(code_file, "\tldy #2\n");
                    //fprintf(code_file, "\tsta.w (1,S),Y\t; *********** Check Addressing Mode\n");
                    //fprintf(code_file, "\tswp a\n");
                    //fprintf(code_file, "\tsta.w (1,S)\n");
                    //fprintf(code_file, "\tadj #%d\n", 2);
                    fprintf(code_file, "\tpli\n");
                    fprintf(code_file, "\tsta.w 0,I++\n");
                    fprintf(code_file, "\tswp a\n");
                    fprintf(code_file, "\tsta.w 0,I++\n");
                } else if (actual_parm_tp == char_typep) {
                    fprintf(code_file, "\tjsr _cread\n");
                    //fprintf(code_file, "\tsta (1,S)\n");
                    //fprintf(code_file, "\tadj #%d\n", 2);
                    fprintf(code_file, "\tpli\n");
                    fprintf(code_file, "\tsta 0,I++\n");
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
        fprintf(code_file, "\tjsr _readln\n");
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

	        if (actual_parm_tp->form != ARRAY_FORM) {
		        emit_push_operand(actual_parm_tp);
	        }

	        if ((actual_parm_tp->form != SCALAR_FORM)   &&
		        (actual_parm_tp       != boolean_typep) &&
		       ((actual_parm_tp->form != ARRAY_FORM) ||
		        (actual_parm_tp->info.array.elmt_typep != char_typep))) {
		        error(INVALID_EXPRESSION);
	        }

	        /*
	        --  Optional field width <expr>
	        --  Push onto the stack.
	        */

	        if (token == COLON) {
		        get_token();
		        field_width_tp = base_type(expression());
                //fprintf(code_file, "\tpha.w\n");
		        emit_push_operand(integer_typep);

		        if (field_width_tp != integer_typep) {
		            error(INCOMPATIBLE_TYPES);
		        }

		        /*
		        --  Optional precision <expr>
		        --  Push onto the stack if the value to be printed
		        --  is of type real.
		        */

		        if (token == COLON) {
		            get_token();
		            precision_tp = base_type(expression());

                    if (actual_parm_tp == real_typep) {
                        //fprintf(code_file, "\tpha.w\n");
                    	emit_push_operand(integer_typep);
                    }

		            if (precision_tp != integer_typep) {
				        error(INCOMPATIBLE_TYPES);
		            }
                } else if (actual_parm_tp == real_typep) {
                    fprintf(code_file, "\tpsh.w #%d\n", DEFAULT_PRECISION);
		        }
            } else {
		        if (actual_parm_tp == integer_typep) {
                    fprintf(code_file, "\tpsh.w #%d\n", DEFAULT_NUMERIC_FIELD_WIDTH);
                } else if (actual_parm_tp == real_typep) {
                    fprintf(code_file, "\tpsh.w #%d\n", DEFAULT_NUMERIC_FIELD_WIDTH);
                    fprintf(code_file, "\tpsh.w #%d\n", DEFAULT_PRECISION);
                } else {
                    fprintf(code_file, "\tpsh.w #%d\n", 0);
		        }
	        }

	        if (actual_parm_tp == integer_typep) {
                fprintf(code_file, "\tjsr _iwrite\n");
                fprintf(code_file, "\tadj #%d\n", 4);
            } else if (actual_parm_tp == real_typep) {
                fprintf(code_file, "\tjsr _fwrite\n");
                fprintf(code_file, "\tadj #%d\n", 8);
            } else if (actual_parm_tp == boolean_typep) {
                fprintf(code_file, "\tjsr _bwrite\n");
                fprintf(code_file, "\tadj #%d\n", 4);
            } else if (actual_parm_tp == char_typep) {
                fprintf(code_file, "\tjsr _cwrite\n");
                fprintf(code_file, "\tadj #%d\n", 4);
            } else  /* string */  {
		        /*
		        --  Push the string length onto the stack.
		        */
                fprintf(code_file, "\tpsh.w #%d\n", actual_parm_tp->info.array.elmt_count);
                fprintf(code_file, "\tjsr _swrite\n");
                fprintf(code_file, "\tadj #%d\n", 6);
	        }

	        /*
	        --  Error synchronization:  Should be , or )
	        */

	        synchronize(follow_parm_list, statement_end_list, NULL);
	    } while (token == COMMA);

    	if_token_get_else_error(RPAREN, MISSING_RPAREN);
    } else if (rtn_idp->defn.info.routine.key == WRITE) {
	    error(WRONG_NUMBER_OF_PARMS);
    }

    if (rtn_idp->defn.info.routine.key == WRITELN) {
        fprintf(code_file, "\tjsr _writeln\n");
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
        fprintf(code_file, "\tjsr _eof\n");
    } else {
        fprintf(code_file, "\tjsr _eol\n");
    }
    
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
        } else {
            result_tp = parm_tp;
        }

	    if_token_get_else_error(RPAREN, MISSING_RPAREN);
    } else {
        error(WRONG_NUMBER_OF_PARMS);
    }

    switch (rtn_idp->defn.info.routine.key) {
	    case ABS :  if (parm_tp == integer_typep) {
		                /*
		                int nonnegative_labelx = new_label_index();

                        fprintf(code_file, "\tcmp.w #%d\n", 0);
                        fprintf(code_file, "\tbge %s_%03d\n", STMT_LABEL_PREFIX, nonnegative_labelx);
                        fprintf(code_file, "\teor.w #-1\n");
                        fprintf(code_file, "\tinc.w a\n");
		                emit_label(STMT_LABEL_PREFIX, nonnegative_labelx);
		                */
						emit_push_operand(parm_tp);
						fprintf(code_file, "\tjsr _iabs\n");
						fprintf(code_file, "\tadj #%d\n", 2);
					} else {
		                emit_push_operand(parm_tp);
                        fprintf(code_file, "\tjsr _fabs\n");
                        fprintf(code_file, "\tadj #%d\n", 4);
	                }
	                break;

	    case SQR :  if (parm_tp == integer_typep) {
	    				//fprintf(code_file, "\tpha.w\n");
		                //fprintf(code_file, "\tpha.w\n");
            			emit_push_operand(parm_tp);
            			emit_push_operand(parm_tp);
            			fprintf(code_file, "\tjsr _imul\n");
		                fprintf(code_file, "\tadj #%d\n", 4);
                    } else {
		                emit_push_operand(parm_tp);
		                emit_push_operand(parm_tp);
		                fprintf(code_file, "\tjsr _fmul\n");
		                fprintf(code_file, "\tadj #%d\n", 8);
	                }
	                break;
	    default :   return(NULL);
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

    if (token == LPAREN) {
	    get_token();
	    parm_tp = base_type(expression());

	    if ((parm_tp != integer_typep) && (parm_tp != real_typep)) {
	        error(INCOMPATIBLE_TYPES);
	    }

	    if_token_get_else_error(RPAREN, MISSING_RPAREN);
    } else {
        error(WRONG_NUMBER_OF_PARMS);
    }

    if (parm_tp == integer_typep) {
	    //fprintf(code_file, "\tpha.w\n");
    	emit_push_operand(parm_tp);
	    fprintf(code_file, "\tjsr _fconv\n");
	    fprintf(code_file, "\tadj #%d\n", 2 );
    }

    emit_push_operand(real_typep);
    switch (rtn_idp->defn.info.routine.key) {
	    case ARCTAN :   fprintf(code_file, "\tjsr _fatan\n");
	    				break;
	    case COS    :   fprintf(code_file, "\tjsr _fcos\n");
						break;
	    case EXP    :   fprintf(code_file, "\tjsr _fexp\n");
						break;
	    case LN     :   fprintf(code_file, "\tjsr _fln\n");
						break;
	    case SIN    :   fprintf(code_file, "\tjsr _fsin\n");
						break;
	    case SQRT   :   fprintf(code_file, "\tjsr _fsqrt\n");
						break;
	    default     :   return(NULL);
    }
    fprintf(code_file, "\tadj #%d\n", 4);

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
        } else {
        	result_tp = parm_tp;
        }

	    if_token_get_else_error(RPAREN, MISSING_RPAREN);
    } else {
        error(WRONG_NUMBER_OF_PARMS);
    }

    if(rtn_idp->defn.info.routine.key == (PRED)) {
    	fprintf(code_file, "\tdec.w a\n");
    } else {
    	fprintf(code_file, "\tinc.w a\n");
    }

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

	    if (parm_tp != integer_typep) {
            error(INCOMPATIBLE_TYPES);
	    }
	    if_token_get_else_error(RPAREN, MISSING_RPAREN);
    } else {
        error(WRONG_NUMBER_OF_PARMS);
    }

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

	    if (parm_tp != integer_typep) {
            error(INCOMPATIBLE_TYPES);
	    }
	    if_token_get_else_error(RPAREN, MISSING_RPAREN);
    } else {
        error(WRONG_NUMBER_OF_PARMS);
    }

    fprintf(code_file, "\tand.w #%d\n", 1);
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
            
	    if ((parm_tp->form != ENUM_FORM) && (parm_tp != char_typep)) { /* 2/9/91 */
	        error(INCOMPATIBLE_TYPES);
	    }
	    if_token_get_else_error(RPAREN, MISSING_RPAREN);
    } else {
        error(WRONG_NUMBER_OF_PARMS);
    }

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

	    if (parm_tp != real_typep) {
            error(INCOMPATIBLE_TYPES);
	    }
	    if_token_get_else_error(RPAREN, MISSING_RPAREN);
    } else {
        error(WRONG_NUMBER_OF_PARMS);
    }

    emit_push_operand(parm_tp);
    if(rtn_idp->defn.info.routine.key == (ROUND)) {
        fprintf(code_file, "\tjsr _fround\n");
    } else {
        fprintf(code_file, "\tjsr _ftrunc\n");
    }
    fprintf(code_file, "\tadj #%d\n", 4);

    return(integer_typep);
}

