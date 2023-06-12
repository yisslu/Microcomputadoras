#include <16f887.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#fuses HS, NOWDT, NOPROTECT, NOLVP
#use delay(clock = 20M)
#use rs232(baud = 9600, xmit = PIN_C6, rcv = PIN_C7)
#use i2c(MASTER, SDA = PIN_C4, SCL = PIN_C3, SLOW, NOFORCE_SW)
// #include "i2c-lcd.c"
#include <lcd.c>
/* Prototipo de funciones */
void escribir_i2c();
void obtenerTemperatura();
void leerEntrada(char* comando);
int analizaOpcion(char* comando);
int comparaStrings(char str1[], char str2[]);
int compareStrings(char* str1, char* str2);
int verificaPorcentaje(char *comando);
int PWM(int8 pwmCiclo);

int8 contador = 0;
char getch(void);
float valor_temperatura = 0.0;
int pwmGlobal = 130;

int verificaPorcentaje(char *comando) {
   char *pointer;
   pointer = comando;
   pointer += 4;
   int porcentaje = atoi(pointer);
   if(porcentaje >= 0 && porcentaje <= 100) {
      return porcentaje;      
   }
   
   return -1;
   
}

int compareStrings(char* str1, char* str2)
{
    int i = 0;
    while (str1[i] != '\0' && str2[i] != '\0') {
        if (str1[i] != str2[i]) {
            return 0;
        }
        i++;
    }
    if (str1[i] == '\0' && str2[i] == '\0') {
        return 1;
    }
    return 0;
}

void obtenerTemperatura()
{
    set_adc_channel(0);
    delay_ms(10);
    valor_temperatura = read_adc() * 2;
}

void escribir_i2c()
{
    i2c_start();
    i2c_write(0x42); // Direcion del esclavo
    i2c_write(contador); // El dato a escribir
    i2c_stop();
}

int PWM(int8 pwmCiclo) {
   int ciclo = 256 * pwmCiclo / 100;
   return ciclo;
}

void leerEntrada(char* comando)
{
    char* ptr;
    char ch;

    ptr = comando;
    printf("Ingrese comando: \n\r");
    while ((ch = getchar()) != '\r') {
        printf("%c", ch);
        *ptr++ = (char)ch;
    }
    printf("\n\r");
    *ptr++ = 0;

    printf("The given string is : %s\n\r", comando);
}

int getCommand(char* entry)
{
    char command[20];
    char parameter[20];
    int i = 0;
    char *temperaturaString = "temperatura",
         *pwm = "pwm=",
         *motor = "motor",
         *leds = "leds",
         *offStr = "off",
         *onStr = "on";

    while (entry[i] != ' ' && entry[i] != '\0') {
        command[i] = entry[i];
        i++;
    }
    command[i] = '\0';
    if (entry[i] == ' ') {
        i++;
    }
    int j = 0;
    while (entry[i] != '\0') {
        parameter[j] = entry[i];
        i++;
        j++;
    }
    parameter[j] = '\0';

    if (compareStrings(command, temperaturaString)) {
        return 1;
    } else if (compareStrings(command, motor)) {
        if (compareStrings(parameter, onStr)) {
            return 2;
        } else if (compareStrings(parameter, offStr)) {
            return 3;
        }
        return -1;
    } else if (compareStrings(command, leds)) {
        if (compareStrings(parameter, onStr)) {
            return 4;
        } else if (compareStrings(parameter, offStr)) {
            return 5;
        }
        return -1;
    }else if (strstr(command, pwm)) {
      int porcentaje = verificaPorcentaje(command);
      if(porcentaje != -1) {
         pwmGlobal = porcentaje;
         return 6;
      }
      return -1;
     
    }

    return -1;
}

void encenderMotor()
{
    output_low(PIN_C0); // Encender el motor conectado al pin C0 (Logica negada)
}

void apagarMotor()
{
    output_high(PIN_C0); // Apagar el motor conectado al pin C0 (Logica negada)
}

void prenderLeds()
{
    output_b(0xFF); // Prender todos los LEDs del puerto B
}

void apagarLeds()
{
    output_b(0x00); // Apagar todos los LEDs del puerto B
}

int main()
{
    /* Configuracion */
    lcd_init();
    enable_interrupts(GLOBAL);
    Setup_port_a(ALL_ANALOG);
    Setup_adc(ADC_CLOCK_INTERNAL);
    setup_ccp1(CCP_PWM);
    setup_timer_2(T2_DIV_BY_16, 64, 1);
    set_pwm1_duty(pwmGlobal);
    while (TRUE) {
        char comando[20];
        leerEntrada(&comando);
        // int opcion = analizaOpcion(comando);
        int opcion = getCommand(comando);
        printf("Opcion: %d\n\r", opcion);
        switch (opcion) {
        case 0:
            lcd_putc('\f');
            lcd_gotoxy(0, 1);
            printf(lcd_putc, " Esperando comando...");
            break;
        // Temperatura
        case 1:
            lcd_putc('\f');
            obtenerTemperatura();
            lcd_gotoxy(0, 1);
            printf(lcd_putc, " Temp.: %f C", valor_temperatura);
            delay_ms(200);
            break;

        // Motor on
        case 2:
            lcd_putc('\f');
            encenderMotor();
            lcd_gotoxy(0, 1);
            printf(lcd_putc, " Motor ON");
            delay_ms(200);
            break;

        // Motor off
        case 3:
            lcd_putc('\f');
            apagarMotor();
            lcd_gotoxy(0, 1);
            printf(lcd_putc, " Motor OFF");
            delay_ms(200);
            break;

        // Leds on
        case 4:
            lcd_putc('\f');
            prenderLeds();
            lcd_gotoxy(0, 1);
            printf(lcd_putc, " Leds ON");
            delay_ms(200);
            break;

        // Leds off
        case 5:
            lcd_putc('\f');
            apagarLeds();
            lcd_gotoxy(0, 1);
            printf(lcd_putc, " Leds OFF");
            delay_ms(200);
            break;
        // PWM
        case 6:
            int ciclo = PWM(pwmGlobal);
            set_pwm1_duty(ciclo);
            lcd_putc('\f');
            lcd_gotoxy(0, 1);
            printf(lcd_putc, " PWM Exitoso!");
            delay_ms(200);
            break;
        default:
            printf("Ups, intenta de nuevo un comando invalido\n\rAlgunos comandos validos son:\n\rmotor on, pwm=50, leds off, temperatura\n\r");
            break;
        }
    }

    return 0;
}
