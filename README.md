# Assembly_FASM_Example
Example FASM assembly

Ассемблер - это компилятор предоставляюший диалекты ассемблера FASM,NASM,WASM,TASM ...

Зачем - для вставок в высокоуровневый код при потребности в возможностях процессора, которые невозможно реализовать на языке высокого уровня
        Для встроенного программного обеспечения. Для ортимизации в игровых консолях. Использование возможностей процессора (avx,графический gpu процессора) которые еще не добавленны в компиляторы. Для создания вирусов инфекторов. Реверсинженериг и взлом программ


# Download FASM for Linux

[Download FASM](http://flatassembler.net/download.php)

```
$ tar zxvf fasm-1.69.11.tgz

# Для удобства вы можете создать симлинк на исполняемый файл fasm:
$ sudo ln -s <PATH YOUR LIB>/assembler/fasm/fasm /usr/local/bin

# Компиляция
$ fasm your-asm-file.asm

# Запуск исполняемой программы
$./your-asm-file

```

# Состав регистр

rax   - 64bit (8 byte)
eax   - 32bit (4 byte)
ax    - 16bit (2 byte)
ah/al - 8bit (1 byte)

и ah/al содержится в регистре ax, а ax в eax и eax в находится в rax

# Data type asm

```
db - data byte 8 bit
dw - data word 16 bit
dd - data dword 32 bit
dq - data qword 64 bit (для ELF64)

Можно объявлять переменные, не имеющие определённого начального значения. Такие переменные называются неинициализированными.

Резервирование данных
x1 db ?
x2 dw ?,?,?
x3 dd 10 dup(?)

x1 rb 1
x2 rw 3
x3 rd 10
------------------------------------------------------
section '.data' writable
    strnum db "571",0
    _buffer.size equ 20
    array db 5,4,3,2,1
    array_size equ 5

section '.bss' writable
    _buffer rb _buffer.size  

```

# Format

```
Для Linux 32bit
format ELF

Для Linux 64bit (доступны регистры rax,rbx,rcx,rdx,...)
format ELF64 

```

# Операции

```
; mov - перемещение
mov rax,10 ; переместить значение 10 в регистр rax

; add - сложение
add rax,20 ; сложить текущее значение в rax и 20 т.е. rax=rax+20

add rax, rbx ; rax=rax+rbx

imul - умножение
imul rax, rbx ; rax=rax*rbx

mul - умножение зависимое
mul rbx ; rax=rax*rbx т.е. mul уже расчитан на rax (зависим)

div - деление зависимое
div rbx ; rax=rax/rbx  т.е. div уже расчитан на rax (зависим)

sub - вычитание  
sub rax, rbx; rax=rax-rbx  

push - добавление в стек регистра только 64 bit rax при ELF64 или eax 32 bit при ELF
push rcx

pop  - удаление из стека в обратном порядке добавления
pop rcx

cmp rax, 0 ; cmp сравнение
je .print_iter ; je (равно) прыжок на метку если значение cmp еквивалентны/равно

cmp rax, 1
jle .print_iter ; jle (меньше или равно)  прыжок на метку 

; call - вызов процедуры
call _exit
```



# Структура c обьектным файлов

```
format ELF64
public _start    ; процедура точка входа, public для видимости

section '.data' writable
    msg db "Hello, Jeka!",0xA,0
    len = $-msg

section '.text' executable
_start:          ; аналог главной ф-ции main
    ; code ....
    call _exit

section '._exit' executable  
_exit:           ; процедура для выхода
    mov rax,1        ; Назначаем для вызова системную функции, где 1 - соответствует функции `int sys_exit(int status)`
    mov rbx,0        ; Задаем параметр status=0, для возврат 0 означает успешное выполнение
    int 0x80     ; Вызываем функции заданную в rax
 
```
; Создание обьектного файла
; $ fasm hello.asm 

; Линковка в исполняемый файл
; $ ld hello.o -o hello  


### Смотрим обьектный файл:
```
$ objdump -S -M intel -d hello > hello.dump
```

File hello.dump:

```
hello:     формат файла elf64-x86-64


Дизассемблирование раздела .text:

0000000000401000 <_start>:
  401000:       48 b8 00 20 40 00 00    movabs rax,0x402000
  401007:       00 00 00 
  40100a:       e8 09 00 00 00          call   401018 <_start+0x18>
  40100f:       e8 44 00 00 00          call   401058 <_start+0x58>

Дизассемблирование раздела .print_string:

0000000000401018 <.print_string>:
  401018:       50                      push   rax
  401019:       53                      push   rbx
  40101a:       51                      push   rcx
  40101b:       52                      push   rdx
  40101c:       48 89 c1                mov    rcx,rax
  40101f:       e8 1c 00 00 00          call   401040 <_start+0x40>
  401024:       48 89 c2                mov    rdx,rax
  401027:       48 c7 c0 04 00 00 00    mov    rax,0x4
  40102e:       48 c7 c3 01 00 00 00    mov    rbx,0x1
  401035:       cd 80                   int    0x80
  401037:       5a                      pop    rdx
  401038:       59                      pop    rcx
  401039:       5b                      pop    rbx
  40103a:       58                      pop    rax
  40103b:       c3                      ret    

Дизассемблирование раздела .length_string:

0000000000401040 <.length_string>:
  401040:       52                      push   rdx
  401041:       48 31 d2                xor    rdx,rdx
  401044:       80 3c 10 00             cmp    BYTE PTR [rax+rdx*1],0x0
  401048:       74 05                   je     40104f <_start+0x4f>
  40104a:       48 ff c2                inc    rdx
  40104d:       eb f5                   jmp    401044 <_start+0x44>
  40104f:       48 89 d0                mov    rax,rdx
  401052:       5a                      pop    rdx
  401053:       c3                      ret    

Дизассемблирование раздела ._exit:

0000000000401058 <._exit>:
  401058:       48 c7 c0 01 00 00 00    mov    rax,0x1
  40105f:       48 c7 c3 00 00 00 00    mov    rbx,0x0
  401066:       cd 80                   int    0x80
```

# Структура оптимизированная, в исполняемый файл

Иммет меньший размер но не имеет обьектный файл

```
format ELF64 executable
entry _start

segment readable writeable
msg db "Hello, Jeka!",0xA,0
;len = $-msg

segment readable executable

_start:          ; аналог главной ф-ции main
    ; code ....
    call _exit
_exit:           ; процедура для выхода
    mov rax,1        ; Назначаем для вызова системную функции, где 1 - соответствует функции `int sys_exit(int status)`
    mov rbx,0        ; Задаем параметр status=0, для возврат 0 означает успешное выполнение
    int 0x80     ; Вызываем функции заданную в rax


; Создание исполняемого файла
; $ fasm hello_execute.asm
```

# Ортимизация

1.
```
`mov rbx,0` равносильно `xor rbx,rbx` но на 4 байта меньше
```

2.
```
 `mov rbx,1` 

 равносильно 

 `xor rbx,rbx
  inc rbx
 ` 
 но на 1 байт меньше
```


# [Разработка на ассемблере в Linux](https://habr.com/ru/articles/79454/)

[Ghex](https://community.linuxmint.com/software/view/ghex)  - шестнадцатеричный файловый редактор для GNOME

[Ghex help](https://help.gnome.org/users/ghex/stable/ghex-getting-started.html.ru)

[gdb](https://community.linuxmint.com/software/view/gdb) - Assembly Language Debugger 

[gdb documentation](https://www.sourceware.org/gdb/documentation/)

[OllyDbg](http://www.ollydbg.de/)

[IDA tools disassembler](https://hex-rays.com/ida-free/#download)

[disassembler object file to code](https://dogbolt.org/?id=762189b3-aa3d-4fab-bef1-37db63f7797e#Ghidra=1)

[disasm online to HEX](https://disasm.pro/)

### Системные вызовы

Linux предоставляет API. В большинстве случаев вызов системной функции производится с помощью прерывания `80h`. Следует отметить, что Linux используется fastcall-конвенция передачи параметров. Согласно ей параметры передаются через регистры. Номер вызываемой функции кладется в `eax`, а параметры в регистры `ebx,ecx,edx,esi,edi,ebp`

```
№  - Номер параметра вызоваемой ф-ции  

№   64bit                 32bit              16 bit     8 bit
sys  rax (8 byte)         eax  (4 byte)      ax         ah/al сумматор
1    rbx                  ebx                bx         dh/dl базовый регистр
2    rcx                  ecx                cx         ch/cl счетчик
3    rdx                  edx                dx         dh/dl регистр данных
4    rsi                  esi                si
5    rdi                  edi                di
6    rbp                  ebp
7    rsp                  esp

mm0 .. mm7 ; 64 bits
r8 .. r15 ; 64 bits
```

[Узнать номер системной функции, ее описание и параметры](http://www.unusedino.de/linuxassembly/syscall.html). 
Возьмем, к примеру `int sys_exit(int status)`, она имеет порядковый номер 1 и у нее есть один параметр — код возврата:

```
1. sys_exit
Syntax: int sys_exit(int status)
Source: kernel/exit.c
Action: terminate the current process
Details: status is return code
```

Таким образом мы можем вызвать ее следующим кодом:

```
mov eax, 1    ; 1 - номер системной функции
sub ebx, ebx  ; Задаем параметр status,Кладем 0 в регистр (можно было записать `mov ebx, 0`)
int 80h       ; Вызываем функции заданную в eax
```

Пример вывод сообщения - Hello world!

```
    format ELF executable 3
    entry start

    segment readable executable

    start:

    mov eax,4         ; Назначаем для вызова системную функции, где 4 - соответствует функции `ssize_t sys_write(unsigned int fd, const char * buf, size_t count)`
    mov ebx,1         ; Задаем параметр fd, где 1 - это stdout дескриптор потока вывода 
    mov ecx,msg       ; Задаем параметр buf, указатель на строку
    mov edx,msg_size  ; Задаем параметр count, размер строки
    int 0x80          ; Вызываем функции заданную в eax

    mov eax,1         ; 1 - номер системной функции `int sys_exit(int status)`
    xor ebx,ebx       ; Задаем параметр status 
    int 0x80          ; Вызываем функции заданную в eax

    segment readable writeable

    msg db 'Hello world!', 0xA, 0  ; задаем переменной msg  типом db.Еще строки должны иметь окончание 0, перенос строки 0xA
    msg_size = $-msg          ; $-msg это длина полученная вычитанием адрессов, где $ текушая точка,отнять адресс msg. Т.е. позиция важна!
```

Пример с промежуточным этапом создания обьектного файла:
```
format ELF64
public _start    ; процедура точка входа, public для видимости

_start:          ; аналог главной ф-ции main
    call _exit   ; вызов процедуры _exit. Вызов пользовательских процедур это прыжок к строке обьявления с дальнейшим выполнением построчно кода (как goto)

_exit:           ; процедура для выхода
    mov rax,1        ; Назначаем для вызова системную функции, где 1 - соответствует функции `int sys_exit(int status)`
    mov rbx,0        ; Задаем параметр status=0, для возврат 0 означает успешное выполнение
    int 0x80     ; Вызываем функции заданную в rax

; Создание обьектного файла
; $ fasm hello.asm 

; Линковка в исполняемый файл
; $ ld hello.o -o hello   
```

 

# disassembler

```
IDA -> View-A

; Attributes: noreturn

public start
start proc near
mov     eax, 4
mov     ebx, 1          ; fd
mov     ecx, offset unk_8049093 ; addr
mov     edx, 0Dh
int     80h             ; LINUX - sys_write
mov     eax, 1
xor     ebx, ebx        ; status
start endp


IDA -> Hex View-1

08048030  00 00 00 00 01 00 00 00  00 00 00 00 00 80 04 08  ................
08048040  00 80 04 08 93 00 00 00  93 00 00 00 05 00 00 00  ................
08048050  00 10 00 00 01 00 00 00  93 00 00 00 93 90 04 08  ................
08048060  93 90 04 08 0D 00 00 00  0D 00 00 00 06 00 00 00  ................
08048070  00 10 00 00 B8 04 00 00  00 BB 01 00 00 00 B9 93  ................
08048080  90 04 08 BA 0D 00 00 00  CD 80 B8 01 00 00 00 31  ...............1
08048090  DB CD 80                                          ...             
08049090           48 65 6C 6C 6F  20 77 6F 72 6C 64 21 0A     Hello world!.
```

```
Editor Ghex

$ ghex hello_world

08048030  00 00 00 00 01 00 00 00  00 00 00 00 00 80 04 08  ................
08048040  00 80 04 08 93 00 00 00  93 00 00 00 05 00 00 00  ................
08048050  00 10 00 00 01 00 00 00  93 00 00 00 93 90 04 08  ................
08048060  93 90 04 08 0D 00 00 00  0D 00 00 00 06 00 00 00  ................
08048070  00 10 00 00 B8 04 00 00  00 BB 01 00 00 00 B9 93  ................
08048080  90 04 08 BA 0D 00 00 00  CD 80 B8 01 00 00 00 31  ...............1
08048090  DB CD 80                                          ...             
08049090           48 65 6C 6C 6F  20 77 6F 72 6C 64 21 0A     Hello world!.

```

```
$ objdump -S -M intel -d hello
$ objdump -D -M intel hello

hello:     формат файла elf32-i386


Дизассемблирование раздела .text:

08048080 <.text>:
 8048080:       ba 0e 00 00 00          mov    edx,0xe
 8048085:       b9 a0 90 04 08          mov    ecx,0x80490a0
 804808a:       bb 01 00 00 00          mov    ebx,0x1
 804808f:       b8 04 00 00 00          mov    eax,0x4
 8048094:       cd 80                   int    0x80
 8048096:       b8 01 00 00 00          mov    eax,0x1
 804809b:       cd 80                   int    0x80

Дизассемблирование раздела .data:

080490a0 <.data>:
 80490a0:       48                      dec    eax
 80490a1:       65 6c                   gs ins BYTE PTR es:[edi],dx
 80490a3:       6c                      ins    BYTE PTR es:[edi],dx
 80490a4:       6f                      outs   dx,DWORD PTR ds:[esi]
 80490a5:       2c 20                   sub    al,0x20
 80490a7:       77 6f                   ja     0x8049118
 80490a9:       72 6c                   jb     0x8049117
 80490ab:       64 21 0a                and    DWORD PTR fs:[edx],ecx
```

```
$ objdump -D -b binary -m i386 hello_world

hello_world:     формат файла binary


Дизассемблирование раздела .data:

00000000 <.data>:
   0:   7f 45                   jg     0x47
   2:   4c                      dec    %esp
   3:   46                      inc    %esi
   4:   01 01                   add    %eax,(%ecx)
   6:   01 03                   add    %eax,(%ebx)
        ...
  10:   02 00                   add    (%eax),%al
  12:   03 00                   add    (%eax),%eax
  14:   01 00                   add    %eax,(%eax)
  16:   00 00                   add    %al,(%eax)
  18:   74 80                   je     0xffffff9a
  1a:   04 08                   add    $0x8,%al
  1c:   34 00                   xor    $0x0,%al
        ...
  26:   00 00                   add    %al,(%eax)
  28:   34 00                   xor    $0x0,%al
  2a:   20 00                   and    %al,(%eax)
  2c:   02 00                   add    (%eax),%al
  2e:   28 00                   sub    %al,(%eax)
  30:   00 00                   add    %al,(%eax)
  32:   00 00                   add    %al,(%eax)
  34:   01 00                   add    %eax,(%eax)
  36:   00 00                   add    %al,(%eax)
  38:   00 00                   add    %al,(%eax)
  3a:   00 00                   add    %al,(%eax)
  3c:   00 80 04 08 00 80       add    %al,-0x7ffff7fc(%eax)
  42:   04 08                   add    $0x8,%al
  44:   93                      xchg   %eax,%ebx
  45:   00 00                   add    %al,(%eax)
  47:   00 93 00 00 00 05       add    %dl,0x5000000(%ebx)
  4d:   00 00                   add    %al,(%eax)
  4f:   00 00                   add    %al,(%eax)
  51:   10 00                   adc    %al,(%eax)
  53:   00 01                   add    %al,(%ecx)
  55:   00 00                   add    %al,(%eax)
  57:   00 93 00 00 00 93       add    %dl,-0x6d000000(%ebx)
  5d:   90                      nop
  5e:   04 08                   add    $0x8,%al
  60:   93                      xchg   %eax,%ebx
  61:   90                      nop
  62:   04 08                   add    $0x8,%al
  64:   0d 00 00 00 0d          or     $0xd000000,%eax
  69:   00 00                   add    %al,(%eax)
  6b:   00 06                   add    %al,(%esi)
  6d:   00 00                   add    %al,(%eax)
  6f:   00 00                   add    %al,(%eax)
  71:   10 00                   adc    %al,(%eax)
  73:   00 b8 04 00 00 00       add    %bh,0x4(%eax)
  79:   bb 01 00 00 00          mov    $0x1,%ebx
  7e:   b9 93 90 04 08          mov    $0x8049093,%ecx
  83:   ba 0d 00 00 00          mov    $0xd,%edx
  88:   cd 80                   int    $0x80
  8a:   b8 01 00 00 00          mov    $0x1,%eax
  8f:   31 db                   xor    %ebx,%ebx
  91:   cd 80                   int    $0x80
  93:   48                      dec    %eax
  94:   65 6c                   gs insb (%dx),%es:(%edi)
  96:   6c                      insb   (%dx),%es:(%edi)
  97:   6f                      outsl  %ds:(%esi),(%dx)
  98:   20 77 6f                and    %dh,0x6f(%edi)
  9b:   72 6c                   jb     0x109
  9d:   64 21 0a                and    %ecx,%fs:(%edx)

```

```
$ readelf -a hello_world

Заголовок ELF:
  Magic:   7f 45 4c 46 01 01 01 03 00 00 00 00 00 00 00 00 
  Класс:                             ELF32
  Данные:                            дополнение до 2, от младшего к старшему
  Version:                           1 (current)
  OS/ABI:                            UNIX - GNU
  Версия ABI:                        0
  Тип:                               EXEC (Исполняемый файл)
  Машина:                            Intel 80386
  Версия:                            0x1
  Адрес точки входа:               0x8048074
  Начало заголовков программы:          52 (байт в файле)
  Начало заголовков раздела:          0 (байт в файле)
  Флаги:                             0x0
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         2
  Size of section headers:           40 (bytes)
  Number of section headers:         0 (1)
  Section header string table index: 0
readelf: Предупреждение: Раздел 0 находится вне диапазона значения sh_link, равное 134512756

Заголовок раздела:
  [Нм] Имя               Тип             Адрес    Смещ   Разм   ES Флг Сс Инф Al
readelf: Предупреждение: [ 0]: непредвиденное значение (52) в поле информации
  [ 0] <��� �����>[...]  03010101: <не 00000000 030002 000001 00     134512756  52  0
readelf: Предупреждение: раздел 0: размер sh_link у 134512756 больше чем количество разделов
Обозначения флагов:
  W (запись), A (назнач), X (исполняемый), M (слияние), S (строки),
  I (инфо), L (порядок ссылок), O (требуется дополнительная работа ОС),
  G (группа), T (TLS), C (сжат), x (неизвестно), o (специфич. для ОС),
  E (исключён),
  R (retain), D (mbind), p (processor specific)

В этом файле нет групп разделов.

Заголовки программы:
  Тип            Смещ.    Вирт.адр   Физ.адр    Рзм.фйл Рзм.пм  Флг Выравн
  LOAD           0x000000 0x08048000 0x08048000 0x00093 0x00093 R E 0x1000
  LOAD           0x000093 0x08049093 0x08049093 0x0000d 0x0000d RW  0x1000

В этом файле нет динамического раздела.

В этом файле нет перемещений.
No processor specific unwind information to decode

В этом файле не найдена информация о версии.
```

# Язык Ассемблера #1/2 [FASM, Linux, x86-64]

[CryptoFun [ IT ]](https://www.youtube.com/watch?v=TuNiVG2hYuU&t=9s)




# Tempesta Torres Assembler

[Assembler Tempesta Torres](https://www.youtube.com/watch?v=1-ktz0fkCjg&t=29s)

[Intel 80386](https://ru.wikipedia.org/wiki/Intel_80386) 

[x86](https://ru.wikipedia.org/wiki/X86)

[Executable and Linkable Format](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format)

Семейство процессоров 86 для INTEL

[label:] opcode [operands] [;comment]


```
$ fasm --help
flat assembler  version 1.73.31
usage: fasm <source> [output]
optional settings:
 -m <limit>         установить лимит доступной памяти в килобайтах
 -p <limit>         установить максимально разрешенное количество проходов
 -d <name>=<value>  определить символьную переменную
 -s <file>          dump символической информации для debugging

```
 