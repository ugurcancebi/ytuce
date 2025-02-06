datasg		SEGMENT PARA 'veri'
VIZE			DB 77, 85, 64, 96
FINAL			DB 56, 63, 86, 74
OBP			DB 0, 0, 0, 0
datasg		ENDS
stacksg		SEGMENT PARA STACK 'yigin'
			DW 12 DUP(?)
stacksg		ENDS
codesg		SEGMENT PARA 'kod'
			ASSUME DS:datasg, SS:stacksg, CS:codesg
ORBAPU		PROC FAR
			PUSH DS
			XOR AX, AX
			PUSH AX
			MOV AX, datasg
			MOV DS, AX

			
			
			MOV CX, 4		;ilk döngü OBP'leri bulacak
			LEA SI, VIZE
			LEA DI, FINAL
			LEA BX, OBP
                  
J1:    			MOV AL, [SI]       	; VIZE dizisindekini ALye at
			MOV AH, 4          	; 4le carpmak icin 
			MUL AH             	; AX = AL * 4
			ADD AX, 5          	; AX = AX + 5
			MOV DL, 10         	; Boleni 10 yap
			DIV DL             	; AXi 10a bol sonuc AL kalan AH
			MOV DH, AL         	; Sonucu DHye at Boylece yuvarlama islemi yapildi
    
			MOV AL, [DI]       	; FINAL dizisindekini ALye at
			MOV AH, 6          	; 6 ile carpilacak
			MUL AH             	; AX = AL * 6
			ADD AX, 5          	; AX = AX + 5
			MOV DL, 10         	; Boleni 10 yap
			DIV DL			; AXi 10a bol sonuc AL kalan AH Yine Yuvarlama islemi yapilmis oldu
			
			ADD AL, DH         	; VIZEL ve FINAL toplami
			MOV [BX], AL       	; OBPye aktar
    
			INC SI             	; Dizilerdeki sonraki elemana git
			INC DI             	
			INC BX             	 
    
    			LOOP J1			
			
			MOV CX, 3 		; Bubblesort icin ilk dongu n-1 yani 3
			MOV SI, 0


JD1:			MOV DI, SI		; DI her geciste dizi ogeleri uzerinde yineleme yapacaktır DIS DONGU
			MOV BX, CX		; BX ic dongu sayaci

JD2:			MOV AL, [DI]		; Simdiki eleman IC DONGU
			MOV DL, [DI+1]		; Sonraki

						; AX ve DX i karsilastir
			CMP AL, DL
			JLE JD3			; Eger simdiki eleman<=sonraki eleman yer degistirmeyi gec

			MOV [DI], DL 		; Sonraki elemani simdiki elemanin yerine al
			MOV [DI+1], AL		; Simdiki elemani sonraki elemanin yerine al

JD3:			INC DI			; Bir sonraki cifte gec
			DEC BX			; Ic dongu sayacini azalt
			JNZ JD2			; Eger BX 0 degilse ic donguyu tekrarla

			DEC CX			; Dis dongu sayacini azalt
			JNZ JD1			; CX 0 degilse basa don		
			
			RETF
ORBAPU			ENDP
codesg			ENDS
			END ORBAPU
			
			













