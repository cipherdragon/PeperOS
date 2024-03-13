ORG 0
BITS 16

_start:
	jmp short init 
	nop

times 33 db 0 ; writing null for bios parameter block

init:
	jmp 0x7c0:start ; makes cs register 0x7c0

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

	; Reading from the disk
	mov ah, 02h
	mov al, 1
	mov ch, 0
	mov cl, 2
	mov dh, 0
	mov bx, buffer
	int 0x13
	jc disk_error
	
	mov si, buffer
	call print
	jmp $

disk_error:
	mov si, error_msg
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

error_msg: db "Failed to read from disk", 0
message: db "hello world", 0
times 510 - ($ - $$) db 0
dw 0xAA55

buffer:
