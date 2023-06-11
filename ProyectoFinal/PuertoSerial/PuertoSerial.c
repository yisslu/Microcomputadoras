#include <16f887.h>
#include<stdlib.h>
#include<stdio.h>

#fuses HS, NOWDT, NOPROTECT, NOLVP

#use delay(clock=20M)
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)
#use i2c(MASTER, SDA=PIN_C4, SCL=PIN_C3,SLOW, NOFORCE_SW)
//#include "i2c-lcd.c"
#include <lcd.c>

/* Definicion de constantes */
#define MAX_LINE 1 // Maximo de lineas que el usuario puede ingresar a la terminal

/* Prototipo de funciones */
void escribir_i2c();
void obtenerTemperatura();

int8 contador=0; //contador principal
int8 countAux = 0; //contador auxiliar
char getch(void);
float valor_temperatura = 0.0;

void obtenerTemperatura() {
    set_adc_channel(0);
    delay_ms(10);
    valor_temperatura = read_adc()*2;
}

void escribir_i2c(){
//!   printf("Escribir I2C\n");
//!   i2c_start();
//!   i2c_write(0x42); //Direcion del esclavo
//!   i2c_write(contador); //El dato a escribir
//!   i2c_stop();
}

/* Enviar al correo: moises.melendes@fi-b.unam.mx*/
/* Asunto: Diagrama Proteus Grupo 4*/
int main() {
   /* Configuracion */
    // Se configuran las interrupciones, el display LCD y el puerto A
    lcd_init();
    //enable_interrupts(INT_RB);
    enable_interrupts(GLOBAL);
    Setup_port_a(ALL_ANALOG);
    Setup_adc(ADC_CLOCK_INTERNAL);
   
   /*
   lcd_init(0x4E, 16, 2);
   while(true)
   {
      //Elige la posicion de escritura 
      lcd_gotoxy(0,2);
      //Imprime el contador
      printf(lcd_putc,"Contador = %d", contador);
      //Escribe el numero por i2c
      escribir_i2c();
      //Escribe el numero en el puerto b
      output_d(contador);
      delay_ms(500);
      //Aumenta los contadores
      contador++;
      countAux++;
      //Si se cuenta hasta 10, se aplica un corrimiento 
      //a la suma principal
      if(countAux == 10){
         countAux = 0;
         contador += 6 ;
      }
   }
   */
//!   char buf[20];
//!   char *ptr;
//!    char ch;
//!    ptr = buf;
//!    printf("Ingrese comando: \n\r");
//!    while ((ch = getchar()) != '\r') *ptr++ = (char)ch;
//!    *ptr++ = 0;
//! printf("The given string is : %s\n\r", buf);
    
    while (TRUE) {
        obtenerTemperatura();
        lcd_gotoxy(0, 1);
        printf(lcd_putc, "Temp.: %f C\n\r",valor_temperatura);
        delay_ms(200);
    }
    
//!   char n = 0;
//!   while(n < 100) {
//!      printf("%i\n\r", n);
//!      n++;
//!   }
   output_b(0xFF);
   return 0;
}

