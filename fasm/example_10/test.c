typedef unsigned long long int uint;

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

uint sum(uint x, uint y){
    return x + y;
}