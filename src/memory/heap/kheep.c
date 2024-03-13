#include "kheep.h"
#include "heap.h"
#include "config.h"

struct heap kernel_heap;
struct heap_table kernel_heap_table;

void kheep_init() {
    int total_table_entries = KERNEL_HEAP_SIZE / KERNEL_HEAP_BLOCK_SIZE;
    
    kernel_heap_table.entries = (void*) 0x00;
    kernel_heap_table.total = total_table_entries;
}