format ELF executable 3
entry start

segment readable executable

start:

mov eax,4         ; Назначаем для вызова системную функцию, где 4 - соответствует функции `ssize_t sys_write(unsigned int fd, const char * buf, size_t count)`
mov ebx,1         ; Задаем параметр fd, где 1 - это stdout дескриптор потока вывода 
mov ecx,msg       ; Задаем параметр buf, указатель на строку
mov edx,msg_size  ; Задаем параметр count, размер строки
int 0x80          ; Вызываем функции заданную в eax

mov eax,1         ; 1 - номер системной функции `int sys_exit(int status)`
xor ebx,ebx       ; Задаем параметр status 
int 0x80          ; Вызываем функции заданную в eax

segment readable writeable

msg db 'Hello world!',0xA
msg_size = $-msg