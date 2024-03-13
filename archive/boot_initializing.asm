ORG 0
BITS 16

_start:
	jmp short init 
	nop

times 33 db 0 ; writing null for bios parameter block

init:
	jmp 0x7c0:start ; makes cs register 0x7c0

handle_int_zero:
	mov ah, 0eh
	mov al, "A"
	mov bx, 0x00
	int 0x10
	iret

start:
	; we are going to set segment registers. Don't want hardware interrupts to
	; disturb the operation.	
	cli ; clear interrupts. 
	mov ax, 0x7c0
	mov ds, ax
	mov es, ax
	mov ax, 00
	mov ss, ax
	mov sp, 0x7c00
	sti ; enable interrupts

	mov word[ss:0x00], handle_int_zero
	mov word[ss:0x02], 0x7c0

	mov si, message
	call print
	jmp $

print:
	lodsb
	cmp al, 0
	je .done
	call print_char
	jmp print

.done:
	ret
	

print_char:
	mov ah, 0eh
	int 0x10
	ret

message: db "hello world", 0
times 510 - ($ - $$) db 0
dw 0xAA55
