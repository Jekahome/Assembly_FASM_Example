format PE64 console DLL

entry DllEntryPoint

include 'win64ax.inc'
include 'encoding/win1251.inc'      ; подключим кирилицу
; include 'MACRO\PROC64.INC'

section '.data' data readable writeable

    hello db 10,13,'Привет друг!', 0
    value db 5,0
    len      =   $ - value    ; размер этих данных

section '.text' code readable executable

; https://docs.microsoft.com/en-us/windows/win32/dlls/dllmain
proc DllEntryPoint hinstDLL,fdwReason,lpvReserved
	mov	eax,TRUE ; 1
	ret
endp

proc myproc
    ;local param1:DWORD
    mov DWORD ebx,hello
    ret
endp

;-- Функция обмена данными через указатели ------
proc   GetStr arg1                     ; функция с одним аргументом
       mov   edi,[ebp+8]              ; ebp+8 читаем аргумент - это приёмник в секции-данных EXE
       mov    esi,value                 ; источник внутри DLL
       mov    ecx,len                  ; размер копируемых данных
       rep    movsb            ;<------; скопировать ECX-байт из ESI в EDI
       ret
endp

section '.edata' export data readable

  export 'PE_DLL64.DLL',\
	 myproc,'myproc',\
      GetStr,'GetStr'

; Если в программе эта секция не определена, то EXE/DLL грузиться по фиксированному адресу 00400000h и операция перемещения образа не производится.
section '.reloc' fixups data readable discardable  ; разрешаем загрузчику перемещать базу DLL в памяти

