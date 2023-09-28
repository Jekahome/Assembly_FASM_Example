
format ELF64

public gcd
public factorial

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
