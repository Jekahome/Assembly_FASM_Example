SHELL = /bin/sh
.SUFFIXES:

CC=gcc
ASM=fasm

.DEFAULT: compiler
compiler:  
	$(ASM) ex.asm; $(CC) -no-pie main.c ex.o -o main
run:
	./main

	