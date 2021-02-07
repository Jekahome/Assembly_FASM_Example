format PE console              ;Исполняемый файл Windows EXE
entry start                    ;Точка входа в программу
include 'win32a.inc'
section '.text' code executable
start:
    push hello
    call [printf]
    push 0
    ccall   [getchar]
    call [ExitProcess]
section '.rdata' data readable
    hello db 'Hello World!', 0
section '.idata' data readable import
    library kernel32, 'kernel32.dll', \
        msvcrt,   'msvcrt.dll'
    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', getchar,'_fgetchar'