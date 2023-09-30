; https://www.youtube.com/watch?v=7OZnphRVCps&t=32s
; вызов ф-ций C из файла asm
format ELF64
public main ; точка входа для gcc компоновки

extrn sum ; from test.c
extrn printf ; from lib stdio
extrn fopen ; from lib stdio
extrn fprintf ; from lib stdio
extrn fclose ; from lib stdio

section '.data' writeable
    filename db "file.txt", 0
    mode db "w", 0
    fmt db "%d", 0xA, 0
    fnum dq 555.25
    fmt_float db "%f", 0xA, 0

section '.text' writeable 
main:
    ; example printf int ----------------------------------
    ;mov rdi,5
    ;mov rsi, 10
    ;call sum ; return result rax=15(5+10)
    ;; input rax = 15
    ;sub rsp, 8  ; для выравнивания стека
    ;mov rdi, fmt
    ;mov rsi, rax ; rsi=15
    ;xor rax, rax ; rax определяет сколько будет использованно векторных регистров
    ;call printf
    ;add rsp, 8 ; для выравнивания стека

    ; example printf float ---------------------------------
    ; вектореые регистры 128bit и требуют выравнивание стека по 16 байт, а 64bit режим выравнивает стек по 8 байт
    ;push rax ; для выравнивания стека ( `sub rsp, 8`  - второй способ выравнивания стека)
    ;mov rdi, fmt_float
    ;movq xmm0, [fnum] ; или `mov xmm0, qword [fnum]`
    ;mov rax, 1 ; 1 - использованно векторных регистров
    ;call printf
    ;pop rax ;(`add rsp, 8` - при втором способе выравнивания стека)
    

    ; example fopen fprintf --------------------------------
    sub rsp, 8
    mov rdi, filename
    mov rsi, mode
    call fopen
    add rsp, 8
    push rax ; сохраняем дескриптор файла для fprintf
    push rax ; сохраняем дескриптор файла для fclose
     
    mov rdi, 5
    mov rsi, 10
    call sum ; mov rax,15

    pop rdi ; получаем из стека дескриптор файла
    mov rsi, fmt ; второй аргумент fprintf
    mov rdx, rax ; третий аргумент fprintf
    xor rax, rax ; 0 - использованно векторных регистров
    call fprintf
 
    pop rdi ; получаем из стека дескриптор файла
    sub rsp, 8 ; для выравнивания стека
    call fclose
    add rsp, 8 ; для выравнивания стека

    ; exit
    xor rax, rax ; return 0
    ret
 
; fasm ex.asm    
; gcc -no-pie main.c ex.o -o main
; ./main