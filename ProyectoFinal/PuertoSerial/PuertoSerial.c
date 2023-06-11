#include <16f887.h>
#include<stdlib.h>
#include<stdio.h>
#fuses HS, NOWDT, NOPROTECT, NOLVP
#use delay(clock=20M)
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)
#use i2c(MASTER, SDA=PIN_C4, SCL=PIN_C3,SLOW, NOFORCE_SW)
//#include "i2c-lcd.c"
#include <lcd.c>
/* Prototipo de funciones */
void escribir_i2c();
void obtenerTemperatura();
void leerEntrada(char *comando);
int analizaOpcion(char *comando);
int comparaStrings(char str1[], char str2[]);

int8 contador = 0; //contador principal
int8 countAux = 0; //contador auxiliar
char getch(void);
float valor_temperatura = 0.0;

int comparaStrings(char str1[], char str2[]) {
   for(int i = 0; i < strlen(str1); i++) {
      if(str1[i] != str2[i]) return 0;
   }
   return 1;
}
void obtenerTemperatura() {
    set_adc_channel(0);
    delay_ms(10);
    valor_temperatura = read_adc()*2;
}

void escribir_i2c(){
   i2c_start();
   i2c_write(0x42); //Direcion del esclavo
   i2c_write(contador); //El dato a escribir
   i2c_stop();
}

void leerEntrada(char *comando) {
   char *ptr;
   char ch;
   
   ptr = comando;
   printf("Ingrese comando: \n\r");
   
   while ((ch = getchar()) != '\r') {printf("%c", ch);*ptr++ = (char)ch;} 
   printf("\n\r");
   *ptr++ = 0;
   
   printf("The given string is : %s\n\r", comando);
}

int analizaOpcion(char *comando) {
   char *temperaturaString = "temperatura", 
        *pwm = "pwm", 
        *motor = "motor", 
        *leds = "leds";
   
   if(comparaStrings(comando, temperaturaString)) return 0;
   else if(comparaStrings(comando, pwm)) return 1;
   else if(comparaStrings(comando, motor)) return 2;
   else if(comparaStrings(comando, leds)) return 3; 
  
   return -1;
}

int main() {
   /* Configuracion */
    lcd_init();
    enable_interrupts(INT_RB);
    enable_interrupts(GLOBAL);
    Setup_port_a(ALL_ANALOG);
    Setup_adc(ADC_CLOCK_INTERNAL);

    while (TRUE) {
       char comando[20];
       leerEntrada(&comando);
       int opcion = analizaOpcion(comando);
       switch (opcion) {
         case 0:
            
            break;
         case 1: 
            break;
         case 2:
            break;
         case 3:
            
            break;
         default:
            printf("Ups, intenta de nuevo un comando v�lido\n\rAlgunos comandos validos son:\n\rmotor on, pwm=50, leds off, temperatura\n\r");
            break;
        }
        obtenerTemperatura();
        lcd_gotoxy(0, 1);
        printf(lcd_putc, "Temp.: %f C\n\r", valor_temperatura);
        delay_ms(200);
    }
   /*
   lcd_init(0x4E, 16, 2);
   while(true) {
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
   

    
   return 0;
}

