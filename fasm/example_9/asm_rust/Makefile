SHELL = /bin/sh
.SUFFIXES:

ASM=fasm

.DEFAULT: run 

run: compiler build
	./target/debug/asm_rust

compiler:   
	$(ASM) src/ex.asm

build:
	cargo build

# build_asm:	fasm src/ex.asm; ld src/ex.o -o src/ex; ./src/ex

  	
	

