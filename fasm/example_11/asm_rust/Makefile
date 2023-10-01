SHELL = /bin/sh
.SUFFIXES:
 

.DEFAULT: default build run
default: build dis run
build:
	cargo build
dis:
	objdump -S -M intel -d target/debug/asm_rust > disassembly.dump	
run:
	./target/debug/asm_rust