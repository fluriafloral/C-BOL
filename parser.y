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
%token <iValue> INTEGER
%token <dValue> DECIMAL
%token <fValue> REAL
%token <cValue> CHARACTER
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
%token POWER MULTIPLICATION DIVISION REST_OF_DIVISION SUM SUBTRACTION
%token BEGIN_PARENTESES END_PARENTESES BEGIN_SQUARE_BRACKET END_SQUARE_BRACKET BEGIN_CURLY_BRACKET END_CURLY_BRACKET COMMA COLON ASSIGN SEMICOLON

%start prog

%type <sValue> stm

%%
prog : stmlist {} 
	 ;

stm : ID ASSIGN ID                                      {printf("%s = %s \n",$1, $3);}
    ;

stmlist : stm SEMICOLON						{}
		| stm SEMICOLON stmlist				{}
	    ;
%%

int main (void) {
	return yyparse();
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}