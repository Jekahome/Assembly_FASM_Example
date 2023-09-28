; input output https://www.youtube.com/watch?v=IjicY8fhgcI&t=200s

format ELF64
public _start    ; процедура точка входа, public для видимости

section '.bss' writable
    _buffer_char_size equ 2
    _buffer_char rb _buffer_char_size

    _buffer_number_size equ 21 ; max число символов
    _buffer_number rb _buffer_number_size
    buffer_size equ 20
    buffer rb buffer_size
    _bss_char rb 1

section '.text' executable
_start: 
    ; input string         
    ;mov rax, buffer
    ;mov rbx, buffer_size
    ;call input_string
    ;call print_string
    ;call _exit
    ;--------------------
    ;call input_number
    ;call print_number
    ;call _exit
    ;--------------------
    call input_char
    call print_char
    call _exit

section '.input_char' executable  
; output|rax = char
input_char:
    mov rax, _buffer_char
    mov rbx, _buffer_char_size
    call input_string
    mov rax, [rax]
    ret

section '.input_number' executable  
; output|rax = number
input_number:
    mov rax, _buffer_number
    mov rbx, _buffer_number_size
    call input_string
    call string_to_number
    ret

section '.input_string' executable    
; input| rax = buffer
; input| rbx = buffer size
input_string:
    push rax
    push rbx
    push rcx
    push rdx

    push rax

    mov rcx, rax ; перекладываем buffer
    mov rdx, rbx ; перекладываем buffer size
    mov rax, 3 ; ssize_t sys_read(unsigned int fd, char * buf, size_t count)
    mov rbx, 2 ; параметр fd=2 это stdin
    int 0x80

    pop rbx ; забираем из стека данные,а там сейчас rax и помещаем их в rbx
    mov [rbx+rax-1], byte 0 ; для вставки в конец завершения строки символ 0

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret



; "571",0
; '5'-'0'=5
; '7'-'0'=7
; '1'-'0'=1
; 1*1+7*10*5*100=571
section '.string_to_number' executable
; input | rax = string
; output| rax = number
string_to_number:
    push rbx
    push rcx
    push rdx
    xor rbx,rbx ; длина
    xor rcx,rcx
    .next_iter:
        cmp [rax+rbx], byte 0
        je .next_step
        mov cl, [rax+rbx]
        sub cl, '0'
        push rcx
        inc rbx
        jmp .next_iter
    .next_step:  
        mov rcx, 1
        xor rax, rax  
    .to_number:
        cmp rbx, 0
        je .close
        pop rdx
        imul rdx, rcx
        imul rcx, 10
        add rax, rdx
        dec rbx
        jmp .to_number
    .close:    
        pop rdx
        pop rcx
        pop rbx
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

section '.length_string' executable
; input| rax = string
; output| rax = length
length_string:
    push rbx
    xor rbx,rbx
    .next_iter:
        cmp [rax+rbx], byte 0
        je .close
        inc rbx
        jmp .next_iter
    .close:
        mov rax, rbx
        pop rbx
        ret  

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

section '._exit' executable
_exit:          
    mov rax,1        ; Назначаем для вызова системную функции, где 1 - соответствует функции `int sys_exit(int status)`
    mov rbx,0        ; Задаем параметр status=0, для возврат 0 означает успешное выполнение
    int 0x80     ; Вызываем функции заданную в rax

