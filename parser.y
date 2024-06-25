%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "./lib/hashtable.h"
#include "./lib/record.h"
#include "./lib/stack.h"


int yylex(void);
void push();
int yyerror(char *s);
void already_declared_error(char *s);
void undeclared_error(char *s);
void type_error(char *t1, char*t2);
void check_variable(const char* var_name);
void vars_routine(record * r);
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
%token TRY END_TRY CATCH THROW FINALLY EXPECT SIZE
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
%type <rec> declar_enum declar_struct proc_arg_dims exp_size expect_stm for_stm for_var_init assign_op_stm

%%
prog : {push_frame("main");} funcs_procs_declars PROGRAM stmlist END_PROGRAM ';' {
        vars_routine($4);
        char * includes = "#include <stdio.h>\n#include <math.h>\n";
        fprintf(yyout, "%s\n%s\nint main() {\n%s\nreturn 0;\n}\n", includes, $2->code, $4->code);
        freeRecord($2);
        freeRecord($4);
        pop_frame();
     }
     ;

funcs_procs_declars : func_stm ';' funcs_procs_declars {
                        char * s = cat($1->code, $3->code, "", "", "");
                        record * r = createRecord(NULL, 0, s, "", "");
                        dup_vars(r, $1->num_vars_used, $1->vars);
                        dup_vars(r, $3->num_vars_used, $3->vars);
                        $$ = r;
                        freeRecord($1);
                        freeRecord($3);
                        free(s);
                    }
                    | proc_stm ';' funcs_procs_declars {
                        char * s = cat($1->code, $3->code, "", "", "");
                        $$ = createRecord(NULL, 0, s, "", "");
                        freeRecord($1);
                        freeRecord($3);
                        free(s);
                    }
                    | declar_enum ';' funcs_procs_declars {
                        char * s = cat($1->code, ";", $3->code, "", "");
                        $$ = createRecord(NULL, 0, s, "", "");
                        freeRecord($1);
                        freeRecord($3);
                        free(s);
                    }
                    | declar_struct ';' funcs_procs_declars {
                        char * s = cat($1->code, ";", $3->code, "", "");
                        $$ = createRecord(NULL, 0, s, "", "");
                        freeRecord($1);
                        freeRecord($3);
                        free(s);
                    }
                    | {$$ = createRecord(NULL, 0, "", "", "");}
                ;

/// TYPES
type : P_TYPE {
        if (strcmp($1, "UNIT") == 0) {
            $$ = createRecord(NULL, 0, "void ", $1, "");
        } else if (strcmp($1, "EMPTY") == 0) {
            yyerror("Whatahell?!");
            $$ = createRecord(NULL, 0, "", "", "");
        } else if (strcmp($1, "INTEGER") == 0) {
            $$ = createRecord(NULL, 0, "int ", $1, "");
        } else if (strcmp($1, "REAL") == 0) {
            $$ = createRecord(NULL, 0, "float ", $1, "");
        } else if (strcmp($1, "DECIMAL") == 0) {
            $$ = createRecord(NULL, 0, "double ", $1, "");
        } else if (strcmp($1, "CHARACTER") == 0) {
            $$ = createRecord(NULL, 0, "char ", $1, "");
        } else if (strcmp($1, "TEXT") == 0) {
            $$ = createRecord(NULL, 0, "char * ", $1, "");
        }
        free($1);
     }
     | LARGE P_TYPE {
        char * s = cat("long ", $2, "", "", "");
        // TODO: Not all types are longable
        $$ = createRecord(NULL, 0, s, $2, "");
        free($2);
        free(s);
     }
     | ID {
        $$ = createRecord(NULL, 0, $1, $1, "");
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
                     | {$$ = createRecord(NULL, 0, "", "", "");}
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
                    record * r = createRecord(NULL, 0, s, "", "");
                    dup_vars(r, $2->num_vars_used, $2->vars);
                    dup_vars(r, $4->num_vars_used, $4->vars);
                    dup_vars(r, $6->num_vars_used, $6->vars);
                    $$ = r;
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
                record * r = createRecord(NULL, 0, s, "", "");
                dup_vars(r, $1->num_vars_used, $1->vars);
                dup_vars(r, $2->num_vars_used, $2->vars);
                $$ = r;
                freeRecord($1);
                freeRecord($2);
                free(s);
            }
            | CASE OTHER ':' stmlist
            ;
        
switch_stmts : SWITCH exp switch_case END_SWITCH {
                char * s = cat("switch (", $2->code, ") {\n", $3->code, "\n}");
                record * r = createRecord(NULL, 0, s, "", "");
                dup_vars(r, $2->num_vars_used, $2->vars);
                dup_vars(r, $3->num_vars_used, $3->vars);
                $$ = r;
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
                record * r = createRecord(NULL, 0, s, "", "");
                dup_vars(r, $2->num_vars_used, $2->vars);
                dup_vars(r, $3->num_vars_used, $3->vars);
                $$ = r;
                freeRecord($2);
                freeRecord($3);
                free(s);
            }
            ;

for_var_init : type assign {
                char * s = cat($1->code, $2->code, "", "", "");
                $$ = createRecord(NULL, 0, s, $1->type, $2->opt1);
                freeRecord($1);
                freeRecord($2);
                free(s);
             }
             | assign {
                $$ = $1;
             } 
             ;

for_stm : FOR '(' for_var_init ';' exp ';' stm ')' stmlist END_FOR {
            unsigned long loop_id = (unsigned long) &$5;
            char loop_id_str[21];

            snprintf(loop_id_str, sizeof(loop_id_str), "%lu", loop_id);

            char * opts = cat($3->opt1, ",", $5->opt1, ",", $9->opt1);
            char * s = cat("for", loop_id_str, ":\n", $9->code, $7->code);
            s = cat("\nif(", $5->code, ")\ngoto for", loop_id_str, "");
            $$ = createRecord(NULL, 0, s, "", opts);

            freeRecord($3);
            freeRecord($5);
            freeRecord($7);
            freeRecord($9);
            free(opts);
            free(s);
        }
        | FOR '(' type ID ':' ID ')' stmlist END_FOR
        ;

do_stm : DO stmlist THEN WHILE exp
       ;

/// END-LOOPS




/// EXCEPTIONS
expect_stm : EXPECT '(' exp_logic ')' ELSE TEXT {
                char * s = cat("if(!(", $3->code, ")) {\nprintf(", $6, ");\n");
                s = cat(s, "break;\n}", "", "", "");
                $$ = createRecord(NULL, 0, s, "", $3->opt1);
           }
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
proc_arg_dims :         {$$ = createRecord(NULL, 0, "", "", "");}
              | '[' ']' proc_arg_dims {
                char * s = cat("[]", $3-> code, "", "" ,"");

                $$ = createRecord(NULL, 0, s, "", "");

                freeRecord($3);
                free(s);
              }

proc_arg_typado : type ID {
                    char * s = cat($1->code, $2, "", "", "");
                    record * r = createRecord(NULL, 0, s, $1->type, "");
                    record_var * r_var = createVar($2, 0, "", $1->type);
                    push_var(r, r_var);
                    $$ = r;
                    freeRecord($1);
                    free($2);
                    free(s);
                }
                | type '@' ID 
                | type ID '[' ']' proc_arg_dims {
                    char * s = cat($1->code, $2, "[]", $5->code, "");
                    char * opt = cat($1->type, "#", $2, "", "");
                    $$ = createRecord(NULL, 0, s, $1->type, opt);
                    freeRecord($1);
                    free($2);
                    free(s);
                    free(opt);
                }
                ;

proc_args : proc_arg_typado {$$ = $1;}
          | proc_arg_typado ',' proc_args {
                char * s = cat($1->code, ", " , $3->code, "", "");
                char * opts = cat($1->opt1, ",", $3->opt1, "", "");
                record * r = createRecord(NULL, 0, s, "", opts);
                dup_vars(r, $1->num_vars_used, $1->vars);
                dup_vars(r, $3->num_vars_used, $3->vars);
                $$ = r;
                freeRecord($1);
                freeRecord($3);
                free(s);
                free(opts);
          }
          | type assign
          ;
          
proc_params : '(' proc_args ')' {
                char * s = cat("(", $2->code, ")", "", "");
                $$ = createRecord($2->vars, $2->num_vars_used, s, "", $2->opt1);
                vars_routine($2);
                freeRecord($2);
                free(s);
            }
            | UNIT {
                $$ = createRecord(NULL, 0, "()", "", "");
            }
            ;

proc_stm : PROCEDURE ID proc_params stmlist END_PROCEDURE {
            char *argt, *t, *i;
            argt = strtok($3->opt1, ",");
            while (argt != NULL) {
                t = strtok(argt, "#");
                i = strtok(NULL, "#");

                printf("%s\n", argt);
                add_variable(i, t, "");
                insert_ht(i, t);
                argt = strtok(NULL, ",");
            }

            char * vars = strtok($4->opt1, ",");
            while(vars != NULL) {
                undeclared_error(vars);
                vars = strtok(NULL, ",");
            }
            free(argt);
            free(t);
            free(i);
            free(vars);

            char * s = cat("void ", $2, $3->code, "{\n", $4->code);
            s = cat(s, "}\n", "", "", "");

            $$ = createRecord(NULL, 0, s, "", "");

            freeRecord($3);
            freeRecord($4);
            free($2);
            free(argt);
            free(s);
            pop_frame();
         }
         ;
/// END-PROCEDURE





/// FUNCTIONS
func_return_dims :                          {$$ = createRecord(NULL, 0, "", "", "");}
                 | '[' ']' func_return_dims {
                    char * s = cat("*", $3->code, "", "", "");

                    $$ = createRecord(NULL, 0, s, "", "");

                    freeRecord($3);
                    free(s);
                }

func_stm : FUNCTION type func_return_dims ID { push_frame($4); } proc_params stmlist END_FUNCTION {
            vars_routine($7);
            char * s = cat($2->code, $3->code, $4, $6->code, " {\n");
            s = cat(s, $7->code, "\n}\n", "", "");

            record * r = createRecord(NULL, 0, s, $2->type, $4);
            dup_vars(r, $6->num_vars_used, $6->vars);
            dup_vars(r, $7->num_vars_used, $7->vars);
            $$ = r;

            freeRecord($2);
            freeRecord($3);
            freeRecord($6);
            freeRecord($7);
            free($4);
            free(s);
            pop_frame();
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

declar_array_dimensions :                                     {$$ = createRecord(NULL, 0, "", "", "");}
                        | '[' exp ']' declar_array_dimensions {
                            char * s = cat("[", $2->code, "]", $4->code, "");
                            $$ = createRecord(NULL, 0, s, "", "");
                            freeRecord($2);
                            freeRecord($4);
                            free(s);
                        }
                        ;

declar_var : ID {
                //already_declared_error($1);
                record * r = createRecord(NULL, 0, $1, "", $1);
                push_var(r, createVar($1, 0, "", ""));
                $$ = r;
                free($1);
           }
           | ID '=' exp {
                //already_declared_error($1);
                char * s = cat($1, "=", $3->code, "", "");
                record * r = createRecord(NULL, 0, s, $3->type, $1);
                push_var(r, createVar($1, 0, $3->code, $3->type));
                dup_vars(r, $3->num_vars_used, $3->vars);
                $$ = r;
                freeRecord($3);
                free($1);
                free(s);
           }
           | '@' ID {
                //already_declared_error($2);
                char * s = cat("*", $2, "", "", "");
                $$ = createRecord(NULL, 0, s, "", $2);
                free($2);
                free(s);
           }
           | ID '[' exp ']' declar_array_dimensions {
                //already_declared_error($2);
                char * s = cat($1, "[", $3->code, "]", $5->code);
                $$ = createRecord(NULL, 0, s, "", $1);
                freeRecord($3);
                freeRecord($5);
                free($1);
           }
           | ID '[' exp ']' declar_array_dimensions '=' exp
           ;

declar_vars : declar_var {$$ = $1;}
            | declar_var ',' declar_vars {
                char * s = cat($1->code, ",", $3->code, "", "");
                record * r = createRecord(NULL, 0, s, $1->type, "");
                dup_vars(r, $1->num_vars_used, $1->vars);
                dup_vars(r, $3->num_vars_used, $3->vars);
                $$ = r;
                freeRecord($1);
                freeRecord($3);
                free(s);
            }
            ;

declar : type declar_vars {
            char * s = cat($1->code, $2->code, "", "", "");
            $$ = createRecord($2->vars, $2->num_vars_used, s, "", $2->opt1);
            freeRecord($1);
            freeRecord($2);
            free(s);
       }
       | CONST type ID '=' exp
       | declar_struct
       | declar_enum
       ;

/// END-DECLARATIONS





/// EXPRESSIONS
exp_literal : UNIT {
                $$ = createRecord(NULL, 0, "()", "UNIT", "");
                free($1);
          }
          | INTEGER {
                $$ = createRecord(NULL, 0, $1, "INTEGER", "");
                free($1);
          }
          | REAL {
                $1[strlen($1) - 1] = 'f';
                $$ = createRecord(NULL, 0, $1, "REAL", "");
                free($1);
          }
          | DECIMAL {
                $$ = createRecord(NULL, 0, $1, "DECIMAL", "");
                free($1);
          }
          | CHARACTER {
                $$ = createRecord(NULL, 0, $1, "CHARACTER", "");
                free($1);
          }
          | TEXT {
                $$ = createRecord(NULL, 0, $1, "TEXT", "");
                free($1);
          }
          ;

exp_logic : exp RELATIONAL exp {
            char * opts = cat($1->opt1, ",", $3->opt1, "", "");
            char * s = cat($1->code, $2, $3->code, "", "");
            $$ = createRecord(NULL, 0, s, "", opts);
            freeRecord($1);
            freeRecord($3);
            free($2);
            free(s);
            free(opts);
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
                record * r = createRecord(NULL, 0, s, $1->type, "");
                dup_vars(r, $1->num_vars_used, $1->vars);
                dup_vars(r, $3->num_vars_used, $3->vars);
                $$ = r;
                freeRecord($1);
                freeRecord($3);
                free(s);
          }
          | exp '-' exp {
                char * s = cat($1->code, " - ", $3->code, "", "");
                // TODO: Typewise
                record * r = createRecord(NULL, 0, s, $1->type, "");
                dup_vars(r, $1->num_vars_used, $1->vars);
                dup_vars(r, $3->num_vars_used, $3->vars);
                $$ = r;
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
                record * r = createRecord(NULL, 0, s, $1->type, "");
                dup_vars(r, $1->num_vars_used, $1->vars);
                dup_vars(r, $3->num_vars_used, $3->vars);
                $$ = r;
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

exp_size : SIZE '(' ID ')'                                 {
            char * s = cat("sizeof(", $3, ")", "", "");
            $$ = createRecord(NULL, 0, s, "", $3);
            free($3);
            free(s);
         } 
         | SIZE '(' ID '[' exp ']' declar_array_dimensions ')' {
            char * opts = cat($3, ",", $5->opt1, ",", $7->opt1);
            char * s = cat("sizeof(", $3, "[", $5->code, "]");
            s = cat(s, $7->code, ")", "", "");
            $$ = createRecord(NULL, 0, s, "", opts);
            freeRecord($5);
            freeRecord($7);
            free($3);
            free(opts);
            free(s);
         } 
         ;

exp : exp_literal {$$ = $1;}
    | ID {
        record * r = createRecord(NULL, 0, $1, "", "");
        record_var * r_var = createVar($1, 1, "", "");
        push_var(r, r_var);
        $$ = r;
        free($1);
    }
    | ID '.' ID
    | ID '[' exp ']' declar_array_dimensions {
        char * opts = cat($1, ",", $3->opt1, ",", $5->opt1);
        char * s = cat($1, "[", $3->code, "]", $5->code);
        $$ = createRecord(NULL, 0, s, "", opts);
        freeRecord($3);
        freeRecord($5);
        free($1);
        free(opts);
        free(s);
    }
    | '@' ID
    | ID exp_func_args
    | exp_array_list
    | exp_size
    | exp_logic {$$ = $1;}
    | exp_arith
    | exp_lazy '(' exp_arith ')'
    | '(' exp ')' {
        char * s = cat("(", $2->code, ")", "", "");
        record * r = createRecord(NULL, 0, s, $2->type, $2->opt1);
        dup_vars(r, $2->num_vars_used, $2->vars);
        $$ = r;
        freeRecord($2);
        free(s);
    }
    | '-' exp {
        char * s = cat("-", $2->code, "", "", "");
        $$ = createRecord(NULL, 0, s, "", "");
        freeRecord($2);
        free(s);
    }
    ;
/// END-EXPRESSIONS





/// ASSIGN-OP
assign_op_stm : ID '+' '=' exp {
                char * opts = cat($1, ",", $4->opt1, "", "");
                char * s = cat($1, " += ", $4->code, "", "");
                $$ = createRecord(NULL, 0, s, "", opts);
                freeRecord($4);
                free($1);
                free(opts);
                free(s);
              }
              | ID '-' '=' exp
              | ID '*' '=' exp
              | ID '/' '=' exp
              | ID '%' '=' exp
              | ID '^' '=' exp
              ;
/// END-ASSIGN-OP





/// STMS
assign : ID '=' exp {
            char * opts = cat($1, ",", $3->opt1, "", "");
            char * s = cat($1, " = ", $3->code, "", "");
            record * r = createRecord(NULL, 0, s, $3->type, opts);
            push_var(r, createVar($1, 1, $3->code, ""));
            $$ = r;
            freeRecord($3);
            free($1);
            free(opts);
            free(s);
       }
       | ID '.' ID '=' exp
       | ID '[' exp ']' declar_array_dimensions '=' exp {
            char * opts = cat($1, ",", $3->opt1, ",", $5->opt1);
            opts = cat(opts, ",", $7->opt1, "", "");
            char * s = cat($1, "[", $3->code, "]", $5->code);
            s = cat(s, "=", $7->code, "", "");
            $$ = createRecord(NULL, 0, s, "", opts);
            freeRecord($3);
            freeRecord($5);
            freeRecord($7);
            free($1);
            free(opts);
            free(s);
       }
       | '@' ID '=' exp
       ;
       
stm : assign {$$ = $1;}
    | if_stmts {}
    | switch_stmts {$$ = $1;}
    | while_stmts {$$ = $1;}
    | for_stm {$$ = $1;}
    | do_stm {}
    | declar {$$ = $1;}
    | expect_stm {$$ = $1;}
    | try_stm {}
    | proc_stm {$$ = $1;}
    | func_stm {$$ = $1;}
    | CALL ID exp_func_args {}
    | CONTINUE {}
    | BREAK {$$ = createRecord(NULL, 0, "break", "", "");}
    | THROW exp {}
    | RETURN exp {
        char * s = cat("return ", $2->code, "", "", "");
        $$ = createRecord($2->vars, $2->num_vars_used, s, "", $2->opt1);
        freeRecord($2);
        free(s);
    }
    | assign_op_stm {$$ = $1;}
    | INPUT ID {
        char * s1 = cat("scanf(\"", "%s", "\", ", "", $2);
        char * s = cat(s1, ")", "", "", "");
        record * r = createRecord(NULL, 0, s, "", "");
        push_var(r, createVar($2, 1, "", ""));
        $$ = r;
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
        $$ = createRecord(NULL, 0, s, $2->code, "");
        freeRecord($2);
        free(s);
    }
    ;

stmlist : stm ';' {
        char * s = cat($1->code, ";\n", "", "", "");
        $$ = createRecord($1->vars, $1->num_vars_used, s, "", $1->opt1);
        freeRecord($1);
        free(s);
    }
	| stm ';' stmlist {
        char * opts = cat($1->opt1, ",", $3->opt1, "", "");
        char * s = cat($1->code, ";\n", $3->code, "", "");
        record * r = createRecord(NULL, 0, s, "", opts);
        dup_vars(r, $1->num_vars_used, $1->vars);
        dup_vars(r, $3->num_vars_used, $3->vars);
        $$ = r;
        freeRecord($1);
        freeRecord($3);
        free(opts);
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
    if (find_variable(s) == NULL) {
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

void check_variable(const char* var_name) {
    if (find_variable(var_name) == NULL) {
        printf("Error: Variable '%s' not found\n", var_name);
        exit(1);
    }
}

void vars_routine(record  * r) {
    for (int i = 0; i < r->num_vars_used; ++i) {
        int is_declar = r->vars[i]->kind_of_use == 0;
        if (is_declar) {
            add_variable(r->vars[i]->name, r->vars[i]->type, r->vars[i]->initial_value);
        } else {
            undeclared_error(r->vars[i]->name);
        }
        /* printf("%s tem agr: %d vars\n", get_stack()->scope_name, get_stack()->var_count); */
    }
}