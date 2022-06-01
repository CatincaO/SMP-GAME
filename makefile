.PHONY: all

all:
	nasm -f bin game.asm -o game.bin
run:
	qemu-system-i386 -drive format=raw,file=game.bin

clean:
	rm -fr game.bin
