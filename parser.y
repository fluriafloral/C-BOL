%{
#include <stdio.h>

int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char * yytext;

%}

%union {
    char * sValue;  /* string value */
};

%token <sValue> INTEGER
%token <sValue> DECIMAL
%token <sValue> REAL
%token <sValue> CHARACTER
%token <sValue> TEXT
%token <sValue> P_TYPE
%token <sValue> RELATIONAL
%token <sValue> ID
%token UNIT
%token LARGE DEFINE ENUM END_ENUM STRUCT END_STRUCT CONST
%token IF THEN ELIF ELSE END_IF
%token SWITCH CASE THRU OTHER END_SWITCH
%token WHILE END_WHILE FOR END_FOR DO
%token CALL PROCEDURE END_PROCEDURE FUNCTION END_FUNCTION
%token RETURN BREAK CONTINUE
%token TRY END_TRY CATCH THROW FINALLY EXPECT
%token LAZY LAZY_RIGHT
%token NOT AND AND_THEN OR OR_ELSE XOR
%token '^' '*' '/' '%' '+' '-'
%token '(' ')' '[' ']' '{' '}' ',' ':' '=' ';'

%start prog

/// ASSOCIATIVITY AND PRECEDENCE
/// https://www.gnu.org/software/bison/manual/html_node/Precedence.html

%left RELATIONAL
%left OR XOR OR_ELSE 
%left AND AND_THEN
%left NOT
%left '+' '-'
%left '*' '/' '%'
%right '^'

%type <sValue> stm

%%
prog : stmlist
     ;

/// TYPES
type : P_TYPE
     | LARGE P_TYPE
     | ID
     ;

/// END-TYPES

/// CONDITIONALS

if_elifs : ELIF exp stmlist if_elifs 
         |
         ;

if_else : ELSE stmlist 
        |
        ;

if_stmts : IF exp stmlist if_elifs if_else END_IF
         ;

switch_case_optional : stmlist
                     |
                     ;

switch_case : CASE exp ':' switch_case_optional
            | CASE exp ':' switch_case_optional switch_case
            | CASE exp THRU exp ':' switch_case_optional
            | CASE exp THRU exp ':' switch_case_optional switch_case
            | CASE OTHER ':' stmlist
            ;
        
switch_stmts : SWITCH exp switch_case END_SWITCH
             ;

/// END-CONDITIONALS





/// LOOPS

while_stmts : WHILE exp stmlist END_WHILE
            ;

for_var_init : type assign
             | assign
             ;

for_stm : FOR '(' for_var_init ';' exp ';' stm ')' stmlist END_FOR
        | FOR '(' type ID ':' ID ')' stmlist END_FOR
        ;

do_stm : DO stmlist THEN WHILE exp
       ;

/// END-LOOPS




/// EXCEPTIONS
expect_stm : EXPECT exp ELSE TEXT
           ;

try_catches : CATCH '(' P_TYPE ID ')' stmlist
            | CATCH '(' P_TYPE ID ')' stmlist try_catches
            ;

try_finally_optional : FINALLY stmlist
                     | 
                     ;

try_stm : TRY stmlist try_catches try_finally_optional END_TRY
        ;

/// END-EXCEPTIONS





/// PROCEDURE
proc_args : type ID
          | type ID ',' proc_args
          | type ID '[' ']'
          | type ID '[' ']' ',' proc_args
          | type assign
          ;
          
proc_params : '(' proc_args ')'
            | UNIT
            ;

proc_stm : PROCEDURE ID proc_params stmlist END_PROCEDURE
         ;
/// END-PROCEDURE





/// FUNCTIONS
func_stm : FUNCTION ID proc_params stmlist END_FUNCTION
         ;
/// END-FUNCTIONS





/// DECLARATIONS
declar_struct_field : type ID 
                    | type ID '[' exp ']' 
                    ;

declar_struct_fields : declar_struct_field ';'
                     | declar_struct_field ';' declar_struct_fields
                     ;

declar_struct : STRUCT ID declar_struct_fields END_STRUCT
              ;

declar_enum_item : ID
                 | ID '=' exp_literal
                 ;

declar_enum_items : declar_enum_item
                  | declar_enum_item ',' declar_enum_items
                  ;

declar_enum : ENUM ID declar_enum_items END_ENUM
            ;

declar_array_dimensions :
                        | '[' exp ']' declar_array_dimensions
                        ;

declar_var : ID
           | ID '=' exp
           | ID '[' exp ']' declar_array_dimensions
           | ID '[' exp ']' declar_array_dimensions '=' exp
           ;

declar_vars : declar_var
            | declar_var ',' declar_vars
            ;

declar : type declar_vars
       | CONST type ID '=' exp
       | declar_struct
       | declar_enum
       ;

/// END-DECLARATIONS





/// EXPRESSIONS
exp_literal : UNIT
          | INTEGER
          | REAL
          | DECIMAL
          | CHARACTER
          | TEXT
          ;

exp_logic : exp RELATIONAL exp
          | exp AND exp
          | exp AND_THEN exp
          | exp OR exp
          | exp OR_ELSE exp
          | exp XOR exp
          | NOT exp
          ;

exp_arith : exp '+' exp
          | exp '-' exp
          | exp '*' exp
          | exp '/' exp
          | exp '%' exp
          | exp '^' exp
          ;

exp_lazy : LAZY
         | LAZY_RIGHT
         ;

exp_func_opt : exp
             | exp ',' exp_func_opt
             ;

exp_func_args : '(' exp_func_opt ')'
              | UNIT
              ;

exp_array_values : exp
                 | exp ',' exp_array_values
                 ;

exp_array_list : '{' exp_array_values '}'
               ;

exp : exp_literal
    | ID
    | ID '[' exp ']'
    | ID exp_func_args
    | exp_array_list
    | exp_logic
    | exp_arith
    | exp_lazy '(' exp_arith ')'
    | '(' exp ')'
    | '-' exp
    ;
/// END-EXPRESSIONS





/// ASSIGN-OP
assign_op_stm : ID '+' '=' exp
              | ID '-' '=' exp
              | ID '*' '=' exp
              | ID '/' '=' exp
              | ID '%' '=' exp
              | ID '^' '=' exp
              ;
/// END-ASSIGN-OP





/// STMS
assign : ID '=' exp
       | ID '[' exp ']' '=' exp
       ;
       
stm : assign {}
    | if_stmts {}
    | switch_stmts {}
    | while_stmts {}
    | for_stm {}
    | do_stm {}
    | declar {}
    | expect_stm {}
    | try_stm {}
    | proc_stm {}
    | func_stm {}
    | CALL ID exp_func_args {}
    | CONTINUE {}
    | BREAK {}
    | THROW exp {}
    | RETURN exp {}
    | assign_op_stm {}
    ;

stmlist : stm ';'
	| stm ';' stmlist
	;

/// END-STMS
%%

int main (void) {
	return yyparse();
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}