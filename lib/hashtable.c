#include "hashtable.h"

struct HashEntry hashtable[MAX_SIZE];

unsigned long djb2_hash(unsigned char *str)
{
    unsigned long hash = 5381;
    int c;

    while ((c = *str++))
    {
        hash = ((hash << 5) + hash) + c; // hash * 33 + c
    }

    return hash;
}

int hash_function(char *key)
{
    return djb2_hash(key) % MAX_SIZE;
}

void free_ht() {
    int i = 0;
    while(i < MAX_SIZE) {
        free(hashtable[i].key);
        free(hashtable[i].value);
        ++i;
    }
}

void insert_ht(char *key, char *value)
{
    int index = hash_function(key);
    hashtable[index].key = strdup(key);
    hashtable[index].value = strdup(value);
}

char *retrieve_ht(char *key)
{
    int index = hash_function(key);
    return hashtable[index].value;
}
