
format PE console
entry start

include 'win32ax.inc'
include 'encoding/win1251.inc'      ; подключим кирилицу

section '.data' data readable writeable

    NULL = 0
    metkaStr db 10,13,'Hello World!', 0
    equalStr db 10,13,'EQUAL [%d]=%d!', 0
    noEqualStr db 10,13,'NOT EQUAL [%d]=%d!', 0
    Arg1 dd ?
    Arg2 dd ?
    Result dd ?
    buffResult     db   64 dup(0)    ; общий буфер, для приёма строки из либы

section '.code' code readable executable

  start:
    ;mov  eax, metkaStr
    call [myproc]
    push ebx
    call [printf] ; вывод 'Привет друг!'


    ; вызов ф-ции GetStr
    invoke  GetStr, buffResult    ; передаём указатель в DLL, и принимаем строку
    push buffResult
    call [printf]


    ; вызов ф-ции myfunc
    xor ebx,ebx
    mov [Arg1], DWORD 44
    mov [Arg2], DWORD 56
    ;push [Arg1]
    ;call [myfunc]
    invoke myfunc,[Arg1],[Arg2]
    mov [Result],ebx ; получить результат
    cmp [Result],110
    je equal
    jmp or_next

equal:
    push DWORD [Result]
    push DWORD Result
    push equalStr
    call [printf]
    jmp finish

or_next:
    push DWORD [Result]
    push DWORD Result
    push noEqualStr
    call [printf]
    jmp finish

finish:

    call [getch]
    push NULL
    call [ExitProcess]

section '.idata' import data readable writeable

  library kernel,'KERNEL32.DLL',\
	  my_library,'PE_DLL.DLL',\
	  msvcrt, 'msvcrt.dll'

  import kernel,\
	 ExitProcess,'ExitProcess'

    import msvcrt, \
         printf, 'printf',\
         getch,'_getch'

  import my_library,\
	 myproc,'myproc',\
	 myfunc,'myfunc',\
	 myuses,'myuses',\
	 GetStr,'GetStr'