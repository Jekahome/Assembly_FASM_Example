; string_to_number и number_to_string и factorial и gcd

format ELF64
public _start    ; процедура точка входа, public для видимости

section '.data' writable
    strnum db "571",0
    _buffer.size equ 20

section '.bss' writable
    _buffer rb _buffer.size  
    _bss_char rb 1

section '.text' executable
_start:          
    ;mov rax, 571
    ;mov rbx, _buffer
    ;mov rcx, _buffer.size
    ;call number_to_string
    ;mov rax, _buffer
    ;call print_string
    ;call print_line
    ;call _exit
    ;--------------------
    ;call print_line
    ;mov rax,strnum
    ;call string_to_number
    ;call print_number
    ;call print_line
    ;call _exit
    ;--------------------
    ;mov rax, 6
    ;call factorial
    ;call print_number
    ;call print_line
    ;call _exit
    ;--------------------
    mov rax, 30
    mov rbx, 9
    call gcd
    call print_number
    call print_line
    call _exit

section '.gcd' executable
; НОД
; input |rax = number
; input |rbx = number
; output|rax = number
gcd:
    push rbx
    push rdx
    .next_iter:
        cmp rbx, 0
        je .close
        xor rdx, rdx
        div rbx
        push rbx
        mov rbx, rdx
        pop rax
        jmp .next_iter
    .close:
        pop rdx
        pop rbx    
        ret


; 6! = 1*2*3*4*5*6=720
section '.factorial' executable
; input | rax = number
; output| rax = number
factorial:
    push rbx
    mov rbx, rax ; перекладываем входной параметр факториала
    mov rax, 1   ; начинам с считать с 1
    .next_iter:
        cmp rbx, 1
        jle .close ; меньше или равно `rbx<=1` прыгаем на выход
        mul rbx    ; иначе rax=rax*rbx 
        dec rbx    ; уменьшаем на 1 входной параметр факториала
        jmp .next_iter ; прыгаем в начала цыкла
    .close:
        pop rbx
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

section '.number_to_string' executable
;            rax|rdx т.е. эти регистры будут использоваться ассемблером для результата и остатка
; 571 / 10 = 57|1
; 57 / 10 = 5|7
; 5 / 10 = 0|5
;
; '0'+1=21+1=22='1'
;
; input rax = number
; input rbx = buffer
; input rcx = buffer size
number_to_string:
    push rax
    push rbx
    push rcx
    push rdx 
    push rsi
    mov rsi,rcx ; buffer size
    dec rsi
    xor rcx,rcx ; rcx будет содержать счетчик количества чисел в стеке
    .next_iter:
        push rbx 
        mov rbx, 10 ; 10 для деления остаток 
        xor rdx, rdx
        div rbx ; div уже ориентированна на rax т.е. rax=rax/rbx,а остаток в rdx
        pop rbx
        add rdx,'0' ; '0'+1=21+1=22='1'
        push rdx ; rdx остаток складываем стек
        inc rcx
        cmp rax, 0
        je .next_step ; если больше не на что делить прыгаем в to_string
        jmp .next_iter
    .next_step:
        mov rdx,rcx
        xor rcx,rcx    
    .to_string:
        cmp rcx,rsi
        je .pop_iter 
        cmp rcx,rdx
        je .null_char
        pop rax ; обратно из стека забираем и выводим
        mov [rbx+rcx],rax
        inc rcx
        jmp .to_string  
    .pop_iter:
        cmp rcx,rdx
        je .close
        pop rax
        inc rcx
        jmp .pop_iter  
    .null_char:
        mov rsi,rdx      
    .close:
    mov [rbx+rsi], byte 0
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax    
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

section '._exit' executable
_exit:          
    mov rax,1        ; Назначаем для вызова системную функции, где 1 - соответствует функции `int sys_exit(int status)`
    mov rbx,0        ; Задаем параметр status=0, для возврат 0 означает успешное выполнение
    int 0x80     ; Вызываем функции заданную в rax

