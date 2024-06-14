#ifndef RECORD
#define RECORD

struct record
{
	char *code; /* field for storing the output code */
	char *type; /* field for storing the type */
	char *opt1; /* field for storing the ids */
};

typedef struct record record;

void freeRecord(record *);
record *createRecord(char *, char *, char *);

#endif