#include "stm32l476xx.h"
#include <stdlib.h>
#include <stdio.h>
typedef unsigned int bool;

#define false 0
#define true 1

extern void GPIO_init();
extern void max7219_send(unsigned char address, unsigned char data);
extern void max7219_init();

bool pressed[4][4];
bool to_be_update[4][4];
bool been_pressed = false;
int number_so_far = 0;

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
int keypad_scan(){
    bool yes_return = false;
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
                    if(flag_keypad_r!=0){
                        yes_return = true;
                        pressed[i][j] = true;
                    }
                    else
                        pressed[i][j] = false;
                }
            }
        }
        GPIOA->ODR=GPIOA->ODR|10111<<8; //set PA8,9,10,12(column) high
    }
    if(yes_return)
        return 1;
    else
        return -1;
}

void display(int data){

	if(data / 100000000 != 0)
		return ;

    /*if(data == 0){
        max7219_send(1, 0);
        return;
    }*/
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

int get_digit(int input){
    if(input == 0)
        return 1;
    int rtn = 0;
    while(input != 0){
        input /= 10;
        rtn += 1;
    }
    return rtn;
}

void clear_to_be_update(){
    for(int i=0;i<4;++i){
        for(int j=0;j<4;++j){
            to_be_update[i][j] = false;
        }
    }
}

int main(){
    int Table[4][4] = {
            {-1, 7, 4, 1},
            {0, 8, 5, 2},
            {-1, 9, 6, 3},
            {13, 12, 11, 10}
    };
	Init_GPIO();
    max7219_init();
    keypad_init();
    while(1){
        if(keypad_scan() == 1){
            for(int i=0;i<4;++i){
                for(int j=0;j<4;++j){
                    if(pressed[i][j] == true)
                        to_be_update[i][j] = true;
                }
            }
            been_pressed = true;
        }else if(been_pressed){
            been_pressed = false;
            //released
            if(to_be_update[0][0] == true || to_be_update[2][0] == true){
                // clear
                number_so_far = 0;
                display(number_so_far);
                clear_to_be_update();
                continue;
            }
            int number_to_be_updated = 0;
            for(int i=0;i<4;++i){
                for(int j=0;j<4;++j){
                    if(to_be_update[i][j] == true)
                        number_to_be_updated += Table[i][j];
                }
            }
            int ntbu_digit = get_digit(number_to_be_updated);
            if(get_digit(number_so_far) + ntbu_digit <= 8){
                for(int i=0;i<ntbu_digit;++i){
                    number_so_far *= 10;
                }
                number_so_far += number_to_be_updated;
                display(number_so_far);
            }
            clear_to_be_update();
        }
    }
    return 0;
}
