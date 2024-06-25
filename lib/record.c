#include "record.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void freeRecord(record *r)
{
  if (r)
  {
    if (r->code != NULL)
      free(r->code);
    if (r->type != NULL)
      free(r->type);
    if (r->opt1 != NULL)
      free(r->opt1);

    for (int i = 0; i < MAX_VARS_RECORD; ++i)
    {
      free(r->vars[i]);
    }

    r->num_vars_used = 0;
    free(r);
  }
}

void push_var(record *r, record_var *var)
{
  if (r->num_vars_used == MAX_VARS_RECORD)
  {
    printf("You have used all vars! Sorry. Closing application BOOM...\n");
    exit(0);
  }

  r->vars[r->num_vars_used] = var;
  r->num_vars_used = r->num_vars_used + 1;
}

void dup_vars(record * r, int i_num_vars, record_var ** i_vars) {
  for (int i = 0; i < i_num_vars; ++i) {
    record_var * i_var = i_vars[i];
    record_var * cp_var = createVar(i_var->name, i_var->kind_of_use, i_var->initial_value, i_var->type);
    push_var(r, cp_var);
  }
}

record *createRecord(record_var ** i_vars, int i_num_vars, char *c1, char *c2, char *c3)
{
  record *r = (record *)malloc(sizeof(record));

  if (!r)
  {
    printf("Allocation problem. Closing application...\n");
    exit(0);
  }

  r->code = strdup(c1);
  r->type = strdup(c2);
  r->opt1 = strdup(c3);
  r->num_vars_used = 0;
  r->vars = (record_var **)malloc(MAX_VARS_RECORD * sizeof(record_var));
  dup_vars(r, i_num_vars, i_vars);
  return r;
}

record_var *createVar(char *name, int kind_of_use, char *initial_value, char *type)
{
  record_var *v = (record_var *)malloc(sizeof(record_var));

  if (!v)
  {
    printf("Allocation problem. Closing application...\n");
    exit(0);
  }

  v->name = strdup(name);
  v->kind_of_use = kind_of_use;
  v->initial_value = strdup(initial_value);
  v->type = strdup(type);
  return v;
}