format PE console

entry start

include 'ENCODING\win1251.inc'
include 'win32a.inc'

section '.data' data readable writeable

    metkaStr du '�ਢ�� ���!', 0 ; ������� ����� � ��⪮� metkaStr ⨯� db (1����). �� �������樨 �ॢ�頥��� � 㪠��⥫� �� �����
    NULL = 0 ; ᮧ���� ����⠭�� �� �㫥��� 㪠��⥫�.�� �������樨 ����⠢���� ���祭��

section '.code' code readable executable

    start:
            push metkaStr ; �������� � �⥪ ��ப�
            call [printf] ; �맮� �-樨 printf �� �� �����  , ��� ��뢠���� � ����� ��ࠬ��஬ �� �⥪�


            call [getch] ; 䨪���� ���� � �����
            push NULL ;������ � �⥪ NULL
            call [ExitProcess] ; �맮� �-樨 ExitProcess �� �� ����� � ��ࠬ��஬ �� �⥪� NULL

section '.import' import data readable

    library kernel32, 'kernel32.dll', \
            msvcrt, 'msvcrt.dll'

    import kernel32, \
           ExitProcess, 'ExitProcess'

    import msvcrt, \
         printf, 'printf',\
         getch,'_getch'

;������⥪�
 ;getch - 䨪���� ���� � �����
 ;printf - ����� � ��⮪ �뢮��
 ;ExitProcess - �����襭�� �����
 
 
