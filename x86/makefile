CC=gcc
ASMBIN=nasm

all : asm cc link
asm : 
	$(ASMBIN) -o func.o -f elf -g -l func.lst func.asm
cc :
	$(CC) -m32 -fpack-struct -c -g -O0 main.c -std=c99
link :
	$(CC) -m32 -g -o program main.o func.o
clean :
	del *.o
	del program.exe
	del func.lst
