bits 16
org 0x7c00

STAGE2 equ 0x7e00 ; "STAGE2 = 0x7e00" defines a var

start:
	cli ; close interrupt
	xor ax, ax ; sets ax to 0
	mov ds, ax ; sets ds to 0 (data segment. used by [drive] anad any [] indedx)
	mov es, ax ; set es to 0 (extra segment. Used by int0x13)
	mov ss, ax ; ss = stack base memory. (the bottom of the stack)
	mov sp, 0x7c00 ; sp = stack top pointer - the current top of stack. 0-0x7c00 is free, so it starts there
	sti ; start interrupt
	cld
	
	mov [drive], dl ; dl is defined by BIOS
	
	; set up parameters for 0x13
	mov ah, 0x02 ; function id
	mov al, 1 ; number of sectors
	mov ch, 0 ; the physical ring on the spinning disk
	mov dh, 0 ; the physical surface on the spinning disk
	mov cl, 2 ; which arc of that ring (which segment)
	mov dl, [drive] ; resetting it again?
	mov bx, STAGE2 ; moving stage2 address to base segment
	int 0x13

	jmp 0:STAGE2

disk_error:
	mov ah, 0x0e
	mov al, 'E'
	int 0x10
	cli
	hlt

drive : db 0
times 510-($-$$) db 0
dw 0xaa55

