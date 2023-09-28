// https://www.youtube.com/watch?v=OIrHZWyWL9U&t=335s
#include <stdio.h>

typedef unsigned long long int uint;
/*
uint mul(uint x, uint y){
    return x * y;
}
*/
/*
 GNU Assembler GAS = AT&T = `mov $10, %rax` (rax=10 т.е. слева на право)
 Assembler FASM   = INTEL = `mov rax, 10` (rax=10 с права на лево)

GAS =  [mov $10, %rax]
FASM = [mov rax, 10]

GNU GAS Assembler for FFI C:
    rdi/edi/di = первый аргумент
    rsi/esi/si = второй аргумент
    rdx/edx/dx = третий аргумент
    rcx/ecx/cx = четвертый аргумент
    r8/r8d/r8w = пятый аргумент
    r9/r9d/r9w = шестой аргумент
    stack = остальные аргумент
    rax = возвращаемое значение
*/
/*
;input |rdi = x
;input |rsi = y
;output|rax = uint
*/
uint mul_c(uint x, uint y){
   asm("mov %rdi, %rax");// rax=rdi
   asm("mul %rsi");// rax=rax*rsi
}

extern uint mul_from_asm(uint x, uint y);
extern uint gas_print_string(char *str);

uint c_print() {
    char *str = "heelllo";
   return gas_print_string(str);
}

// gcc -no-pie main.c ex.o -o main
// ./main