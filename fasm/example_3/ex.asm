; print_number

format ELF64
public _start    ; процедура точка входа, public для видимости

section '.bss' writable
    bss_char db 1 ; пременная bss_char имеет тип размеров 8 бит(1 байт) и кладем в нее 1

section '.text' executable
_start:          
    mov rax, 0
    call print_number
    call print_line
    call _exit

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

section '.print_line' executable
print_line:
    push rax
    mov rax, 0xA
    call print_char
    pop rax
    ret

section '.print_char' executable
; injput rax = char
print_char:
    push rax
    push rbx
    push rcx
    push rdx
    mov [bss_char], al ; перемешаем из регистра rax->eax->ax->ah/al в bss_char наш символ
    ;Параметры в rax -> sys_write, rbx -> fd, rcx -> buf, rdx -> count
    mov rax, 4 ; 4 - соответствует функции `ssize_t sys_write(unsigned int fd, const char * buf, size_t count)`
    mov rbx, 1 ; rbx заполняет параметр fd, где 1 - это stdout дескриптор потока вывода 
    mov rcx, bss_char ; rcx заполняет параметр buf
    mov rdx, 1 ;rdx заполняет параметр count
    int 0x80 
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

section '._exit' executable
_exit:          
    mov rax,1        ; Назначаем для вызова системную функции, где 1 - соответствует функции `int sys_exit(int status)`
    mov rbx,0        ; Задаем параметр status=0, для возврат 0 означает успешное выполнение
    int 0x80     ; Вызываем функции заданную в rax

