CC=gcc
ASMBIN=nasm

all : asm cc link
asm : 
	$(ASMBIN) -o func.o -f elf64 func.asm
cc :
	$(CC) -c -g -O0 main.c -std=c99
link :
	$(CC) -o program main.o func.o
clean :
	rm *.o
	rm main
