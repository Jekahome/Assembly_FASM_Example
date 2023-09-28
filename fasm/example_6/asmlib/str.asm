format ELF64

public string_to_number
public number_to_string
public length_string

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
