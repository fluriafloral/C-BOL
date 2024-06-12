#ifndef HASHTB_H
#define HASHTB_H

#define MAX_SIZE 5327

struct HashEntry
{
    char * key;
    char * value;
};

unsigned long djb2_hash(unsigned char *str);
int hash_function(char * key);
void insert(char * key, char * value);
char * retrieve(char * key);

#endif // HASHTB_H
