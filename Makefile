SHELL = /bin/sh
.SUFFIXES:


.DEFAULT: build
build:  
	cd fasm; mkdir example_$(n); cd example_$(n); touch ex.asm; touch Makefile

# $ make --quiet --warn-undefined-variables n=<N>

