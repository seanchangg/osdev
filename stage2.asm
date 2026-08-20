bits 16
org 0x7e00

start:
    call com1_init
    mov si, msg
    call serial_print
    cli
    hlt
    
msg: db "stage 2 is running", 13, 10, 0

%include "com1.asm"
times 512-($-$$) db 0
