;========================================================================================
;
;	CODIGO FUENTE PARA LA TAREA , MICROCOMPUTADORAS, SEMESTRE 2023-II
;
;	MICROCONTROLADOR: PIC16F877A
;	
;	FECHA: 5 DE MARZO DE 2023
;
;	MOISES MELENDEZ (moises.melendez@fi-b.unam.mx)
;
;========================================================================================
;	LIBRERIAS
;========================================================================================
#INCLUDE <P16F877A.INC>		;LIBRERIA CON DEFINICIONES PARA EL MICRO UTILIZADO

;========================================================================================
;	DECLARACION DE REGISTROS Y VALORES
;========================================================================================
VALOR1 EQU 0X7D				;
VALOR2 EQU 0X7E				;
VALOR3 EQU 0X7F				;REGISTROS PARA LA SUBRUTINA DE RETARDO

CONST1 EQU  .10				;   TIEMPO = CONST1 X 10 ms
CONST2 EQU  .200			;
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
   	CLRF PORTA			;CONFIGURACIONES INICIALES
	CLRF PORTB			;LIMPIA LOS PUERTO A Y B
	
	BSF STATUS,RP0		;
	BCF STATUS,RP1		;CAMBIA AL BANCO 1 DE RAM

	MOVLW 0X07			;
	MOVWF ADCON1		;CONFIGURA LOS PINES DEL PUERTO A COMO I/O DIGITALES

	MOVLW H'3F' 		;
	MOVWF TRISA			;CONFIGURA EL PUERTO A COMO ENTRADAS

	CLRF TRISB			;CONFIGURA EL PUERTO B COMO SALIDAS

	BCF STATUS,RP0 		;REGRESA AL BANCO 0 DE RAM

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
	GOTO SEC_03			;PC + 2 --> SECUENCIA 3		"CONTADOR DESCENDENTE"
	GOTO SEC_04			;PC + 3 --> SECUENCIA 4		"SECUENCIA PERSONALIZADA"

SEC_01:					;"PRENDE - APAGA"
	MOVLW .255
	MOVWF PORTB			;(PORTB) <-- 0XFF
	MOVLW .50
	CALL RETARDO
	CLRF PORTB			;(PORTB) <-- 0X00
	MOVLW .50
	CALL RETARDO
	GOTO LOOP

SEC_02:					;"CONTADOR ASCENDENTE"
	INCF CONTADOR,F		;(CONTADOR) <-- (CONTADOR) + 1
	MOVF CONTADOR,W		;W <-- (CONTADOR)
	MOVWF PORTB			;(PORTB) <-- W
	MOVLW .25
	CALL RETARDO					
	GOTO LOOP

SEC_03:					;"CONTADOR DESCENDENTE"
	DECF CONTADOR,F		;(CONTADOR) <-- (CONTADOR) - 1
	MOVF CONTADOR,W		;W <-- (CONTADOR)
	MOVWF PORTB			;(PORTB) <-- W
	MOVLW .25
	CALL RETARDO					
	GOTO LOOP

SEC_04:					;"SECUENCIA PERSONALIZADA"
	INCF INDICE,F		;(INDICE) <-- (INDICE) + 1
	MOVF INDICE,W		;W <-- (INDICE)
	CALL SECUENCIA		;LLAMA A LA SUBRUTINA DE SECUENCIAS PERSONALIZADAS CON
						;EL VALOR DEL INDICE EN W         "PASO DE VALOR EN W"
	MOVWF PORTB			;(PORTB) <-- W
	MOVLW .10
	CALL RETARDO		
	GOTO LOOP

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

	RETLW B'00000000'	;MOVLW K   +    RETURN
	RETLW B'00011000'	;
	RETLW B'00111100'	;
	RETLW B'01111110'	;
	RETLW B'11111111'	;
	RETLW B'11100111'	;
	RETLW B'11000011'	;
	RETLW B'10000001'	;

;========================================================================================
;	FIN DEL CODIGO FUENTE
;========================================================================================
	END

;========================================================================================