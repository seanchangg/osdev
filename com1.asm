BASE equ 0x3F8

com1_init: 
    mov dx, BASE+3
    in al, dx
    and al, 0x7F ; 01111111 - leftmost is most significant bit. This masks out bit 7 AKA DLAB bit
    out dx, al
    
    mov dx, BASE+1
    mov al, 0
    out dx, al ; DLAB bit is guaranteed reset, now we disable interrupts
 
    mov dx, BASE+3
    in al, dx
    or al, 0x80 ; 10000000 - set DLAB to 1
    out dx, al 
    
    ; now we're gonna set baud rate - we're going for dividing by 1 (00000001)
    mov dx, BASE
    mov al, 0x01
    out dx, al
    mov dx, BASE+1
    mov al, 0x00
    out dx, al
        
    ;set DLAB back to 0
    mov dx, BASE+3
    in al, dx
    and al, 0x7F 
    out dx, al
    
    mov dx, BASE+3
    in al, dx; about to set no parity & 1 stop bit. Parity is bits 3-5, to set none we just need 3 to be 0. stop bits is bit 2. SO we need xxxx00xx
    and al, 0xF3 ; 11110011 = 15, 3
    or al, 0x03 ; 00000011 - writes 1 1 to data bits telling it 8 bit word length
    out dx, al
    
    mov dx, BASE+2
    mov al, 0x07 ; 00000111 - clear and reset fifo and enable
    out dx, al
    ret
    
serial_putc: 
    mov dx, BASE+5 ; This accesses the line status register. bit 5 says if there's room for data
    .wait: 
        in al, dx ; load for arithmetic
        test al, 0x20 ; check if we have room. This checks bit 5 (00100000)
        jz .wait ; if not, keep waiting
	lodsb ; if so load in
	mov dx, BASE
	out dx, al ; put the character in the transmission buffer
	ret ; returns after code is run to the caller code, otherwise cpu keeps executing into serial_print
	
	
serial_print:
    .wait: 
        mov dx, BASE+5 ; This accesses the line status register. bit 5 says if there's room for data
        in al, dx ; load for arithmetic
        test al, 0x20 ; check if we have room. This checks bit 5 (00100000)
        jz .wait ; if not, keep waiting
        lodsb ; load byte (one char) - looks at ds:si (16-bit) or ds:esi (32) and loads into al, ax, eax respectively. increments according to DF (direction flag) for moving up or down memory
	    test al, al 
	    jz .stop 
	    mov dx, BASE
	    out dx, al
	    jmp .wait ; repeat
	.stop:
	   ret
    
    
    
    