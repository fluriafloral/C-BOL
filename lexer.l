%{
  #include <stdio.h>  
%}

%%

[ \t\n]                                                  ;
[0-9]+                                                   {printf("NUMBER(%s)\n",yytext);}
"int" | "float" | "char" | "double" | "text" | "decimal" {printf("TYPE(%s)\n", yytext);}
.                                                        {printf("Invalid character.\n");}

%%

#ifndef yywrap
   int yywrap (void) {return 1;}
#endif

int main(void)
{
  yylex();  
  return 0;
}