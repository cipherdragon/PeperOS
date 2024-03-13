#include "memory.h"

void* memset(void* ptr, int c, size_t num) {
    char* char_ptr = (char*) ptr;
    for (size_t i = 0; i < num; i++) {
        char_ptr[i] = (char) c;
    }

    return ptr;
}