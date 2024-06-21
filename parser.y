%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "./lib/hashtable.h"
#include "./lib/record.h"

int yylex(void);
int yyerror(char *s);
void already_declared_error(char *s);
void undeclared_error(char *s);
void type_error(char *t1, char*t2);
extern int yylineno;
extern char * yytext;
extern FILE * yyin, * yyout;

char * cat(char *, char *, char *, char *, char *);
%}

%union {
    char * sValue;  /* string value */
    struct record * rec;
};

%token <sValue> UNIT INTEGER DECIMAL REAL CHARACTER TEXT P_TYPE RELATIONAL ID
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
%token '(' ')' '[' ']' '{' '}' ',' ':' '=' '@' '&' '.' ';'
%token OUTPUT INPUT
%token PROGRAM END_PROGRAM

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

%type <rec> switch_case_thru switch_case_optional switch_case switch_stmts exp_logic while_stmts proc_stm proc_params proc_args proc_arg_typado
%type <rec> funcs_procs_declars stmlist stm declar declar_vars declar_var declar_array_dimensions exp exp_literal type assign exp_arith func_return_dims func_stm
%type <rec> declar_enum declar_struct

%%
prog : funcs_procs_declars PROGRAM stmlist END_PROGRAM ';' {
        char * includes = "#include <stdio.h>\n#include <math.h>\n";
        fprintf(yyout, "%s\n%s\nint main() {\n%s\nreturn 0;\n}\n", includes, $1->code, $3->code);
        freeRecord($1);
        freeRecord($3);
     }
     ;

funcs_procs_declars : func_stm ';' funcs_procs_declars {
                        char * s = cat($1->code, $3->code, "", "", "");
                        $$ = createRecord(s, "", "");
                        freeRecord($1);
                        freeRecord($3);
                        free(s);
                    }
                    | proc_stm ';' funcs_procs_declars {
                        char * s = cat($1->code, $3->code, "", "", "");
                        $$ = createRecord(s, "", "");
                        freeRecord($1);
                        freeRecord($3);
                        free(s);
                    }
                    | declar_enum ';' funcs_procs_declars {
                        char * s = cat($1->code, ";", $3->code, "", "");
                        $$ = createRecord(s, "", "");
                        freeRecord($1);
                        freeRecord($3);
                        free(s);
                    }
                    | declar_struct ';' funcs_procs_declars {
                        char * s = cat($1->code, ";", $3->code, "", "");
                        $$ = createRecord(s, "", "");
                        freeRecord($1);
                        freeRecord($3);
                        free(s);
                    }
                    | {$$ = createRecord("", "", "");}
                ;

/// TYPES
type : P_TYPE {
        if (strcmp($1, "UNIT") == 0) {
            $$ = createRecord("void ", $1, "");
        } else if (strcmp($1, "EMPTY") == 0) {
            yyerror("Whatahell?!");
            $$ = createRecord("", "", "");
        } else if (strcmp($1, "INTEGER") == 0) {
            $$ = createRecord("int ", $1, "");
        } else if (strcmp($1, "REAL") == 0) {
            $$ = createRecord("float ", $1, "");
        } else if (strcmp($1, "DECIMAL") == 0) {
            $$ = createRecord("double ", $1, "");
        } else if (strcmp($1, "CHARACTER") == 0) {
            $$ = createRecord("char ", $1, "");
        } else if (strcmp($1, "TEXT") == 0) {
            $$ = createRecord("char * ", $1, "");
        }
        free($1);
     }
     | LARGE P_TYPE {
        char * s = cat("long ", $2, "", "", "");
        // TODO: Not all types are longable
        $$ = createRecord(s, $2, "");
        free($2);
        free(s);
     }
     | ID {
        $$ = createRecord($1, $1, "");
        free($1);
     }
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

switch_case_optional : stmlist {$$ = $1;}
                     | {$$ = createRecord("", "", "");}
                     ;

switch_case_thru : CASE exp THRU exp ':' switch_case_optional {
                    // TODO: exps integers
                    char * s = cat("case ", $2->code, ":", "", "");
                    char i_str[12] = "";
                    int begin = atoi($2->code);
                    int end = atoi($4->code);
                    int i = begin + 1;
                    while(i <= end) {
                        sprintf(i_str, "%d", i);
                        s = cat(s, "\ncase ", i_str, ":", "");
                        ++i;
                    }
                    s = cat(s, "\n", $6->code, "", "");
                    $$ = createRecord(s, "", "");
                    freeRecord($2);
                    freeRecord($4);
                    freeRecord($6);
                    free(s);
                 }
                 ;

switch_case : CASE exp ':' switch_case_optional
            | CASE exp ':' switch_case_optional switch_case
            | switch_case_thru {$$ = $1;}
            | switch_case_thru switch_case {
                char * s = cat($1->code, $2->code, "", "", "");
                $$ = createRecord(s, "", "");
                freeRecord($1);
                freeRecord($2);
                free(s);
            }
            | CASE OTHER ':' stmlist
            ;
        
switch_stmts : SWITCH exp switch_case END_SWITCH {
                char * s = cat("switch (", $2->code, ") {\n", $3->code, "\n}");
                $$ = createRecord(s, "", "");
                freeRecord($2);
                freeRecord($3);
                free(s);
             }
             ;

/// END-CONDITIONALS





/// LOOPS

while_stmts : WHILE exp stmlist END_WHILE {
                unsigned long loop_id = (unsigned long) &$2;
                char loop_id_str[21];

                snprintf(loop_id_str, sizeof(loop_id_str), "%lu", loop_id);

                char * s = cat("while", loop_id_str, ":\n", $3->code, "\nif(");
                s = cat(s, $2->code, ")\ngoto while", loop_id_str, "");
                $$ = createRecord(s, "", "");
                freeRecord($2);
                freeRecord($3);
                free(s);
            }
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
proc_arg_typado : type ID {
                    char * s = cat($1->code, $2, "", "", "");
                    char * opt = cat($1->type, "#", $2, "", "");
                    $$ = createRecord(s, $1->type, opt);
                    freeRecord($1);
                    free($2);
                    free(s);
                    free(opt);
                }
                | type '@' ID 
                | type ID '[' ']'
                ;

proc_args : proc_arg_typado {$$ = $1;}
          | proc_arg_typado ',' proc_args {
                char * s = cat($1->code, ", " , $3->code, "", "");
                char * opts = cat($1->opt1, ",", $3->opt1, "", "");
                $$ = createRecord(s, "", opts);
                freeRecord($1);
                freeRecord($3);
                free(s);
                free(opts);
          }
          | type assign
          ;
          
proc_params : '(' proc_args ')' {
                char * s = cat("(", $2->code, ")", "", "");
                $$ = createRecord(s, "", $2->opt1);
                freeRecord($2);
                free(s);
            }
            | UNIT {
                $$ = createRecord("()", "", "");
            }
            ;

proc_stm : PROCEDURE ID proc_params stmlist END_PROCEDURE {
            already_declared_error($2);
            char * argt;
            argt = strtok($3->opt1, ",");
            while (argt != NULL) {
                printf("%s\n", argt);
                //insert_ht(arg, $1->type);
                argt = strtok(NULL, ",");
            }
            char * s = cat("void ", $2, $3->code, "{\n", $4->code);
            s = cat(s, "}\n", "", "", "");
            $$ = createRecord(s, "", "");
            freeRecord($3);
            freeRecord($4);
            free($2);
            free(argt);
            free(s);
         }
         ;
/// END-PROCEDURE





/// FUNCTIONS
func_return_dims :                          {$$ = createRecord("", "", "");}
                 | '[' ']' func_return_dims {
                    char * s = cat("*", $3->code, "", "", "");

                    $$ = createRecord(s, "", "");

                    freeRecord($3);
                    free(s);
                }

func_stm : FUNCTION type func_return_dims ID proc_params stmlist END_FUNCTION {
            already_declared_error($4);

            char * argt = strtok($5->opt1, ",");
            while(argt != NULL) {
                printf("%s\n", argt);
                insert_ht(argt, $2->type);
                argt = strtok(NULL, ",");
            }

            char * x = cat($5->code, " {\n", $6->code, "\n}\n", "\n");
            char * s = cat($2->code, $3->code, $4, x, "");

            $$ = createRecord(s, $2->type, $4);

            freeRecord($2);
            freeRecord($3);
            freeRecord($5);
            freeRecord($6);
            free($3);
            free(argt);
            free(x);
            free(s);
         }
         ;
/// END-FUNCTIONS





/// DECLARATIONS
declar_struct_field : type ID 
                    | type '@' ID
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

declar_array_dimensions :                                     {$$ = createRecord("", "", "");}
                        | '[' exp ']' declar_array_dimensions {
                            char * s = cat("[", $2->code, "]", $4->code, "");
                            $$ = createRecord(s, "", "");
                            freeRecord($2);
                            freeRecord($4);
                            free(s);
                        }
                        ;

declar_var : ID {
                already_declared_error($1);
                $$ = createRecord($1, "", $1);
                free($1);
           }
           | ID '=' exp {
                already_declared_error($1);
                char * s = cat($1, "=", $3->code, "", "");
                $$ = createRecord(s, $3->type, $1);
                freeRecord($3);
                free($1);
                free(s);
           }
           | '@' ID {
                already_declared_error($2);
                char * s = cat("*", $2, "", "", "");
                $$ = createRecord(s, "", s);
                free($2);
                free(s);
           }
           | ID '[' exp ']' declar_array_dimensions
           | ID '[' exp ']' declar_array_dimensions '=' exp
           ;

declar_vars : declar_var {$$ = $1;}
            | declar_var ',' declar_vars {
                type_error($1->type, $3->type);
                char * x = cat($1->opt1, ",", $3->opt1, "", "");
                char * s = cat($1->code, ",", $3->code, "", "");
                $$ = createRecord(s, $1->type, x);
                freeRecord($1);
                freeRecord($3);
                free(s);
                free(x);
            }
            ;

declar : type declar_vars {
            type_error($1->type, $2->type);
            char *id;
            id = strtok($2->opt1, ",");
            while (id != NULL) {
                if (id[0] == '*'){
                    id = strtok(id, "*");
                    char * s = cat($1->type, " @", "", "", "");
                    insert_ht(id, s);
                }
                else {
                    insert_ht(id, $1->type);
                }
                id = strtok(NULL, ",");
            }
            char * s = cat($1->code, $2->code, "", "", "");
            $$ = createRecord(s, "", "");
            freeRecord($1);
            freeRecord($2);
            free(s);
            free(id);
       }
       | CONST type ID '=' exp
       | declar_struct
       | declar_enum
       ;

/// END-DECLARATIONS





/// EXPRESSIONS
exp_literal : UNIT {
                $$ = createRecord("()", "UNIT", "");
                free($1);
          }
          | INTEGER {
                $$ = createRecord($1, "INTEGER", "");
                free($1);
          }
          | REAL {
                $1[strlen($1) - 1] = 'f';
                $$ = createRecord($1, "REAL", "");
                free($1);
          }
          | DECIMAL {
                $$ = createRecord($1, "DECIMAL", "");
                free($1);
          }
          | CHARACTER {
                $$ = createRecord($1, "CHARACTER", "");
                free($1);
          }
          | TEXT {
                $$ = createRecord($1, "TEXT", "");
                free($1);
          }
          ;

exp_logic : exp RELATIONAL exp {
            char * s = cat($1->code, $2, $3->code, "", "");
            $$ = createRecord(s, "", "");
            freeRecord($1);
            freeRecord($3);
            free($2);
            free(s);
          }
          | exp AND exp
          | exp AND_THEN exp
          | exp OR exp
          | exp OR_ELSE exp
          | exp XOR exp
          | NOT exp
          ;

exp_arith : exp '+' exp {
                char * s = cat($1->code, " + ", $3->code, "", "");
                // TODO: Typewise
                $$ = createRecord(s, $1->type, "");
                freeRecord($1);
                freeRecord($3);
                free(s);
          }
          | exp '-' exp {
                char * s = cat($1->code, " - ", $3->code, "", "");
                // TODO: Typewise
                $$ = createRecord(s, $1->type, "");
                freeRecord($1);
                freeRecord($3);
                free(s);
          }
          | exp '*' exp
          | exp '/' exp
          | exp '%' exp
          | exp '^' exp {
                char * s = cat("pow(", $1->code, ", ", $3->code, ")");
                // TODO: Typewise
                $$ = createRecord(s, $1->type, "");
                freeRecord($1);
                freeRecord($3);
                free(s);
          }
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

exp : exp_literal {$$ = $1;}
    | ID {
        undeclared_error($1);
        $$ = createRecord($1, retrieve_ht($1), "");
        free($1);
    }
    | ID '.' ID
    | ID '[' exp ']'
    | '@' ID
    | ID exp_func_args
    | exp_array_list
    | exp_logic {$$ = $1;}
    | exp_arith
    | exp_lazy '(' exp_arith ')'
    | '(' exp ')' {
        char * s = cat("(", $2->code, ")", "", "");
        $$ = createRecord(s, $2->type, "");
        freeRecord($2);
        free(s);
    }
    | '-' exp {
        char * s = cat("-", $2->code, "", "", "");
        $$ = createRecord(s, "", "");
        freeRecord($2);
        free(s);
    }
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
assign : ID '=' exp {
            undeclared_error($1);
            type_error(retrieve_ht($1), $3->type);
            char * s = cat($1, " = ", $3->code, "", "");
            $$ = createRecord(s, "", "");
            freeRecord($3);
            free($1);
            free(s);
       }
       | ID '.' ID '=' exp
       | ID '[' exp ']' '=' exp
       | '@' ID '=' exp
       ;
       
stm : assign {$$ = $1;}
    | if_stmts {}
    | switch_stmts {$$ = $1;}
    | while_stmts {$$ = $1;}
    | for_stm {}
    | do_stm {}
    | declar {$$ = $1;}
    | expect_stm {}
    | try_stm {}
    | proc_stm {}
    | func_stm {}
    | CALL ID exp_func_args {}
    | CONTINUE {}
    | BREAK {$$ = createRecord("break", "", "");}
    | THROW exp {}
    | RETURN exp {}
    | assign_op_stm {}
    | INPUT ID {
        undeclared_error($2);
        char * markup = "\%s";
        char * prefix_input = "&";
        char * _type = retrieve_ht($2);

        if (strcmp(_type, "TEXT") == 0) {
            prefix_input = "";
        } else if (strcmp(_type, "INTEGER") == 0) {
            markup = "\%d";
        } else if (strcmp(_type, "CHARACTER") == 0) {
            markup = "\%c";
        } else if (strcmp(_type, "REAL") == 0) {
            markup = "\%f";
        } else if (strcmp(_type, "DECIMAL") == 0) {
            markup = "\%lf";
        }

        char * s1 = cat("scanf(\"", markup, "\", ", prefix_input, $2);
        char * s = cat(s1, ")", "", "", "");
        $$ = createRecord(s, "", "");
        free($2);
        free(s1);
        free(s);
    }
    | OUTPUT exp {
        char * markup = "\%s";

        if (strcmp($2->type, "INTEGER") == 0) {
            markup = "\%d";
        } else if (strcmp($2->type, "CHARACTER") == 0) {
            markup = "\%c";
        } else if (strcmp($2->type, "REAL") == 0 || strcmp($2->type, "DECIMAL") == 0) {
            markup = "\%.2f";
        }
        char * s = cat("printf(\"", markup ,"\\n\", ", $2->code, ")");
        $$ = createRecord(s, $2->code, "");
        freeRecord($2);
        free(s);
    }
    ;

stmlist : stm ';' {
        char * s = cat($1->code, ";\n", "", "", "");
        $$ = createRecord(s, "", "");
        freeRecord($1);
        free(s);
    }
	| stm ';' stmlist {
        char * s = cat($1->code, ";\n", $3->code, "", "");
        $$ = createRecord(s, "", "");
        freeRecord($1);
        freeRecord($3);
        free(s);
    }
	;

/// END-STMS
%%

int main(int argc, char ** argv) {
 	int codigo;

    if (argc != 3) {
       printf("Usage: $./compiler input.txt output.txt\nClosing application...\n");
       exit(0);
    }
    
    yyin = fopen(argv[1], "r");
    yyout = fopen(argv[2], "w");

    codigo = yyparse();

    fclose(yyin);
    fclose(yyout);

    free_ht();

	return codigo;
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}

void undeclared_error(char * s) {
    if (!retrieve_ht(s)) {
        char * out = cat(s, " undeclared!", "", "", "");
        yyerror(out);
    }
}

void already_declared_error(char * s) {
    if (retrieve_ht(s)) {
        char * out = cat(s, " already declared!", "", "", "");
        yyerror(out);
    }
}

void type_error(char * t1, char * t2) {
    if (strcmp(t1, t2) != 0 && !(strcmp(t1, "") == 0 || strcmp(t2, "") == 0)) {
        char * s = cat("[Type error] ", t1, " and ", t2, " are incompatible.");
        yyerror(s);
        free(s);
    }
}

char * cat(char * s1, char * s2, char * s3, char * s4, char * s5) {
  int tam;
  char * output;

  tam = strlen(s1) + strlen(s2) + strlen(s3) + strlen(s4) + strlen(s5)+ 1;
  output = (char *) malloc(sizeof(char) * tam);
  
  if (!output){
    printf("Allocation problem. Closing application...\n");
    exit(0);
  }
  
  sprintf(output, "%s%s%s%s%s", s1, s2, s3, s4, s5);
  
  return output;
}