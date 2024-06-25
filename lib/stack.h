#ifndef STACK_H
#define STACK_H
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_VAR_NAME 256
#define MAX_TYPE_NAME 100

typedef struct Variable {
    char name[MAX_VAR_NAME];
    char type[MAX_TYPE_NAME];
    char* initial_value;
} Variable;

typedef struct StackFrame {
    char scope_name[MAX_VAR_NAME];
    Variable* variables;
    int var_count;
    struct StackFrame* next;
} StackFrame;

StackFrame * get_stack();
void push_frame(const char* scope_name);

void pop_frame();

void add_variable(const char* var_name, const char* var_type, const char* initial_value);

Variable* find_variable(const char* var_name);


#endif