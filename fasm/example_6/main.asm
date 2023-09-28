; library https://www.youtube.com/watch?v=AY-E-YKP4k4
format ELF64
public _start    ; процедура точка входа, public для видимости

include "asmlib/fmt.inc" ;extrn gcd
include "asmlib/mth.inc" ;extrn print_number
include "asmlib/sys.inc" ;extrn print_line
include "asmlib/str.inc" ;extrn _exit

section '.data' writable
    strnum db "571",0
    _buffer.size equ 20

section '.bss' writable
    _buffer rb _buffer.size  

section '.text' executable
_start:  
    ; number_to_string --------------
    mov rax, 571
    mov rbx, _buffer
    mov rcx, _buffer.size
    call number_to_string
    mov rax, _buffer
    call print_string
    call print_line

    ; string_to_number --------------
    mov rax,strnum
    call string_to_number
    call print_number
    call print_line

    ; factorial ---------------------
    mov rax, 6
    call factorial
    call print_number
    call print_line

    ; print_number ------------------
    mov rax, 30
    mov rbx, 9
    call gcd
    call print_number
    call print_line

    call _exit