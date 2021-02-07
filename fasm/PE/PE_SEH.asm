format    pe  console
include  'win32ax.inc'
include  'encoding/win1251.inc'
include  'EXPECT.INC'
.data
;--------
mess0    db  'Стандартный выход из приложения после исключения!',0
mess1    db  'Ошибка!!! Недопустимая операция!',13,10
         db  'Код исключения: '
erCode   db   9 dup(0)
frm      db  '%08X',0
;--------
.code
start:   push   mySEH
         push   dword[fs:0]
         mov    [fs:0],esp

         xor    eax,eax
         mov    eax,[eax]
;         div    eax

next:    pop    dword[fs:0]
         add    esp,4

         invoke  MessageBox,0,mess0,0,0
         invoke  ExitProcess,0
;
;--- Внутрипоточный обработчик исключений -------------
;------------------------------------------------------
proc  mySEH  pRecord, pFrame, pContext, pParam   ; параметры в виде "ExceptionPointers"
         mov     esi,[pRecord]                   ; ESI = Exception_Record
         mov     eax,[esi+EXCEPTION_RECORD.ExceptionCode]   ; берём код-исключения из структуры
        cinvoke  wsprintf,erCode,frm,eax         ; переводим его в строку (Hex2Asc)
         invoke  MessageBox,0,mess1,0,10h        ; боксим мессагу об исключении

         mov     edi,[pContext]                  ; EDI = адрес структуры "Context"
         mov     eax,next                        ; EAX = адрес безопасного места
         mov     [edi+CONTEXT.regEip],eax        ; подмена указателя EIP

         xor     eax,eax                         ; EAX=0 перезагрузить контекст!
;         inc     eax                            ;   ..(можно не перезагружать)
         ret                                     ; CallBack диспетчеру-исключений..
endp
.end start