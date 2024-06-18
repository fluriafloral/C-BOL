%{
  #include <stdio.h>  
  #include <stdlib.h>
  #include "y.tab.h"

  extern int yyerror (char *msg);
%}

%%

[ \t]                                                        ;
\n                                                           {yylineno++;}
"//".*|"/*"([^*]|\*+[^*/])*\*+"/"                            {}
            
[0-9]+                                                       {yylval.sValue = strdup(yytext); return INTEGER;}
([0-9]*"."[0-9]+|[0-9]+"."[0-9]*)                            {yylval.sValue = strdup(yytext); return DECIMAL;}
([0-9]*"."[0-9]+"r"|[0-9]+"r"|[0-9]+"."[0-9]+"r")            {yylval.sValue = strdup(yytext); return REAL;}

"()"                                                         {return UNIT;}
'.?'|'\\.?'                                                  {yylval.sValue = strdup(yytext); return CHARACTER;}
\".*\"                                                       {yylval.sValue = strdup(yytext); return TEXT;}

"UNIT"|"EMPTY"|"INTEGER"|"REAL"|"DECIMAL"|"CHARACTER"|"TEXT" {yylval.sValue = strdup(yytext); return P_TYPE;}

"LARGE"                                                      {return LARGE;}
"DEFINE"                                                     {return DEFINE;}
"ENUM"                                                       {return ENUM;}
"END-ENUM"                                                   {return END_ENUM;}
"STRUCT"                                                     {return STRUCT;}
"END-STRUCT"                                                 {return END_STRUCT;}
"CONST"                                                      {return CONST;}

"OUTPUT"                                                     {return OUTPUT;}
"INPUT"                                                      {return INPUT;}

"PROGRAM"                                                    {return PROGRAM;}
"END-PROGRAM"                                                {return END_PROGRAM;}

"IF"                                                         {return IF;}
"THEN"                                                       {return THEN;}
"ELIF"                                                       {return ELIF;}
"ELSE"                                                       {return ELSE;}
"END-IF"                                                     {return END_IF;}

"SWITCH"                                                     {return SWITCH;}
"CASE"                                                       {return CASE;}
"THRU"                                                       {return THRU;}
"OTHER"                                                      {return OTHER;}
"END-SWITCH"                                                 {return END_SWITCH;}

"WHILE"                                                      {return WHILE;}
"END-WHILE"                                                  {return END_WHILE;}

"FOR"                                                        {return FOR;}
"END-FOR"                                                    {return END_FOR;}

"DO"                                                         {return DO;}

"CALL"                                                       {return CALL;}
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
"LAZY-RIGHT"                                                 {return LAZY_RIGHT;}

"NOT"                                                        {return NOT;}
"AND"                                                        {return AND;}
"AND-THEN"                                                   {return AND_THEN;}
"OR"                                                         {return OR;}
"OR-ELSE"                                                    {return OR_ELSE;}
"XOR"                                                        {return XOR;}

"^"                                                          {return yytext[0];}
"*"                                                          {return yytext[0];}
"/"                                                          {return yytext[0];}
"%"                                                          {return yytext[0];}
"+"                                                          {return yytext[0];}
"-"                                                          {return yytext[0];}

"=="|"!="|"<"|">"|"<="|">="                                  {yylval.sValue = strdup(yytext); return RELATIONAL;}

"("                                                          {return yytext[0];}
")"                                                          {return yytext[0];}
"["                                                          {return yytext[0];}
"]"                                                          {return yytext[0];}
"{"                                                          {return yytext[0];}
"}"                                                          {return yytext[0];}
","                                                          {return yytext[0];}
":"                                                          {return yytext[0];}
"="                                                          {return yytext[0];}
"@"                                                          {return yytext[0];}
"&"                                                          {return yytext[0];}
"."                                                          {return yytext[0];}
";"                                                          {return yytext[0];}

[a-zA-Z][a-zA-Z0-9_]*                                        {yylval.sValue = strdup(yytext); return ID;}

.                                                            {yyerror("Invalid character.");}

%%

#ifndef yywrap
   int yywrap (void) {return 1;}
#endif