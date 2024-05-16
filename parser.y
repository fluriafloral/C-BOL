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
%token <sValue> TYPE
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
%token NOT AND OR XOR
%token '^' '*' '/' '%' '+' '-'
%token '(' ')' '[' ']' '{' '}' ',' ':' '=' ';'

%start prog

%type <sValue> stm

%%
prog : stmlist 
	 ;


/// RELATIONALS

/// TODO: NOT
rel_operator : RELATIONAL | AND | OR | XOR;
rel_exp : exp rel_operator exp;
rel_block : '(' rel_exp ')';

/// END-RELATIONALS





/// CONDITIONALS

if_elifs : ELIF rel_block stmlist if_elifs |;
if_else : ELSE stmlist |;

if_stmts
:
IF rel_block
    stmlist
if_elifs
if_else
END_IF
;

switch_case_optional : stmlist
                     | stmlist BREAK ';'
                     | BREAK ';'
                     |;

switch_case : CASE exp ':' switch_case_optional
            | CASE exp ':' switch_case_optional switch_case
            | CASE exp THRU exp ':' switch_case_optional
            | CASE exp THRU exp ':' switch_case_optional switch_case
            | CASE OTHER ':' stmlist
            | CASE OTHER ':' stmlist BREAK ';'
            ;
        
switch_stmts
:
SWITCH '(' exp ')'
    switch_case
END_SWITCH

/// END-CONDITIONALS





/// LOOPS

while_stmts 
: 
WHILE rel_block
    stmlist
END_WHILE

for_stm
:
FOR '(' assign ';' rel_exp ';' stm ')'
    stmlist
END_FOR

do_stm
:
DO
    stmlist
THEN WHILE rel_block
/// END-LOOPS




/// EXCEPTIONS
expect_stm : EXPECT rel_block ELSE TEXT

try_catches
    : CATCH '(' TYPE ID ')' stmlist
    | CATCH '(' TYPE ID ')' stmlist try_catches
    ;

try_finally_optional : | FINALLY stmlist

try_stm
:
TRY
    stmlist
try_catches
try_finally_optional
END_TRY
/// END-EXCEPTIONS





/// DECLARATIONS
declar
    : TYPE ID
    | LARGE TYPE ID /// TODO: Only large types 
    | CONST TYPE ID '=' exp
    ;
/// END-DECLARATIONS





/// EXPRESSIONS
exp_value
    : UNIT
    | INTEGER
    | REAL
    | DECIMAL
    | CHARACTER
    | TEXT
    ;
exp
    : exp_value
    | ID
    ;
/// END-EXPRESSIONS

/// STMS
assign : ID '=' exp;
stm : assign {}
    | if_stmts {}
    | switch_stmts {}
    | while_stmts {}
    | for_stm {}
    | do_stm {}
    | declar {}
    | expect_stm {}
    | try_stm {}
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