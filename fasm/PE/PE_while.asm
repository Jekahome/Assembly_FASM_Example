format PE console

entry start

include 'win32a.inc'

section '.data' data readable writeable

    metkaStr db 10,13,'iteration:%d', 0 ; обьявленные данные с меткой metkaStr типа db (1байт). При компиляции превращается в указатель на данные
    NULL = 0 ; создать константу на нулевой указатель.При компиляции подставится значение
    COUNT = 10

section '.code' code readable executable
    start:
               mov ebx,0 ; счетчик итераций
               lp: ; создали метку начала цикла while

                   push ebx
                   push metkaStr
                   call [printf] ; показать текущий остаток

                   add ebx, 1 ; инкремент счетчика
                   cmp ebx, COUNT
               jne lp


            ; Пример сравнение и переходов
                mov eax,5
                cmp eax,5
                je equal      ;- Если операнды раны (т.е. когда предыдущая операция дала результат 0 , 1-1=0 тоже сработатет) то переход в инструкцию je или jz
                nop
                jne not_equal ;-  Если операнды не раны то переход в инструкцию jne или jnz
                nop
                jg greated    ;-  Если левый операнд больше правого jg
                nop
                jl lower      ;-  Если левый операнд меньше правого jl
                nop
                jnl not_lower  ;-  Если левый операнд не меньше правого jnl или jge
                nop
                jng not_greated ;-  Если левый операнд не больше правого jng или jle
                nop
                jmp equal ;- Безусловный переход

                equal:
                    nop
                not_equal:
                    nop
                greated:
                    nop
                lower:
                    nop
                not_lower:
                    nop
                not_greated:
                    nop



            call [getch] ; фиксирует окно в процессе
            push NULL ;запись в стек NULL
            call [ExitProcess] ; вызов ф-ции ExitProcess по ее адресу с параметром из стека NULL

section '.import' import data readable

    library kernel32, 'kernel32.dll', \
            msvcrt, 'msvcrt.dll'

    import kernel32, \
           ExitProcess, 'ExitProcess'

    import msvcrt, \
         printf, 'printf',\
         getch,'_getch'

;Библиотеки
 ;getch - фиксирует окно в процессе
 ;printf - печать в поток вывода
 ;ExitProcess - завершение процесса