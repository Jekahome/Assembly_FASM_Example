SHELL = /bin/sh
.SUFFIXES:

CC=gcc
ASM=fasm

.DEFAULT: default build run
default: build run
build:
	$(CC) test.c -c -o test.o;$(ASM) ex.asm;gcc ex.o test.o -o ex

run:
	./ex	