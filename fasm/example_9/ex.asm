format ELF64

public mul_from_asm
public gas_to_fasm_print_string

; wrap fasm for gas assembler syntax
section '.gas_to_fasm_print_string' executable
; input | 1 arg
; output| false
gas_to_fasm_print_string:
    mov rax, rdi
    call print_string
    ret

section '.mul_from_asm' executable
; input | 2 args
; output| false
mul_from_asm:
    mov rax, rdi
    mul rsi
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
; input | rax = string
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


; fasm ex.asm    
; gcc -no-pie main.c ex.o -o main
; ./main