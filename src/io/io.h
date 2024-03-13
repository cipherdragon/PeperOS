#ifndef IO_H
#define IO_H

unsigned char insb(unsigned short port); // read byte
unsigned short insw(unsigned short port); // read word

void outb(unsigned short port, unsigned char value); // write byte
void outw(unsigned short port, unsigned short value); // write word

#endif // IO_H