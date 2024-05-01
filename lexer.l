%{
  #include <stdio.h>  
%}

%%

[ \t\n]                                                      ;

[0-9]+                                                       {printf("INTEGER(%s)\n", yytext);}
([0-9]*"."[0-9]+|[0-9]+"."[0-9]*)                            {printf("DECIMAL(%s)\n", yytext);}
([0-9]*"."[0-9]+"r"|[0-9]+"r"|[0-9]+"."[0-9]+"r")            {printf("REAL(%s)\n", yytext);}

"()"                                                         {printf("UNIT\n");}
'.?'                                                         {printf("CHARACTER(%s)\n", yytext);}
\".*\"                                                       {printf("TEXT(%s)\n", yytext);}

"UNIT"|"EMPTY"|"INTEGER"|"REAL"|"DECIMAL"|"CHARACTER"|"TEXT" {printf("TYPE(%s)\n", yytext);}

"LARGE"                                                      {printf("LARGE\n");}
"DEFINE"                                                     {printf("DEFINE\n");}
"STRUCT"                                                     {printf("STRUCT\n");}
"CONST"                                                      {printf("CONST\n");}

"IF"                                                         {printf("IF\n");}
"THEN"                                                       {printf("THEN\n");}
"ELIF"                                                       {printf("ELIF\n");}
"ELSE"                                                       {printf("ELSE\n");}
"ENDIF"                                                      {printf("ENDIF\n");}

"SWITCH"                                                     {printf("SWITCH\n");}
"CASE"                                                       {printf("CASE\n");}

"WHILE"                                                      {printf("WHILE\n");}
"END-WHILE"                                                  {printf("END-WHILE\n");}

"FOR"                                                        {printf("FOR\n");}
"END-FOR"                                                    {printf("END-FOR\n");}

"DO"                                                         {printf("DO\n");}
"END-DO"                                                     {printf("END-FOR\n");}

"PROCEDURE"                                                  {printf("PROCEDURE\n");}
"END-PROCEDURE"                                              {printf("END-PROCEDURE\n");}

"RETURN"                                                     {printf("RETURN\n");}
"BREAK"                                                      {printf("BREAK\n");}
"CONTINUE"                                                   {printf("CONTINUE\n");}

"NOT"                                                        {printf("NOT\n");}
"AND"                                                        {printf("AND\n");}
"OR"                                                         {printf("OR\n");}
"XOR"                                                        {printf("XOR\n");}

"*"                                                          {printf("MULTIPLICATION\n");}
"/"                                                          {printf("DIVISION\n");}
"%"                                                          {printf("REST_OF_DIVISION\n");}
"+"                                                          {printf("SUM\n");}
"-"                                                          {printf("SUBTRACTION\n");}

"=="|"!="|"<"|">"|"<="|">="                                  {printf("RELATIONAL(%s)\n", yytext);}

"("                                                          {printf("BEGIN_PARENTESES\n");}
","                                                          {printf("COMMA\n");}
":"                                                          {printf("COLON\n");}
")"                                                          {printf("END_PARENTESES\n");}
"="                                                          {printf("ASSIGN\n");}

";"                                                          {printf("SEMICOLON\n");}

[a-zA-Z][a-zA-Z0-9_]*                                        {printf("ID(%s)\n", yytext);}

.                                                            {printf("Invalid character.\n");}

%%

#ifndef yywrap
   int yywrap (void) {return 1;}
#endif

int main(void)
{
  yylex();  
  return 0;
}