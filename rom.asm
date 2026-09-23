bits 16
org 0x0000
COM1_PORT equ 0x3F8

init: ; after the far jump that sends us back to the low segment
    cli ; close interrupt
    cld ; clear direction flag
    
	xor ax, ax ; sets ax to 0
	mov es, ax ; set 0 base for RAM
	mov ss, ax ; ss = stack base memory. (the bottom of the stack)
	mov sp, 0x7000 ; sp = stack top pointer - the current top of stack. 0-0x7c00 is free, so it starts there
	
	mov ax, 0xF000
	mov ds, ax ; now it points to the correct base for lodsb

zerobda:
	mov di, 0x400
	mov cx, 0x80
	xor ax, ax
	rep stosw ; reads from di for initial address and cx for # of iters, decs til 0. Copies ax

init_com1:
	; probe and initiate COM1
	mov dx, COM1_PORT+7
	mov al, 0xAA
	out dx, al
	in al, dx
	cmp al, 0xAA ; comp, write to zero flag
	jne init_ivt ; jump not equal
	mov word [es:0x400], COM1_PORT
	
init_ivt:
	mov ax, 0xF000 ; ROM memory base
	mov dx, dummy_handler ; moves memory location of dummy_handler into dx. Since we're org0x00, this is without the ROM offset
	mov cx, 0x00 ; starts at 0, loop until 256
	.loop:
		mov di, cx
		shl di, 1 ; shift left 2 bits AKA multiply by 4
		shl di, 1
		mov [es:di], dx; little endian, so label comes "first"
		mov [es:di + 2], ax
		
		inc cx
		cmp cx, 0x0100
		jne .loop
	
	mov di, 0x40 ; 0x10 * 4 = 60 = 0x40
	mov ax, display_handler
	stosw ; auto incs di by 2 bytes
	mov ax, 0xF000
	stosw
	
	mov di, 0x58 ; 0x16 * 4 = 88 = 0x58
	mov ax, keyboard_handler
	stosw ; auto incs di by 2 bytes
	mov ax, 0xF000
	stosw
	
	sti
		
test:
	mov al, 'A'
	mov ah, 0x0e
	int 0x10


hang:
	hlt
	jmp hang
	
dummy_handler:
	iret

display_handler: ; int 0x10. com1 putc uses bl to hold the character
	push bx
	cmp ah, 0x0e
	jne .end
	mov bl, al
	call serial_putc
	.end:
		pop bx
		iret

keyboard_handler:
	mov dx, 0x3FD ; line status register. bit 1 is 1 if data ready, 0 if not
	push ax
	
	cmp ah, 0x01
	je .nowait
	
	.wait:
		in al, dx
		test al, 1 ; check if data ready. if not, ZF is set to 0
		jz .wait
	
	.nowait:
		in al, dx
		test al, 1 ; check if data ready. if not, ZF is set to 0
		jz .end
		
	mov dx, 0x3F8
	in al, dx
	
	mov ah, 0x0e
	int 0x10
	
	.end:
		pop ax
		iret

%include "com1.asm"
msg: db "BIOS is... alive!!", 13, 10, 0
times 0xFFF0-($-$$) db 0

jmp 0xF000:init

times 0x10000-($-$$) db 0
