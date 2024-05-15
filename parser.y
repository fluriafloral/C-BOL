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

%token <sValue> COMMENT
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
%token WHILE END_WHILE FOR END_FOR DO END_DO
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
prog : stmlist {} 
	 ;


/// TODO: NOT
relational_operator : RELATIONAL | AND | OR | XOR;

relational : ID relational_operator ID {}
           ;

/// CONDITIONALS

if_exp : '(' relational ')' {};
if_elifs : ELIF if_exp stmlist if_elifs {} | {};
if_else : ELSE stmlist {} | {};

if_stmts
:
IF if_exp
    stmlist
if_elifs
if_else
END_IF {printf("if\n");}
;

switch_case_optional :  stmlist {}
                     | stmlist BREAK ';' {}
                     | BREAK ';' {}
                     | {};

switch_case : CASE ID ':' switch_case_optional {}
            | CASE ID ':' switch_case_optional switch_case {}
            | CASE ID THRU ID ':' switch_case_optional {}
            | CASE ID THRU ID ':' switch_case_optional switch_case {}
            | CASE OTHER ':' stmlist {}
            | CASE OTHER ':' stmlist BREAK ';' {}
            ;
        
switch_stmts
:
SWITCH '(' ID ')'
    switch_case
END_SWITCH {printf("switch\n");};

/// END-CONDITIONALS

stm : ID '=' ID ';'        {}
    | if_stmts                      {}
    | switch_stmts                  {}
    ;

stmlist : stm				        {}
		| stm ';' stmlist	    {}
	    ;
%%

int main (void) {
	return yyparse();
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}