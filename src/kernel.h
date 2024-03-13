#ifndef KERNEL_H
#define KERNEL_H

#define VGA_WIDTH 80
#define VGA_HEIGHT 20

void kernel_main();
uint16_t make_char(char c, char color);
size_t strlen(const char* str);
void terminal_putchar(int x, int y, char c, char color);
void terminal_write(const char* str, char color);
void terminal_writechar(char c, char color);
void print(const char* str);

#endif // KERNEL_H