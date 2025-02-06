PAGE 60,80
TITLE 8254 440 Hz nota üretme
STAK SEGMENT PARA STACK 'STACK'
DW 20 DUP(?)
STAK ENDS
DDATA SEGMENT
NOTALAR    DW 1090, 1090, 1090, 1374, 917, 1090, 1374, 917, 1090, 728, 728, 728, 687, 917, 1155, 1374, 917, 1090, 545, 1090, 1090, 545, 577, 612, 648, 728, 687, 0, 1029, 771, 817, 865, 917, 971, 917, 0, 1374, 1155, 1374, 1090 ; Notalarin byte degeri(240 kHz / frekans)
SURELER    DB  4,4,4,3,1,4,3,1,8,4,4,4,3,1,4,3,1,8,4,3,1,4,3,1,1,1,2,2,2,4,3,1,1,1,2,2,2,4,3,1
NOTASAYISI DW 40                            ; Number of notes in the melody
DDATA ENDS
CODE SEGMENT PARA 'CODE'
ASSUME CS:CODE, SS:STAK, DS:DDATA
START PROC FAR ; ana yordam
MOV AX, DDATA
MOV DS, AX

ENDLESS:
MOV AL, 00110110B
OUT 0AFH, AL ; CNTR0 16 bit, kip 3, binary

MOV SI, OFFSET NOTALAR ; notalar dizisi
MOV DI, OFFSET SURELER ; sureler dizisi
MOV CX, NOTASAYISI     ; notasayisi dongu sayisi

NOTACAL:
MOV AX, [SI]          ; simdiki frekansi al
OUT 0A9h, AL          ; dusuk buyuk kisimlar yollaniyor
MOV AL, AH            ; 
OUT 0A9h, AL          ; 
ADD SI, 2             ; 16 bit artacak

MOV AL, [DI]          ; notanin suresini al
PUSH CX
CALL DELAY            ; delay fonksiyonu cagir
POP CX
INC DI                ; bir sonraki sureler elemanina gec

LOOP NOTACAL

DELAY PROC NEAR	      ; delay dongusu
DISDONGU:
MOV CX, 2FFFH
BEKLE:
NOP
DEC CX
JNZ BEKLE
DEC AL	              ; notanin kac defa calinacagi/suresi
JNZ DISDONGU
RET
DELAY ENDP

JMP ENDLESS ; sonsuz döngü
START ENDP
CODE ENDS
END START