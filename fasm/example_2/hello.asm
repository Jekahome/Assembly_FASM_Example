format ELF64
public _start    ; процедура точка входа, public для видимости

section '.data' writable
    msg db "Hello, Jeka!",0xA,0
    ;len = $-msg

section '.text' executable
_start:          ; аналог главной ф-ции main
    

    mov rax,msg
    call print_string
    call _exit   ; вызов процедуры _exit

section '.print_string' executable
; input | rax = string
print_string:
    push rax
    push rbx
    push rcx
    push rdx
    mov rcx,rax  ; из input rax перемешаем данные в rcx для `buf` параметра `sys_write`
    call length_string 
    ;Параметры в rax -> sys_write, rbx -> fd, rcx -> buf, rdx -> count
    mov rdx,rax ; rdx теперь содержит данные для `count` посчитанные в `length_string`
    mov rax,4 ; Назначаем для вызова системную функцию `ssize_t sys_write(unsigned int fd, const char * buf, size_t count)`
    mov rbx,1 ; Задаем параметр fd, где 1 - это stdout дескриптор потока вывода 
    int 0x80
    pop rdx ; забираем в обратном порядке их добавления
    pop rcx 
    pop rbx 
    pop rax 
    ret     ; ret - обратный возврат к месту вызова

section '.length_string' executable
; input  | rax = string
; output | rax = length
length_string:
    push rdx ; добавляем используемый регистр rdx в стек. Стек нужен для изоляции использумых регистров
    xor rdx,rdx  ; обнулим регистр rdx для дальнейшего использования (аналог `mov rdx,0`)
    .next_iter:  ; внутренняя локальная процедура для создания цыкла
        cmp [rax+rdx], byte 0    ; условие выхода из цыкла,где rax+rdx это адресс, а[rax+rdx] - значение, смещаясь по `+1` и ищем окончания строки т.е. `byte 0` и выход
        je .close      ; обработчик успеха сравнения cmp, прыжок к процедуре `.close`
        inc rdx ; инкремент rdx
        jmp .next_iter ; переброс снова в начало процедуры (goto)
    .close:
        mov rax,rdx ; формирование знаяения для output, в rax перемещаем данные из rdx
        pop rdx ; удалить из стека последний используемый регистр
        ret

section '._exit' executable
_exit:           ; процедура для выхода
    mov rax,1        ; Назначаем для вызова системную функции, где 1 - соответствует функции `int sys_exit(int status)`
    mov rbx,0        ; Задаем параметр status=0, для возврат 0 означает успешное выполнение
    int 0x80     ; Вызываем функции заданную в rax

 
; Использование makefile
; $ make build

; Создание обьектного файла
; $ fasm hello.asm 

; Линковка в исполняемый файл
; $ ld hello.o -o hello   