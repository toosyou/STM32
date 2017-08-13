#include "stm32l476xx.h"
#include <stdlib.h>
#include <stdio.h>

extern void GPIO_init();
extern void max7219_send(unsigned char address, unsigned char data);
extern void max7219_init();

void Init_GPIO(){

    RCC->AHB2ENR = 0x7;

    GPIOC->MODER = 0xFFFFF57F;
    GPIOC->OSPEEDR = 0xFC0;

    return ;
}

/* TODO: initial keypad gpio pin, X as output and Y as input */
void keypad_init(){
    // SET keypad gpio OUTPUT //
    RCC->AHB2ENR = RCC->AHB2ENR|0x2;
    //Set PA8,9,10,12 as output mode
    GPIOA->MODER= GPIOA->MODER&0xFDD5FFFF;
    //set PA8,9,10,12 is Pull-up output
    GPIOA->PUPDR=GPIOA->PUPDR|0x1150000;
    //Set PA8,9,10,12 as medium speed mode
    GPIOA->OSPEEDR=GPIOA->OSPEEDR|0x1150000;
    //Set PA8,9,10,12 as high
    GPIOA->ODR=GPIOA->ODR|10111<<8;
    // SET keypad gpio INPUT //
    //Set PB5,6,7,9 as INPUT mode
    GPIOB->MODER=GPIOB->MODER&0xFFF303FF;
    //set PB5,6,7,9 is Pull-down input
    GPIOB->PUPDR=GPIOB->PUPDR|0x8A800;
    //Set PB5,6,7,9 as medium speed mode
    GPIOB->OSPEEDR=GPIOB->OSPEEDR|0x45400;

    return;
}
/* TODO: scan keypad value * return:
* >=0: key pressed value * -1: no key press
*/
char keypad_scan(){

    return -1;
}

void display(int data){

	if(data / 100000000 != 0)
		return ;

    if(data == 0){
        max7219_send(1, 0);
        return;
    }
    int index = 0;
    while(data != 0){
        max7219_send(index+1, data%10);
        data /= 10;
        index++;
    }

    for(;index<8;++index)
        max7219_send(index+1, 0xF);

	return ;
}

int main(){
    int Table[4][4] = {
            {15, 0, 14, 13},
            {7, 8, 9, 12},
            {4, 5, 6, 11},
            {1, 2, 3, 10}
    };
	Init_GPIO();
    max7219_init();
    keypad_init();
    while(1){
        int flag_keypad=GPIOB->IDR&10111<<5;
        if(flag_keypad!=0){
            int k=45000;
            int flag_debounce = 0;
            while(k!=0){
                flag_debounce=GPIOB->IDR&10111<<5; k--;
            }
            if(flag_debounce!=0){
                for(int i=0;i<4;i++){ //scan keypad from first column
                    int position_c=i+8;
                    if(i==3)position_c++;
                    //set PA8,9,10,12(column) low and set pin high from PA8
                    GPIOA->ODR=(GPIOA->ODR&0xFFFFE8FF)|1<<position_c;
                    for(int j=0;j<4;j++){ //read input from first row
                        int position_r=j+5;
                        if(j==3) position_r++;
                        int flag_keypad_r=GPIOB->IDR&1<<position_r;
                        if(flag_keypad_r!=0)display(Table[j][i]);
                    }
                }
            }
            GPIOA->ODR=GPIOA->ODR|10111<<8; //set PA8,9,10,12(column) high
        }
    }
    return 0;
}
