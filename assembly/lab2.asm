mys		SEGMENT PARA 'ortak'
			ORG 100H
			ASSUME CS:mys, SS:mys, DS:mys
BASLA:		JMP HIP
primeOddSum	  DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
nonPrimeOrEvenSum  DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
HIP			PROC NEAR
			MOV CX, 5
			LEA DI, nonPrimeOrEvenSum
			LEA BP, primeOddSum
DISDONGU:	MOV BL, 2         ; a = 2
ICDONGUA:	CMP BL, CL 		; a ve cyi karsilastir
			JGE DISDONGU_SON 	; eger a >= c is disdongunun sonuna git
			MOV DL, BL				; b = a ,,, DL=b, BL=a, CL=c
ICDONGUB:	CMP DL, CL       ; b ve cyi karsilastir
			JGE ICDONGUA_BITIR ; eger b >= c, ic dongu bden cik
			MOV AL, BL ;  a^2 + b^2
			MUL BL		     ; AX = a * a
			PUSH AX
			MOV AL, DL
			MUL DL      ; AX = b * b
			POP SI
			ADD AX, SI       ; AX = a * a + b * b
			PUSH AX
			MOV AL, CL ;  c^2
			MUL CL      ; AX = c * c
			POP SI
			CMP AX, SI ;  a^2 + b^2 ile c^2 kiyasla
			JNE ICDONGUB_SON ; eger a^2 + b^2 != c^2, asal kontrolunu gec
    			PUSH DX
    			MOV DL, 2         ; i'yi 2den baslat primecontrol basi
			LOOPPRIME:MOV AL, DL       ; AL = i
    					MUL DL		 ; AX = i*i
    					CMP AL, CL       ;  i * i 'yi c ile kiyasla
    					JG ISPRIME       ; eger i * i > c is ISPRIME'a zıpla
						MOV AL, CL		; AL = c
					DIV DL           ; c'yi i'ye bol
					CMP AH, 0        ; kalani kontrol et
					JE NOTPRIME      ; eger kalan 0 ise c asal degil
					INC DX           ; i++
					JMP LOOPPRIME	 ; donguyu tekrarla
			NOTPRIME:POP DX
					MOV [DI], CL 	;diziye ekle
					INC DI			;dizinin indisini arttir
					JMP ICDONGUB_SON
			ISPRIME:POP DX
					MOV [BP], CL	;diziye ekle
					INC BP			;dizinin indisini arttir
					JMP ICDONGUB_SON
ICDONGUB_SON:INC DL            ; b++
			JMP ICDONGUB   ; icdongubyi tekrarla
ICDONGUA_BITIR:INC BL            ; a++
			JMP ICDONGUA   ; icdonguayi tekrarla
DISDONGU_SON:INC CL            ; c++
			CMP CL, 51        ;
			JE BITTI	  ; eger c > 50 ise programi bitir
			JMP DISDONGU     ; disdonguye yeniden gir
BITTI:		RET
HIP			ENDP
mys			ENDS
			END BASLA