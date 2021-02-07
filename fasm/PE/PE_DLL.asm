format PE console DLL

entry DllEntryPoint

include 'win32ax.inc'
include 'encoding/win1251.inc'      ; подключим кирилицу
; include 'MACRO\PROC64.INC'

section '.data' data readable writeable

    hello db 10,13,'Привет друг!', 0

    len      =   $ - hello                        ; размер этих данных

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

; https://www.cyberforum.ru/post6567088.html
; обмен через регистры  32/64-бита, через стек, через указатели, и наконец через MMF - MemoryMappedFile
; принимает два параметра, возвращает через регистр ebx
proc myfunc param1:DWORD, param2:DWORD
     local local_param:DWORD
    ;local str[256]:BYTE ; массив
    ;mov eax,[param1] ; или mov ebx,[ebp+8]
    xor ebx,ebx
    mov [local_param],10
    mov DWORD ebx,[param1]
    add ebx,[param2]; результат в ebx
    add ebx,[local_param]
    ret
endp

;-- Функция обмена данными через указатели ------
proc   GetStr arg1                     ; функция с одним аргументом
       mov    edi,[ebp+8]              ; читаем аргумент - это приёмник в секции-данных EXE
       mov    esi,hello                 ; источник внутри DLL
       mov    ecx,len                  ; размер копируемых данных
       rep    movsb            ;<------; скопировать ECX-байт из ESI в EDI
       ret
endp

proc myuses uses ebx esi edi,\
    param1:DWORD
      mov ebx,[param1]; или mov ebx,[ebp+8]
      add ebx,1
      ret
endp



section '.edata' export data readable

  export 'PE_DLL.DLL',\
	 myproc,'myproc',\
	 myfunc,'myfunc',\
	 myuses,'myuses',\
	 GetStr,'GetStr'

; Если в программе эта секция не определена, то EXE/DLL грузиться по фиксированному адресу 00400000h и операция перемещения образа не производится.
section '.reloc' fixups data readable discardable  ; разрешаем загрузчику перемещать базу DLL в памяти

  if $=$$
    dd 0,8		; if there are no fixups, generate dummy entry
  end if

;Библиотеки
 ;getch - фиксирует окно в процессе
 ;printf - печать в поток вывода
 ;ExitProcess - завершение процесса