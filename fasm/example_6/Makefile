CC = fasm
LIBS = asmlib/mth.asm asmlib/fmt.asm asmlib/sys.asm asmlib/str.asm
LIBS_OBJ = asmlib/mth.o asmlib/fmt.o asmlib/sys.o asmlib/str.o
.PHONY: default compile build run
default: build run
compile: $(LIBS)
	$(CC) asmlib/fmt.asm && $(CC) asmlib/mth.asm && $(CC) asmlib/str.asm && $(CC) asmlib/sys.asm	
build: main.asm $(LIBS_OBJ)
	$(CC) main.asm
	ld main.o $(LIBS_OBJ) -o main
run: main
	./main	

#1 $ make compile
#2 $ make build
 	