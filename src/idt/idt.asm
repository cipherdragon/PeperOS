section .asm

extern int_21h_handler
extern int_0h_handler
extern nointerrupt_handler

global idt_load
global int_21h
global int_0h
global no_interrupt

global enable_interrupts
global disable_interrrupts

enable_interrupts:
	sti
	ret

disable_interrrupts:
	cli
	ret

idt_load:
	push ebp
	mov ebp, esp

	mov ebx, [ebp+8]
	lidt [ebx]

	pop ebp
	ret

int_0h:
	cli
	pushad
	
	call int_0h_handler

	popad
	sti
	iret

int_21h:
	cli
	pushad
	
	call int_21h_handler

	popad
	sti
	iret

no_interrupt:
	cli
	pushad

	call nointerrupt_handler

	popad
	sti
	iret