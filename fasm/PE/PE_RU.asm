format PE console

entry start

include 'ENCODING\win1251.inc'
include 'win32a.inc'

section '.data' data readable writeable

    metkaStr du 'Привет МИР!', 0 ; обьявленные данные с меткой metkaStr типа db (1байт). При компиляции превращается в указатель на данные
    NULL = 0 ; создать константу на нулевой указатель.При компиляции подставится значение

section '.code' code readable executable

    start:
            push metkaStr ; добавили в стек строку
            call [printf] ; вызов ф-ции printf по ее адресу  , она вызывается с одним параметром из стека


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
 
 
