format PE console

entry start

include 'win32a.inc'

section '.data' data readable writeable

    metkaStr db 10,13,'Value:%d', 0 ; обьявленные данные с меткой metkaStr типа db (1байт). При компиляции превращается в указатель на данные
    metkaValue db 10,13, 'edx=%d eax=%d', 0
    metkaValDiv db 10,13, 'Delimoe=%d Chastnoe=%d Ostatok=%d',0
    metkaValDivDB db 10,13, 'Chastnoe=%d Ostatok=%d',0
    NULL = 0 ; создать константу на нулевой указатель.При компиляции подставится значение

    A dd ?
    B dd ?
    C dd ?
    point db ',',0
    formatNum db '%d',0
    PRECISION = 3 ; точность числа, знаки после запятой


    Ab dw ?


    ; резервирование памяти для метки
    ; После компиляции станут адресами
    age_byte Rb 4 ; 4 ячейки по 1 байту
    age_word Rw 2 ; 2 ячейки по 2 байта
    age_dword rd 1 ; 1 ячейка размером 4 байта
    age_qword rq 1; 8 байт


section '.code' code readable executable
    start:

            mov [age_dword], 1; [age_dword] = 1
            inc [age_dword] ; +1 [age_dword] = [age_dword]+1
            dec [age_dword] ; -1 [age_dword] = [age_dword]-1
            neg [age_dword] ; [age_dword] = [age_dword] * -1
            add [age_dword], 2 ; [age_dword] = [age_dword] + 2
            sub [age_dword], 2 ; [age_dword] = [age_dword] - 2
            push [age_dword]
            push metkaStr
            call [printf]

            ; умножение
            ; 400000*3000 = edx=0 eax=1200000000
            mov  [age_dword], 400000
            mov  [age_word], 5000
            mov eax,[age_dword]
            mul  dword [age_word]
            push eax ; посмотрим младшую часть
            push edx ; посмотрим старшую часть
            push metkaValue
            call [printf]

            mov  [age_dword], -10
            mov ecx,2
            imul ecx, [age_dword]
            push ecx
            push metkaStr
            call [printf]

            ; деление
            mov edx,0 ; обнулить регистр  для результата
            mov eax,0 ; обнулить регистр  для результата
            mov  [age_dword], 22 ; 22 делимое
            mov  [age_word],6 ; 6 делитель
            mov eax,dword [age_dword]
            div [age_word] ; 45/2=23
            push edx ; 4 остаток
            push eax ; 3 частное т.е равно
            push metkaValDivDB
            call [printf]





     ; Реализация деления с выводом остатка
            mov [A], 12
            mov [B], 5

            mov eax, [A]
            mov ecx, [B]
            mov edx, 0

            div ecx ; деление eax/ecx=edx
            mov [C], edx ; сохраняем целую часть в С

            push eax
            push metkaStr
            call [printf]

            push point
            call [printf]
                ; найти остаток от деления
                ; умножать остаток на 10 пока не
                mov ebx,0 ; счетчик итераций
                lp: ; создали метку начала цикла while
                    mov eax, [C]
                    mov ecx, [B]
                    imul eax, 10

                    mov edx,0 ; очиста регистра для результата
                    div ecx ; eax/ecx = edx
                    mov [C], edx

                    push eax
                    push formatNum
                    call [printf] ; показать текущий остаток

                    add ebx, 1 ; инкремент счетчика
                    cmp ebx, PRECISION ; если количество итераций не равно 3 то false и переход к следующему оператору. Если равны то true и перепрыгнуть следующий оператор
                jne lp



            ; сдвиг бит
           mov ecx, 110b ;110b это 6 в десятичной
           shl ecx,3 ; логический сдвиг влево , сдвинуть влево на 3 бита т.е. три раза умножить на два
           push ecx ; результат 110000b = 6*2*2*2 = 48
           push metkaStr
           call [printf]


           ; сдвиг бит
           xor eax, eax ; 1&1=0 0&0=0 обнуление регистра или `mov eax,0`
           mov al, 11111010b ; 250 это 8 бит у регистра и у данных
           rol al,1 ; циклический сдвиг влево
           push eax ; 11110101b = 245
           push metkaStr
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