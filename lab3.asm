        ; -----------------------------------------------------------------------
        ; Okunan işaretli iki sayının toplamını hesaplayıp ekrana yazdırır.
        ; ANA 		: Ana yordam 
        ; PUT_STR 	: Ekrana sonu 0 ile belirlenmiş dizgeyi yazdırır. 
        ; PUTC 	: AL deki karakteri ekrana yazdırır. 
        ; GETC 	: Klavyeden basılan karakteri AL’ye alır.
        ; PUTN 	: AX’deki sayeyi ekrana yazdırır. 
        ; GETN 	: Klavyeden okunan sayeyi AX’e koyar
        ; -----------------------------------------------------------------------
GIRIS_DIZI	MACRO SAYILAR
			LOCAL LGSRDIZI
			POP CX
			MOV DX, CX 					;n degerini dxe aktar sonra MY_MOD yordaminda kullanilacak
			MOV DI, 0
LGRSDIZI:	MOV AX, OFFSET MSG2
			CALL PUT_STR			        ; MSG2’i göster 
			XOR AX, AX
			CALL GETN  			        ; oku AX'e yaz	
			MOV SAYILAR[DI], AX				
			ADD DI,2
			LOOP LGRSDIZI					;CX yani n kadar donecek
			ENDM	

SSEG 	SEGMENT PARA STACK 'STACK'
	DW 100 DUP (?)
SSEG 	ENDS

DSEG	SEGMENT PARA 'DATA'
CR	EQU 13
LF	EQU 10
MSG1	DB CR, LF, 'Dizinin kac sayi oldugunu giriniz(En fazla 10): ',0
MSG2	DB CR, LF, 'Tam sayi giriniz: ', 0
MSG3	DB CR, LF, 'Tekrar sayisi: ', 0
MSG4	DB CR, LF, 'KARA GORUNDU ', 0
HATA	DB CR, LF, 'Dikkat !!! Sayi vermediniz yeniden giris yapiniz.!!!  ', 0
SONUC	DB CR, LF, 'Mod ', 0
frekans DW 1
moddegeri DW 1
maxmod  DW 1
elesay 	DW 1
SAYILAR DW 10 DUP(0) 
DSEG 	ENDS 

CSEG 	SEGMENT PARA 'CODE'
	ASSUME CS:CSEG, DS:DSEG, SS:SSEG
ANA 	PROC FAR
        PUSH DS
        XOR AX,AX
        PUSH AX
        MOV AX, DSEG 
        MOV DS, AX
		MOV AX, OFFSET MSG1
        CALL PUT_STR			        ; MSG1’i göster 
		XOR AX, AX
        CALL GETN  			        ; n’i oku 
        MOV CX, AX					; dizinin eleman sayisi
		PUSH CX						;CX stacke aktarildi giris_dizide kullanilacak
		GIRIS_DIZI SAYILAR
		MOV CX, DX
		MOV DI, 0
DIZIPOP:MOV AX, SAYILAR[DI]
		PUSH AX
		ADD DI, 2
		LOOP DIZIPOP
		PUSH DX
		CALL MY_MOD		        
        POP BX						; Sonucu göster			         
		POP AX						; modu yaz
        RETF 
ANA 	ENDP

GETC	PROC NEAR
        ;------------------------------------------------------------------------
        ; Klavyeden basılan karakteri AL yazmacına alır ve ekranda gösterir. 
        ; işlem sonucunda sadece AL etkilenir. 
        ;------------------------------------------------------------------------
        MOV AH, 1h
        INT 21H
        RET 
GETC	ENDP 

PUTC	PROC NEAR
        ;------------------------------------------------------------------------
        ; AL yazmacındaki değeri ekranda gösterir. DL ve AH değişiyor. AX ve DX 
        ; yazmaçlarının değerleri korumak için PUSH/POP yapılır. 
        ;------------------------------------------------------------------------
        PUSH AX
        PUSH DX
        MOV DL, AL
        MOV AH,2
        INT 21H
        POP DX
        POP AX
        RET 
PUTC 	ENDP 

GETN 	PROC NEAR
        ;------------------------------------------------------------------------
        ; Klavyeden basılan sayiyi okur, sonucu AX yazmacı üzerinden dondurur. 
        ; DX: sayının işaretli olup/olmadığını belirler. 1 (+), -1 (-) demek 
        ; BL: hane bilgisini tutar 
        ; CX: okunan sayının islenmesi sırasındaki ara değeri tutar. 
        ; AL: klavyeden okunan karakteri tutar (ASCII)
        ; AX zaten dönüş değeri olarak değişmek durumundadır. Ancak diğer 
        ; yazmaçların önceki değerleri korunmalıdır. 
        ;------------------------------------------------------------------------
        PUSH BX
        PUSH CX
        PUSH DX
GETN_START:
        MOV DX, 1	                        ; sayının şimdilik + olduğunu varsayalım 
        XOR BX, BX 	                        ; okuma yapmadı Hane 0 olur. 
        XOR CX,CX	                        ; ara toplam değeri de 0’dır. 
NEW:
        CALL GETC	                        ; klavyeden ilk değeri AL’ye oku. 
        CMP AL,CR 
        JE FIN_READ	                        ; Enter tuşuna basilmiş ise okuma biter
        CMP  AL, '-'	                        ; AL ,'-' mi geldi ? 
        JNE  CTRL_NUM	                        ; gelen 0-9 arasında bir sayı mı?
NEGATIVE:
        MOV DX, -1	                        ; - basıldı ise sayı negatif, DX=-1 olur
        JMP NEW		                        ; yeni haneyi al
CTRL_NUM:
        CMP AL, '0'	                        ; sayının 0-9 arasında olduğunu kontrol et.
        JB error 
        CMP AL, '9'
        JA error		                ; değil ise HATA mesajı verilecek
        SUB AL,'0'	                        ; rakam alındı, haneyi toplama dâhil et 
        MOV BL, AL	                        ; BL’ye okunan haneyi koy 
        MOV AX, 10 	                        ; Haneyi eklerken *10 yapılacak 
        PUSH DX		                        ; MUL komutu DX’i bozar işaret için saklanmalı
        MUL CX		                        ; DX:AX = AX * CX
        POP DX		                        ; işareti geri al 
        MOV CX, AX	                        ; CX deki ara değer *10 yapıldı 
        ADD CX, BX 	                        ; okunan haneyi ara değere ekle 
        JMP NEW 		                ; klavyeden yeni basılan değeri al 
ERROR:
        MOV AX, OFFSET HATA 
        CALL PUT_STR	                        ; HATA mesajını göster 
        JMP GETN_START                          ; o ana kadar okunanları unut yeniden sayı almaya başla 
FIN_READ:
        MOV AX, CX	                        ; sonuç AX üzerinden dönecek 
        CMP DX, 1	                        ; İşarete göre sayıyı ayarlamak lazım 
        JE FIN_GETN
        NEG AX		                        ; AX = -AX
FIN_GETN:
        POP DX
        POP CX
        POP BX
        RET 
GETN 	ENDP 

PUTN 	PROC NEAR
        ;------------------------------------------------------------------------
        ; AX de bulunan sayiyi onluk tabanda hane hane yazdırır. 
        ; CX: haneleri 10’a bölerek bulacağız, CX=10 olacak
        ; DX: 32 bölmede işleme dâhil olacak. Soncu etkilemesin diye 0 olmalı 
        ;------------------------------------------------------------------------
        PUSH CX
        PUSH DX 	
        XOR DX,	DX 	                        ; DX 32 bit bölmede soncu etkilemesin diye 0 olmalı 
        PUSH DX		                        ; haneleri ASCII karakter olarak yığında saklayacağız.
                                                ; Kaç haneyi alacağımızı bilmediğimiz için yığına 0 
                                                ; değeri koyup onu alana kadar devam edelim.
        MOV CX, 10	                        ; CX = 10
        CMP AX, 0
        JGE CALC_DIGITS	
        NEG AX 		                        ; sayı negatif ise AX pozitif yapılır. 
        PUSH AX		                        ; AX sakla 
        MOV AL, '-'	                        ; işareti ekrana yazdır. 
        CALL PUTC
        POP AX		                        ; AX’i geri al 
        
CALC_DIGITS:
        DIV CX  		                ; DX:AX = AX/CX  AX = bölüm DX = kalan 
        ADD DX, '0'	                        ; kalan değerini ASCII olarak bul 
        PUSH DX		                        ; yığına sakla 
        XOR DX,DX	                        ; DX = 0
        CMP AX, 0	                        ; bölen 0 kaldı ise sayının işlenmesi bitti demek
        JNE CALC_DIGITS	                        ; işlemi tekrarla 
        
DISP_LOOP:
                                                ; yazılacak tüm haneler yığında. En anlamlı hane üstte 
                                                ; en az anlamlı hane en alta ve onu altında da 
                                                ; sona vardığımızı anlamak için konan 0 değeri var. 
        POP AX		                        ; sırayla değerleri yığından alalım
        CMP AX, 0 	                        ; AX=0 olursa sona geldik demek 
        JE END_DISP_LOOP 
        CALL PUTC 	                        ; AL deki ASCII değeri yaz
        JMP DISP_LOOP                           ; işleme devam
        
END_DISP_LOOP:
        POP DX 
        POP CX
        RET
PUTN 	ENDP 

PUT_STR	PROC NEAR
        ;------------------------------------------------------------------------
        ; AX de adresi verilen sonunda 0 olan dizgeyi karakter karakter yazdırır.
        ; BX dizgeye indis olarak kullanılır. Önceki değeri saklanmalıdır. 
        ;------------------------------------------------------------------------
	PUSH BX 
        MOV BX,	AX			        ; Adresi BX’e al 
        MOV AL, BYTE PTR [BX]	                ; AL’de ilk karakter var 
PUT_LOOP:   
        CMP AL,0		
        JE  PUT_FIN 			        ; 0 geldi ise dizge sona erdi demek
        CALL PUTC 			        ; AL’deki karakteri ekrana yazar
        INC BX 				        ; bir sonraki karaktere geç
        MOV AL, BYTE PTR [BX]
        JMP PUT_LOOP			        ; yazdırmaya devam 
PUT_FIN:
	POP BX
	RET 
PUT_STR	ENDP

MY_MOD	PROC NEAR
        ;------------------------------------------------------------------------
		; MAX frekans ve mod değeri pop ile ana yordama yollanacak
		; N degerini de buraya getirmemiz lazim
        ;------------------------------------------------------------------------
			POP CX			;CX=n degerini DX'den stackin en ustunden cekip aldik
			MOV SI, CX      ;yine n degerini dongude kullanmak uzere SI'ya aktariyoruz
			XOR DX, DX 		;DX'i sifirladik dongudeki modu sakladigimiz yazmac
			MOV DI, 0
DIZIDOLDUR:	POP AX					;Stackteki degerleri sayilar dizisine aktar
			MOV SAYILAR[DI], AX
			ADD DI, 2
			DEC SI
			CMP SI, 0
			JE DIZIDOLDUR
			MOV SI, CX				;dongu oncesi hazirliklar
			MOV elesay, CX			;eleman sayisi
			MOV AX, OFFSET MSG4
			CALL PUT_STR
			MOV SI, 0
	DISDNG: MOV AX, SAYILAR[SI]		;0'dan n'e kadar kontrol edilecek dongu basliyor
			MOV frekans, 0			;kontrol edilen sayinin frekansi sifir belirleniyor
			MOV DI, SI
	ICDNG:	MOV BX, SAYILAR[DI]
			CMP AX, BX
			JNE NOESIT
			ADD frekans, 1
			CMP DX, frekans
			JGE NOESIT
			MOV DX, frekans			;mod kac defa tekrar ediyor
			MOV moddegeri, AX
	NOESIT:	ADD DI, 2
			MOV BX, CX
			SHL BX, 1
			CMP DI, BX
			JL  ICDNG
			ADD SI, 2
			LOOP DISDNG
			MOV BX,moddegeri
			
			PUSH BX				;mod hangi sayi
			PUSH DX				;mod kac defa tekrar ediyor
		
        RET
MY_MOD 	ENDP 

CSEG 	ENDS 
	END ANA
