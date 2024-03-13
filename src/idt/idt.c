#include "idt.h"
#include "config.h"
#include "memory/memory.h"
#include "kernel.h"
#include "io/io.h"

struct idt_desc idt_descriptors[PEPER_OS_TOTAL_INTERRUPTS];
struct idtr_desc idtr_descriptor;

extern void idt_load(struct idtr_desc* ptr);
extern void int_21h();
extern void int_0h();
extern void no_interrupt();
extern void problem();

void nointerrupt_handler() {
	outb(0x20, 0x20);
}

void int_21h_handler() {
	print("Keyboard pressed!\n");
	outb(0x20, 0x20);
}

void int_0h_handler() {
    print("Divide by zero error\n");
}

void idt_set(int interrupt_num, void* address) {
    struct idt_desc* descriptor = &idt_descriptors[interrupt_num];
    descriptor->offset_1 = (uint32_t) address & 0x0000FFFF; // mask higher 16 bits and keep only lower 16 bits
    descriptor->selector = KERNEL_CODE_SELECTOR;
    descriptor->zero = 0;
    descriptor->type_attr = 0xEE; // 11101110b
    descriptor->offset_2 = (uint32_t) address >> 16; // shift right 16 bits
}

void idt_init() {
    memset(idt_descriptors, 0, sizeof(idt_descriptors));
    idtr_descriptor.limit = sizeof(idt_descriptors) - 1;
    idtr_descriptor.base = (uint32_t) idt_descriptors;

	for (int i = 0; i < PEPER_OS_TOTAL_INTERRUPTS; i++) {
		idt_set(i, no_interrupt);
	}

    idt_set(0, int_0h);
    idt_set(0x21, int_21h);
    idt_set(0x20, int_21h);

    // Load the IDT
    idt_load(&idtr_descriptor);

	enable_interrupts();
}
