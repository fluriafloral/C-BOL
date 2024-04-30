%{
  #include <stdio.h>  
%}

%%

[ \t\n]                     ;
[0-9]+                      {printf("INTEGER(%s)\n", yytext);}
([0-9]*"."[0-9]+ | [0-9]+"."[0-9]*)                          {printf("DECIMAL(%s)\n", yytext);}
([0-9]*"."[0-9]+"r" | [0-9]+"r" | [0-9]+"."[0-9]+"r")        {printf("REAL(%s)\n", yytext);}
"()"                        {printf("UNIT\n");}
'.?'                        {printf("CHARACTER(%s)\n", yytext);}
\".*\"                      {printf("TEXT(%s)\n", yytext);}
"UNIT"|"EMPTY"|"INTEGER"|"REAL"|"DECIMAL"|"CHARACTER"|"TEXT" {printf("TYPE(%s)\n", yytext);}
"LARGE"                     {printf("LARGE\n");}
"DEFINE"                    {printf("DEFINE\n");}
"STRUCT"                    {printf("STRUCT\n");}
"END"                       {printf("END\n");}
"IF"                        {printf("IF\n");}
"RETURN"                    {printf("RETURN\n");}
"CONST"                     {printf("CONST\n");}
"AND"                       {printf("AND\n");}
"OR"                        {printf("OR\n");}
"XOR"                       {printf("XOR\n");}
"*"                         {printf("MULTIPLICATION\n");}
"/"                         {printf("DIVISION\n");}
"%"                         {printf("REST_OF_DIVISION\n")}
"+"                         {printf("SUM\n");}
"-"                         {printf("SUBTRACTION\n");}
"=="                        {printf("EQUALS\n");}
"!="                        {printf("NOT_EQUALS\n");}
"!"                         {printf("NOT\n");}
"<"                         {printf("LESS_THAN\n");}
">"                         {printf("GREATER_THAN\n");}
"<="                        {printf("LESS_OR_EQUAL\n");}
">="                        {printf("GREATER_OR_EQUAL\n");}
"("                         {printf("BEGIN_PARENTESES\n")}
","                         {printf("COLON\n");}
")"                         {printf("END_PARENTESES\n")}
"="                         {printf("ASSIGN\n");}
";"                         {printf("SEMICOLON\n");}
[a-zA-Z][a-zA-Z0-9_]*       {printf("ID(%s)\n", yytext);}
.                           {printf("Invalid character.\n");}

%%

#ifndef yywrap
   int yywrap (void) {return 1;}
#endif

int main(void)
{
  yylex();  
  return 0;
}