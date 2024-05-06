%{
  #include <stdio.h>  
  #include <stdlib.h>
  #include "y.tab.h"

  extern int yyerror (char *msg);
%}

%%

[ \t\n]                                                      ;
"//".*|"/*"([^*]|\*+[^*/])*\*+"/"                            {yylval.sValue = strdup(yytext); return COMMENT;}
            
[0-9]+                                                       {yylval.iValue = atoi(yytext); return INTEGER;}
([0-9]*"."[0-9]+|[0-9]+"."[0-9]*)                            {yylval.dValue = atof(yytext); return DECIMAL;}
([0-9]*"."[0-9]+"r"|[0-9]+"r"|[0-9]+"."[0-9]+"r")            {yylval.fValue = atof(yytext); return REAL;}

"()"                                                         {return UNIT;}
'.?'|'\\.?'                                                  {yylval.cValue = yytext[0]; return CHARACTER;}
\".*\"                                                       {yylval.sValue = yytext; return TEXT;}

"UNIT"|"EMPTY"|"INTEGER"|"REAL"|"DECIMAL"|"CHARACTER"|"TEXT" {yylval.sValue = yytext; return TYPE;}

"LARGE"                                                      {return LARGE;}
"DEFINE"                                                     {return DEFINE;}
"ENUM"                                                       {return ENUM;}
"END-ENUM"                                                   {return END_ENUM;}
"STRUCT"                                                     {return STRUCT;}
"END-STRUCT"                                                 {return END_STRUCT;}
"CONST"                                                      {return CONST;}

"IF"                                                         {return IF;}
"THEN"                                                       {return THEN;}
"ELIF"                                                       {return ELIF;}
"ELSE"                                                       {return ELSE;}
"END-IF"                                                      {return END_IF;}

"SWITCH"                                                     {return SWITCH;}
"CASE"                                                       {return CASE;}
"THRU"                                                       {return THRU;}
"OTHER"                                                      {return OTHER;}

"WHILE"                                                      {return WHILE;}
"END-WHILE"                                                  {return END_WHILE;}

"FOR"                                                        {return FOR;}
"END-FOR"                                                    {return END_FOR;}

"DO"                                                         {return DO;}
"END-DO"                                                     {return END_DO;}

"PROCEDURE"                                                  {return PROCEDURE;}
"END-PROCEDURE"                                              {return END_PROCEDURE;}
"END-FUNCTION"                                               {return END_FUNCTION;}

"RETURN"                                                     {return RETURN;}
"BREAK"                                                      {return BREAK;}
"CONTINUE"                                                   {return CONTINUE;}

"TRY"                                                        {return TRY;}
"END-TRY"                                                    {return END_TRY;}
"CATCH"                                                      {return CATCH;}
"THROW"                                                      {return THROW;}
"FINALLY"                                                    {return FINALLY;}
"EXPECT"                                                     {return EXPECT;}

"LAZY"                                                       {return LAZY;}

"NOT"                                                        {return NOT;}
"AND"                                                        {return AND;}
"OR"                                                         {return OR;}
"XOR"                                                        {return XOR;}

"^"                                                          {return POWER;}
"*"                                                          {return MULTIPLICATION;}
"/"                                                          {return DIVISION;}
"%"                                                          {return REST_OF_DIVISION;}
"+"                                                          {return SUM;}
"-"                                                          {return SUBTRACTION;}

"=="|"!="|"<"|">"|"<="|">="                                  {yylval.sValue = yytext; return RELATIONAL;}

"("                                                          {return BEGIN_PARENTESES;}
")"                                                          {return END_PARENTESES;}
"["                                                          {return BEGIN_SQUARE_BRACKET;}
"]"                                                          {return END_SQUARE_BRACKET;}
"{"                                                          {return BEGIN_CURLY_BRACKET;}
"}"                                                          {return END_CURLY_BRACKET;}
","                                                          {return COMMA;}
":"                                                          {return COLON;}
"="                                                          {return ASSIGN;}

";"                                                          {return SEMICOLON;}

[a-zA-Z][a-zA-Z0-9_]*                                        {yylval.sValue = yytext; return ID;}

.                                                            {yyerror("Invalid character.");}

%%

#ifndef yywrap
   int yywrap (void) {return 1;}
#endif