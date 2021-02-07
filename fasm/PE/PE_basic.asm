format PE console

entry start

include 'win32a.inc'

section '.data' data readable writeable

    metkaFormatStr db '%s', 0
    metkaFormatNum db '%d', 0

    ; Резервирование места под данные, метки
    name rd 2 ; размер 2 ячейки памяти по 2 байта т.е 8 байт символов
    age rd 1  ; размер 1 ячейка 2 байта т.е. −2147483648 +2147483647

    wn db 'What is your name? ', 0
    ho db 'How old are you? ', 0
    hello db 'Hello %s, %x', 0

    address db 10,13, 'hello var address is %x' ; 10,13 это \n

    NULL = 0 ; создать константу на нулевой указатель.При компиляции подставится знаяение

section '.code' code readable executable

    start:
            ; вывод на экран
            push  wn
            call  [printf]

            ; ввод данных
            ; добавим в стек втрой аргумент ф-ции scanf и после первый аргумент для ее вызова
            push name
            push metkaFormatStr
            call  [scanf] ;scanf возьмет из стека два значения. Запрос ввода данных пользователя

           ; вывод на экран просьбы ввести данные
            push ho
            call  [printf]

            ; ввод данных для age пользователем
            push age
            push metkaFormatNum
            call [scanf]

            ; вывод данных пользователем
            push [age] ; почему-то адрес а не значение метки
            push name
            push hello
            call [printf] ;Сперва загрузит формат строку потом два значения из стека заберет  printf

            ; вывод адреса метки
            lea eax,[hello] ; поместим адрес метки hello в регистр eax
            push eax
            push address
            call [printf]


            call [getch] ; задержать окно

            push NULL ;запись в стек NULL
            call [ExitProcess] ; вызов ф-ции ExitProcess по ее адресу с параметром из стека NULL

section '.import' import data readable

    library kernel32, 'kernel32.dll', \
            msvcrt, 'msvcrt.dll'

    import kernel32, \
           ExitProcess, 'ExitProcess'

    import msvcrt, \
         printf, 'printf',\
         getch,'_getch',\
         scanf, 'scanf'

; scanf - ввод данных