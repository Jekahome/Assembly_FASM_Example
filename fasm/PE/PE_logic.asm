format PE console

entry start

include 'win32a.inc'

section '.data' data readable writeable

    metkaStr db 10,13,'Value:%d', 0 ; обьявленные данные с меткой metkaStr типа db (1байт). При компиляции превращается в указатель на данные
    NULL = 0 ; создать константу на нулевой указатель.При компиляции подставится значение

    strFALSE db 10,13,'ZF = 1, op result is FALSE', 0
    strTRUE db 10,13,'ZF = 0, op result is TRUE',0

section '.code' code readable executable

    start:

           ; все логические команды выполняются над битами
            mov eax, 110b ; 110b = 6
            and eax, 101b
            push eax ; 110b & 101b = 100b = 4
            push metkaStr
            call [printf]

            mov eax, 1000b ; 1000b = 8
            or eax, 1010b ; 1010b = 10
            push eax ; 1000b | 1010b = 1010b = 10
            push metkaStr
            call [printf]

            mov eax, 1010b ; 1010b = 10
            xor eax, 111b ; 111b = 7
            push eax ; 1010b | 111b = 0101b = 13
            push metkaStr
            call [printf]



          ; test
          ; ZF - равен 0 если результат test был 1
          ; ZF - равен 1 если результат test был 0
          ; jz - условный переход при ZF=1

           mov eax, 110b ; 110b = 6
           test eax, 101b ; 101b = 5, 110b & 101b = 100b = 4 т.е. TRUE и ZF = 0

            jz ifZFTrue

            ; если программа дошла до сюда то условный переход jz не сработал и ZF = 0
            push strTRUE
            call [printf]

            jmp finish ; перепрыгнуть условный переход ifZFTrue в случае если ZF=0

            ifZFTrue: ; это не блок, это просто метка в коде
            push strFALSE
            call [printf]

            finish:

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