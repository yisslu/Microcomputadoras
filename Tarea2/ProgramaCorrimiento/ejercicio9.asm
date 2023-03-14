processor 16f887
include <p16f887.inc>
valor1 equ h'21'
valor2 equ h'22'
valor3 equ h'23'
cte1 equ 20h
cte2 equ 50h
cte3 equ 60h
 	ORG 0
GOTO INICIO
	ORG 5
INICIO:
	BSF STATUS,RP0
 	BCF STATUS,RP1
 	MOVLW H'00'
 	MOVWF TRISB
 	BCF STATUS,RP0
 	MOVLW B'10000000'
	MOVWF PORTB
loop2
 	CALL retardo
	RRF PORTB
 	GOTO loop2
retardo 
	MOVLW cte1
 	MOVWF valor1
tres 
	MOVLW cte2
	MOVWF valor2
dos 
	MOVLW cte3
	MOVWF valor3
uno 
	DECFSZ valor3
 	GOTO uno
	DECFSZ valor2
	GOTO dos
	DECFSZ valor1
	GOTO tres
	RETURN
	END