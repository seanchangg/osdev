bits 16
org 0x000

start: ; after the far jump that sends us back to the low segment
    cli ; close interrupt
    cld ; clear direction flag
    
	xor ax, ax ; sets ax to 0
	mov ss, ax ; ss = stack base memory. (the bottom of the stack)
	mov sp, 0x7000 ; sp = stack top pointer - the current top of stack. 0-0x7c00 is free, so it starts there
	
	mov ax, 0xF000
	mov ds, ax ; now it points to the correct base 
	
	call com1_init
	mov si, msg
	call serial_print

.hang:
	hlt
	jmp .hang

msg: db "BIOS is... ALIVE!", 13, 10, 0

%include "com1.asm"
times 0xFFF0-($-$$) db 0

jmp 0xF000:start

times 0x10000-($-$$) db 0
