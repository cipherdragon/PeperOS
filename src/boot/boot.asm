ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
	jmp short init 
	nop

times 33 db 0 ; writing null for bios parameter block

init:
	jmp 0:start ; makes cs register 0x7c0

start:
	; we are going to set segment registers. Don't want hardware interrupts to
	; disturb the operation.	
	cli ; clear interrupts. 
	mov ax, 0
	mov ds, ax
	mov es, ax
	mov ax, 00
	mov ss, ax
	mov sp, 0x7c00
	sti ; enable interrupts

.load_protected:
	cli
	lgdt[gdt_descriptor]
	mov eax, cr0
	or al, 1
	mov cr0, eax
	jmp CODE_SEG:load32

gdt_start:
gdt_null:
	dd 0x0
	dd 0x0

; offset 0x8
gdt_code:     ; CS should point to this
	dw 0xffff ; Segment limit first 0-15 bits
	dw 0      ; Base 0-15 bits
	db 0      ; Base 16-23 bits
	db 0x9a   ; Access bytes
	db 11001111b ; High 4 bit flags and low 4 bit flags
	db 0      ; Base 24 - 31 bits
; offset 0x10
gdt_data:     ; DS, SS, ES, FS, GS
	dw 0xffff ; Segment limit first 0-15 bits
	dw 0      ; Base 0-15 bits
	db 0      ; Base 16-23 bits
	db 0x92   ; Access bytes
	db 11001111b ; High 4 bit flags and low 4 bit flags
	db 0      ; Base 24 - 31 bits
gdt_end:
gdt_descriptor:
	dw gdt_end - gdt_start - 1
	dd gdt_start

[BITS 32]
load32:
	mov eax, 1
	mov ecx, 100
	mov edi, 0x0100000
	call ata_lba_read
	jmp CODE_SEG:0x0100000

ata_lba_read:
	mov ebx, eax ; backup the LBA for later
	; Send high 8 bits of the LBA to the hard disk controller
	shr eax, 24
	or eax, 0xE0 ; Select the master drive
	mov dx, 0x1F6 ; Port the 8 bits need to be written
	out dx, al ; Sending high 8 to the port

	; Send total sectors to read
	mov eax, ecx
	mov dx, 0x1F2
	out dx, al

	; Send more bits of the LBA
	mov eax, ebx ; Restore the backed up LBA
	mov dx, 0x1F3
	out dx, al

	; Send more bits of the LBA
	mov dx, 0x1F4
	mov eax, ebx ; Restore the backup LBA
	shr eax, 8
	out dx, al

	; Send upper 16 bits of the LBA
	mov dx, 0x1F5
	mov eax, ebx ; Restore the backup
	shr eax, 16
	out dx, al

	mov dx, 0x1F7
	mov al, 0x20
	out dx, al

; Read all sectores into memory
.next_sector:
	push ecx

; Checking if we need to read again
.try_again:
	mov dx, 0x1F7
	in al, dx
	test al, 8
	jz .try_again

	; Have to read 256 words (2 bytes) each time
	mov ecx, 256
	mov dx, 0x1F0
	rep insw ; Repeat insw command ecx times (256 times)
	pop ecx
	loop .next_sector
	; End reading sectors into memory

	ret

times 510 - ($ - $$) db 0
dw 0xAA55

buffer:
