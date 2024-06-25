#include "stack.h"
#include <stdio.h>

StackFrame* stack = NULL;

StackFrame* get_stack() {
    return stack;
}

void push_frame(const char* scope_name) {
    StackFrame* frame = (StackFrame*)malloc(sizeof(StackFrame));
    strcpy(frame->scope_name, scope_name);
    frame->variables = NULL;
    frame->var_count = 0;
    frame->next = stack;
    stack = frame;
}

void pop_frame() {
    if (stack != NULL) {
        StackFrame* temp = stack;
        stack = stack->next;
        free(temp->variables);
        free(temp);
    }
}

void add_variable(const char* var_name, const char* var_type, const char* initial_value) {
    if (stack != NULL) {
        stack->var_count++;
        stack->variables = (Variable*)realloc(stack->variables, stack->var_count * sizeof(Variable));
        strcpy(stack->variables[stack->var_count - 1].name, var_name);
        strcpy(stack->variables[stack->var_count - 1].type, var_type);
        stack->variables[stack->var_count - 1].initial_value = initial_value ? strdup(initial_value) : NULL;
    }
}

Variable* find_variable(const char* var_name) {
    StackFrame* frame = stack;
    while (frame != NULL) {
        for (int i = 0; i < frame->var_count; i++) {
            if (strcmp(frame->variables[i].name, var_name) == 0) {
                return &frame->variables[i];
            }
        }
        frame = frame->next;
    }
    return NULL;
}