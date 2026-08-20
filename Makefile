ASM := nasm
QEMU := qemu-system-i386

.PHONY: all run debug clean

all: rom.bin

# {target} : {source}
# $< = source, $@ = target
rom.bin : rom.asm com1.asm
	$(ASM) -f bin $< -o $@

run: rom.bin
	$(QEMU) -bios rom.bin -serial stdio -display none

debug: rom.bin
	$(QEMU) -bios rom.bin -serial stdio -display none -d in_asm,cpu_reset -D trace.txt

clean: 
	rm -f rom.bin trace.txt 
