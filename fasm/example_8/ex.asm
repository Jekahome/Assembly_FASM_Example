; file https://www.youtube.com/watch?v=dF7ksQQW-yk&t=133s

format ELF64
public _start    ; процедура точка входа, public для видимости

section '.bss' writeable
    buffer_size equ 3
    buffer rb buffer_size
    _bss_char rb 1


section '.data' writeable
    datas db "hello, world!", 0
    datas_size = $-datas-1 ; -1 для корректного отображения в редакторе, так как последний 0 мешает распознать текст
    filename db "test_file.txt", 0

section '.text' executable
_start: 
    ; fcreate -----------------
    ;mov rax, filename
    ;mov rbx, 777o
    ;call fcreate
    ;call fclose
    ; fdelete -------------------
    ;mov rax, filename
    ;call fdelete

    ; fwrite --------------------
    ;mov rax, filename
    ;mov rbx, 1
    ;call fopen
    ;mov rbx, datas
    ;mov rcx, datas_size
    ;call fwrite

    ; read -------------------
    mov rax, filename
    mov rbx, 2 
    call fopen

    ; 1 chank ---
    ;mov rbx, buffer
    ;mov rcx, buffer_size - 1 ; -1 так как если будем читать простой текст то должны оставить место для 0 символа
    
    ;push rdx
    ;push rax
    ;call fread
    ;mov rdx, rax
    ;pop rax
    
    ;push rax
    ;mov rax, buffer
    ;call print_string
    ;pop rax 
    ;pop rdx

    ; iter chanks ---
    .read_iter:
        mov rbx, buffer
        mov rcx, buffer_size - 1 ; -1 так как если будем читать простой текст то должны оставить место для 0 символа
        
        push rdx
        push rax
        call fread
        cmp rax, 0
        je .close
        ;call print_number
        mov rdx, rax
        pop rax
        
        push rax
        mov rax, buffer
        call print_string
        pop rax 
        pop rdx
        jmp .read_iter
    .close:
        call fclose
        call _exit

section '.fcreate' executable
; input |rax = filename
; input |rbx = permissions
; output|rax = descriptor
fcreate:
    push rbx
    push rcx
    mov rcx, rbx ; rcx = permissions
    mov rbx, rax ; rbx = filename 
    mov rax, 8 ; int sys_creat(const char * pathname, int mode)
    int 0x80
    pop rcx
    pop rbx 
    ret

section '.fdelete' executable
; input|rax = filename
fdelete:
    push rax
    push rbx
    mov rbx, rax ; rbx = pathname
    mov rax, 10 ; int sys_unlink(const char * pathname)
    int 0x80
    pop rbx
    pop rax
    ret

section '.fopen' executable
; input |rax = filename
; input |rbx = mode (0=O_RDONLY, 1=O_WRONLY, 2=O_RDWR) O_RDWR - оставляет за собой смешение 
; output|rax = descriptor
fopen:
    push rbx
    push rcx
    mov rcx, rbx ; rcx = mode
    mov rbx, rax; ; rbx = filename
    mov rax, 5 ; int sys_open(const char * filename, int flags, int mode)
    int 0x80
    pop rcx
    pop rbx
    ret   

section '.fclose' executable
; input|rax = descriptor
fclose:
    push rbx
    mov rbx, rax ; rbx = fd
    mov rax, 6 ; sys_close(unsigned int fd)
    int 0x80
    pop rbx
    ret

section '.fwrite' executable
; input|rax = descriptor
; input|rbx = data
; input|rcx = data size
fwrite:
    push rax
    push rbx
    push rcx 
    push rdx 

    push rbx ; сохранение входных параметров в стеке
    push rcx ; сохранение входных параметров в стеке
    mov rbx, 1 ; fseek input mode=SEEK_CUR
    xor rcx, rcx ; fseek input position=0
    call fseek ; 
    pop rcx
    pop rbx

    mov rdx, rcx ; rdx = count
    mov rcx, rbx ; rcx = buf
    mov rbx, rax ; rbx = fd
    mov rax, 4 ; ssize_t sys_write(unsigned int fd, const char * buf, size_t count)
    int 0x80

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret    

section '.fread' executable
; input |rax = descriptor
; input |rbx = buffer
; input |rcx = buffer size
; output|rax = size read
fread:
    ;push rax
    push rbx
    push rcx 
    push rdx 

    push rbx ; сохранение входных параметров в стеке
    push rcx ; сохранение входных параметров в стеке
    mov rbx, 1 ; fseek input mode=SEEK_CUR
    xor rcx, rcx ; fseek input position=0
    call fseek ; 
    pop rcx
    pop rbx

    mov rdx, rcx ; rdx = count
    mov rcx, rbx ; rcx = buf
    mov rbx, rax ; rbx = fd
    mov rax, 3 ; ssize_t sys_read(unsigned int fd, char * buf, size_t count)
    int 0x80

    pop rdx
    pop rcx
    pop rbx
    ;pop rax
    ret  

section '.fseek' executable
; input|rax = descriptor
; input|rbx = mode seeek(SEEK_SET=0,SEEK_CUR=1,SEEK_END=2)
; input|rcx = position
fseek:
    push rax
    push rbx
    push rcx
    push rdx
    mov rdx, rbx ; rdx = origin (mode)
    ; rcx = offset
    mov rbx, rax; rbx = fd
    mov rax, 19; off_t sys_lseek(unsigned int fd, off_t offset, unsigned int origin)
    int 0x80
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret


section '.print_string' executable
; input|rax = string
; input|rdx = length string
print_string:
    push rax
    push rbx
    push rcx
    push rdx
    mov rcx, rax ; rcx = buf
    ; rdx = count
    mov rax, 4 ; ssize_t sys_write(unsigned int fd, const char * buf, size_t count)
    mov rbx, 1 ; rbx = fd
    int 0x80
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
; input| rax = number
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

