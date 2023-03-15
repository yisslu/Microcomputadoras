;========================================================================================
;
;	CODIGO FUENTE PARA LA TAREA , MICROCOMPUTADORAS, SEMESTRE 2023-II
;
;	MICROCONTROLADOR: PIC16F887
;	
;	FECHA: 5 DE MARZO DE 2023
;
;	MOISES MELENDEZ (moises.melendez@fi-b.unam.mx)
;
;========================================================================================
;	LIBRERIAS
;========================================================================================
#INCLUDE <P16F887.INC>		;LIBRERIA CON DEFINICIONES PARA EL MICRO UTILIZADO

;========================================================================================
;	DECLARACION DE REGISTROS Y VALORES
;========================================================================================
VALOR1 EQU 0X7D				;
VALOR2 EQU 0X7E				;
VALOR3 EQU 0X7F				;REGISTROS PARA LA SUBRUTINA DE RETARDO

CONST1 EQU  .1				;  
CONST2 EQU  .80				;
CONST3 EQU  .82				;VALORES PARA LOS REGISTROS DE LA SUBRUTINA DE RETARDO

;REGISTRO PARA EL CONTADOR
CONTADOR EQU 0X20

;REGISTRO PARA LA SECUENCIA PERSONALIZADA
INDICE EQU 0X21


;========================================================================================
;	VECTOR DE RESET
;========================================================================================
	ORG 0X0000			;VECTOR DE RESET
	CLRF PCLATH			;LIMPIA LA PARTE ALTA DEL PROGRAM COUNTER
	GOTO INICIO			;SALTO A LA DIRECCION DE INICIO

;========================================================================================
;	INICIO Y CONFIGURACIONES INICIALES
;========================================================================================
	ORG 0X0005			
INICIO:
	BANKSEL PORTA 		;
   	CLRF PORTA			;CONFIGURACIONES INICIALES
	CLRF PORTB			;LIMPIA LOS PUERTO A Y B
	
	BANKSEL ANSEL 		;
	CLRF ANSEL 			;PORTA COMO I/O DIGITAL 

	BANKSEL TRISA 		;
	MOVLW 0FFh 			;
	MOVWF TRISA 		;PORTA COMO ENTRDADAS

	BANKSEL ANSELH
	CLRF ANSELH
	BANKSEL TRISB
	CLRF TRISB			;PORTB COMO SALIDA

	BANKSEL PORTB		

	CLRF CONTADOR		;LIMPIA EL REGISTRO CONTADOR
	CLRF INDICE			;LIMPIA EL REGISTRO INDICE PARA LA SECUENCIA PERSONALIZADA	

;========================================================================================
;	PROGRAMA PRINCIPAL
;========================================================================================
LOOP:					;LOOP PRINCIPAL
	MOVF PORTA,W		;W <-- (PORTA)
	ANDLW 3				;W <-- W & 00000011
	ADDWF PCL,F			;(PCL) <-- (PCL) + W			
	GOTO SEC_01			;PC + 0 --> SECUENCIA 1		"PRENDE - APAGA"
	GOTO SEC_02			;PC + 1 --> SECUENCIA 2		"CONTADOR ASCENDENTE"
	GOTO SEC_03			;PC + 3 --> SECUENCIA 4		"SECUENCIA PERSONALIZADA"
	GOTO SEC_04			;PC + 2 --> SECUENCIA 3		"CONTADOR DESCENDENTE"

SEC_01:					;"PRENDE - APAGA"
	MOVLW H'01'
	MOVWF PORTB			;(PORTB) <-- 0XFF
	MOVLW .50
	CALL RETARDO
	CLRF PORTB			;(PORTB) <-- 0X00
	MOVLW .50
	CALL RETARDO
	GOTO LOOP

SEC_02:				;"CONTADOR ASCENDENTE"	
	CALL STOP	
	INCF CONTADOR,F	;(CONTADOR) <-- (CONTADOR) + 1
	MOVF CONTADOR,W		;W <-- (CONTADOR)
	MOVWF PORTB			;(PORTB) <-- W
	MOVLW .25
	CALL RETARDO					
	GOTO LOOP
STOP:
	MOVLW H'10' 
	SUBWF CONTADOR,0
	BTFSC STATUS, Z ;Z = 1
	GOTO LOOP
	RETURN

SEC_03:					;"SECUENCIA PERSONALIZADA"
	INCF INDICE,F		;(INDICE) <-- (INDICE) + 1
	MOVF INDICE,W		;W <-- (INDICE)
	CALL SECUENCIA		;LLAMA A LA SUBRUTINA DE SECUENCIAS PERSONALIZADAS CON					;EL VALOR DEL INDICE EN W         "PASO DE VALOR EN W"
	MOVWF PORTB			;(PORTB) <-- W
	MOVLW .10
	CALL RETARDO		
	GOTO LOOP

SEC_04:					;"CONTADOR DESCENDENTE"
	MOVFW CONTADOR
	MOVWF PORTB
	RLF CONTADOR,1
	CALL RETARDO
	BTFSS CONTADOR,0
	GOTO SEC_04
 	CALL RETARDO
 	GOTO LOOP
	;DECF CONTADOR,F		;(CONTADOR) <-- (CONTADOR) - 1
	;MOVF CONTADOR,W		;W <-- (CONTADOR)
	;MOVWF PORTB			;(PORTB) <-- W
	;MOVLW .25
	;CALL RETARDO					
	;GOTO LOOP

;========================================================================================
;	SUBRUTINAS
;========================================================================================

;===== SUBRUTINA DE RETARDO =============================================================
RETARDO:
 	;MOVLW  CONST1
	MOVWF  VALOR1		;CARGA LA CONSTANTE 1 AL REGISTRO 1
TRE MOVLW  CONST2
	MOVWF  VALOR2		;CARGA LA CONSTANTE 2 AL REGISTRO 2
DOS MOVLW  CONST3
	MOVWF  VALOR3		;CARGA LA CONSTANTE 3 AL REGISTRO 3
UNO DECFSZ VALOR3
	GOTO   UNO			;LOOP DE RETARDO INTERNO
	DECFSZ VALOR2
	GOTO   DOS			;LOOP DE RETARDO MEDIO
	DECFSZ VALOR1
	GOTO   TRE			;LOOP DE RETARDO EXTERNO
	RETURN

;=====SUBRUTINA PARA LA SECUENCIA PERSONALIZADA =========================================
SECUENCIA:
	ANDLW 7		  		;W <-- W & 0X07
	ADDWF PCL,1			;PC <-- PC + W

	RETLW B'00010001'	;MOVLW K   +    RETURN
	RETLW B'00110011'	;
	RETLW B'01110111'	;
	RETLW B'11111111'	;
	RETLW B'10001000'	;
	RETLW B'11001100'	;
	RETLW B'11101110'	;
	RETLW B'11111111'	;

;========================================================================================
;	FIN DEL CODIGO FUENTE
;========================================================================================
	END

;========================================================================================