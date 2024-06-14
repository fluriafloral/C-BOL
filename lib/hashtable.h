#ifndef HASHTB_H
#define HASHTB_H

#define MAX_SIZE 5327

#include <string.h>
#include <stdlib.h>

struct HashEntry
{
    char *key;
    char *value;
};

unsigned long djb2_hash(unsigned char *str);
int hash_function(char *key);
void insert_ht(char *key, char *value);
char *retrieve_ht(char *key);
void free_ht();

#endif // HASHTB_H
