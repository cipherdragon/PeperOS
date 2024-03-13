#include <stddef.h>
#include <stdint.h>

#include "kernel.h"
#include "idt/idt.h"
#include "io/io.h"

uint16_t* video_memory;
uint16_t seek_position;

void terminal_initialize() {
    video_memory = (uint16_t*) 0xb8000;
    seek_position = 0;

    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        video_memory[i] = make_char(' ', 0);
    }
}

void kernel_main() {
    terminal_initialize();
    
    // Note about endianness: x86 is little-endian, so the least significant byte
    // is stored first. That's why even though we write 'H' first, it appears on
    // the right and 9 appears on the left.
    // video_memory[0] = 'H' | 9 << 8; 

    print("Hello, world!\n");

    // Initialize interrupt descriptor table
    idt_init();
}

size_t strlen(const char* str) {
    size_t len = 0;
    while (str[len]) {
        len++;
    }
    return len;
}

uint16_t make_char(char c, char color) {
    return c | color << 8;
}

void terminal_putchar(int x, int y, char c, char color) {
    video_memory[y * VGA_WIDTH + x] = make_char(c, color);
}

void scroll_line() {
    // Shift all lines by one line up
    for (int y = 1; y < VGA_HEIGHT; y++) {
        for (int x = 0; x < VGA_WIDTH; x++) {
            video_memory[(y - 1) * VGA_WIDTH + x] = video_memory[y * VGA_WIDTH + x];
        }
    }

    // Clear the last line
    for (int x = 0; x < VGA_WIDTH; x++) {
        video_memory[(VGA_HEIGHT - 1) * VGA_WIDTH + x] = make_char(' ', 0);
    }

}

void terminal_writechar(char c, char color) {
    if (c == '\n') {
        seek_position += VGA_WIDTH - seek_position % VGA_WIDTH;
        if (seek_position >= VGA_WIDTH * VGA_HEIGHT) {
            scroll_line();
            seek_position -= VGA_WIDTH;
        }
        return;
    }

    video_memory[seek_position] = make_char(c, color);
    seek_position++;

    if (seek_position >= VGA_WIDTH * VGA_HEIGHT) {
        scroll_line();
        seek_position -= VGA_WIDTH;
    }
}

void terminal_write(const char* str, char color) {
    size_t i = 0;
    while (str[i]) {
        terminal_writechar(str[i], color);
        i++;
    }
}

void print(const char* str) {
    terminal_write(str, 0x0f);
}