format PE console

entry start

include 'win32a.inc'

section '.data' data readable writeable

    tub dd 10.0
    divident dd 3.0

    NULL = 0

section '.code' code readable executable

    start:
    ; открыть в ollydb и пошагово F7 пройти код
            fld [tub] ; загрузить 10.0 в ST(0)
            fld [divident] ; загрузить 3.0 в ST(0). А 10.0 опустится в ST(1)
            ; теперь в ST(0) находится 3.0, а в ST(1) находится 10.0
            fdivp st1,st0 ; делим st1=st1/st0 и pop удалить из стека т.е. ST(0)
            ; после выбрасывания ST(0) на это место поднялся бывший ST(1) с результатом деления
            fstp [tub] ; store сохранить верхушку стека т.е. ST(0) в tub и pop выбросить из стека


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