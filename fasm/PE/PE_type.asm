format PE console

entry start

include 'win32a.inc'

section '.data' data readable writeable

    ; Метка на данные
    ; Это определение присваивает метке значение смещения начала определенных данных,
    ; и запоминается как метка данных с размером ячейки, указанной директивой

    ; обьявление меток(переменных) строк
    metkaDBStr db 'Hello World!', 0 ;Каждый символ 1байт. При компиляции превращается в указатель на данные
    metkaDBNum dd 6,0 ;  После компиляции (40100d или 4198413) это адрес на начало ячейки адреса содержащем значения 6

    metkaFormatStr db 10,13,'%s', 0
    metkaFormatNum db 10,13,'%d', 0
    metkaFormatNumEx db 10,13,'Rezult:%d', 0
    metkaFormatAddr db 10,13,'%x', 0
    metkaMessage db 10,13,'Enter value: ',0
    metkaMessageYou db 10,13,'You enter value:%d',0

    ; обьявление меток
    A dd ?
    B dd ?

    char_db db 1  ; 1 байт
    label char_du word at char_db ; 2 байта
    label char_dd dword at char_db ; 4 байта


    ; резервирование памяти для метки. По умолчанию 0
    ; После компиляции станут адресами
    age_byte Rb 4 ; 4 ячейки по 1 байту
    age_word Rw 2 ; 2 ячейки по 2 байта
    age_dword rd 1 ; 1 ячейка размером 4 байта
    age_qword rq 1; 8 байт

   ; создание констант (чисел)  4 байт
    age = 2147483649 ;  -2147483648 до 2147483647 создание чисел КАК СОЗДАТЬ больше чем 4 байтное знаковое число ???
    address = 4198413
    NULL = 0 ; создать константу на нулевой указатель.При компиляции подставится значение





section '.code' code readable executable
    start:
            ; вывод строки
            push metkaDBStr
            push metkaFormatStr
            call [printf] ; вызов ф-ции printf по ее адресу  , она вызывается с одним параметром из стека

            ; вывод числа
            push age
            push metkaFormatNum
            call [printf]

            ; вывод метки metkaDBNum с числом
            ; lea - вычисляет выражение в скобках
            lea eax, [metkaDBNum] ; метка metkaDBNum содержит адрес для значению 6. В eax будет адрес (40100d или 4198413)
            push dword [eax]
            push metkaFormatNum ; 6
            call [printf]

            ; bx bh bl  ebx
            ; 1  0  2  =513
            ; 0  0  4  =1024
            mov ebx,dword 0
            ;mov  bx,word 1;[char_dd]
            mov  bl,byte 1;[char_db]
            mov  bh,byte 2
            push dword ebx
            push metkaFormatNumEx
            call [printf]

             ;mov [char_db],224
             ;push dword [char_db]
             ;mov [char_dd],57568
             ;push dword [char_dd]
             mov ebx, dword 400
             mov [char_dd],dword ebx
             push [char_dd]
             push metkaFormatNum
             call [printf]

             mov [age_dword],400; или из ebx от предыдущих манипуляций осталось значение 400
             push [age_dword]
             push metkaFormatNum
             call [printf]

             mov [age_byte],byte 255
             push dword [age_byte] ; приведение byte к типу dword так как регистры размером 4 байта
             push metkaFormatNum
             call [printf]


             push metkaMessage ; в стек сообщение
             call [printf] ; вывод на экран
             push age_qword ;в стек метку для данных ввода
             push metkaFormatNum ; в стек строку формат
             call [scanf] ; заполнение метки вводом по формату
             push dword [age_qword] ; в стек данных метки (Все равно данные для 4 байт)
             push metkaMessageYou ; в стек формат
             call [printf] ; вывод на экран


            mov  [A],  1
            mov  [B],  2
            mov eax,[B]
            add [A],eax
            push [A] ; результат 3
            push metkaFormatNum
            call [printf]

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
         getch,'_getch',\
         scanf, 'scanf'

;Библиотеки
 ;getch - фиксирует окно в процессе
 ;printf - печать в поток вывода
 ;ExitProcess - завершение процесса