
format ELF64

include "str.inc" ;extrn length_string

public print_number
public print_string
public print_char
public print_line

section '.bss' writable
    _bss_char rb 1

section '.print_number' executable
;            rax|rdx т.е. эти регистры будут использоваться ассемблером для результата и остатка
; 571 / 10 = 57|1
; 57 / 10 = 5|7
; 5 / 10 = 0|5
;
; '0'+1=21+1=22='1'
;
; input rax number
print_number:
    push rax
    push rbx
    push rcx
    push rdx 
    xor rcx,rcx ; rcx будет содержать счетчик количества чисел в стеке
    .next_iter:
        mov rbx, 10 ; 10 для деления остаток 
        xor rdx, rdx
        div rbx ; div уже ориентированна на rax т.е. rax=rax/rbx,а остаток в rdx
        add rdx,'0' ; '0'+1=21+1=22='1'
        push rdx ; rdx остаток складываем стек
        inc rcx
        cmp rax, 0
        je .print_iter ; если больше не на что делить прыгаем в print_iter
        jmp .next_iter
    .print_iter:
        cmp rcx,0
        je .close
        pop rax ; обратно из стека забираем и выводим
        call print_char
        dec rcx
        jmp .print_iter  
    .close:
        pop rdx
        pop rcx
        pop rbx
        pop rax    
        ret

section '.print_char' executable
; injput rax = char
print_char:
    push rdx
    push rcx
    push rbx
    push rax
    mov [_bss_char], al ; перемешаем из регистра rax->eax->ax->ah/al в bss_char наш символ
    ;Параметры в rax -> sys_write, rbx -> fd, rcx -> buf, rdx -> count
    mov rax, 4 ; 4 - соответствует функции `ssize_t sys_write(unsigned int fd, const char * buf, size_t count)`
    mov rbx, 1 ; rbx заполняет параметр fd, где 1 - это stdout дескриптор потока вывода 
    mov rcx, _bss_char ; rcx заполняет параметр buf
    mov rdx, 1 ;rdx заполняет параметр count
    int 0x80 
    pop rax
    pop rbx
    pop rcx
    pop rdx
    ret  

section '.print_string' executable
; input|rax = string
print_string:
    push rax
    push rbx
    push rcx
    push rdx
    mov rcx, rax
    call length_string
    mov rdx, rax
    mov rax, 4
    mov rbx, 1
    int 0x80
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

section '.print_line' executable
print_line:
    push rax
    mov rax, 0xA
    call print_char
    pop rax
    ret
