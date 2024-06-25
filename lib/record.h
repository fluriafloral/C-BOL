#ifndef RECORD
#define RECORD

#define MAX_VARS_RECORD 331

struct record_var
{
	char * name;
	int kind_of_use; // 0 - declaration 1 - using
	char * initial_value;
	char * type;
};

typedef struct record_var record_var;

struct record
{
	char *code; /* field for storing the output code */
	char *type; /* field for storing the type */
	char *opt1; /* field for storing the ids */
	int num_vars_used;
	record_var ** vars;
};

typedef struct record record;

void push_var(record *, record_var *);
void freeRecord(record *);
void dup_vars(record *, int, record_var **);
record *createRecord(record_var **, int, char *, char *, char *);
record_var *createVar(char *, int, char *, char *);

#endif