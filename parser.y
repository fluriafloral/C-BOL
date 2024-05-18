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
%token PROCEDURE END_PROCEDURE END_FUNCTION
%token RETURN BREAK CONTINUE
%token TRY END_TRY CATCH THROW FINALLY EXPECT
%token LAZY
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

for_stm : FOR '(' assign ';' exp ';' stm ')' stmlist END_FOR
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





/// DECLARATIONS
declar_struct_fields : type ID ';'
                     | type ID ';' declar_struct_fields
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

declar : type ID
       | type ID '=' exp
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

exp : exp_literal
    | ID
    | exp_logic
    | exp_arith
    | '(' exp ')'
    ;
/// END-EXPRESSIONS

/// STMS
assign : ID '=' exp
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
    | CONTINUE {}
    | BREAK {}
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