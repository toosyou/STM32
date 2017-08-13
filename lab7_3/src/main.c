#include "stm32l476xx.h"
#include <stdlib.h>
#include <stdio.h>

typedef unsigned int bool;

bool pressed[4][4];

#define false 0
#define true 1

void Init_GPIO(){

    RCC->AHB2ENR = 0x1; //abc

    //GPIOB->MODER = 0xFFFFFDFF;
    //GPIOB->OSPEEDR = 0b1100000000;

    GPIOA->MODER = 0xFFFFFFFE;
    GPIOA->OSPEEDR = 0b10;
    GPIOA->AFR[0] |= 0x00000001;
    GPIOA->AFR[0] &= 0xFFFFFFF1;
    GPIOA->AFR[1] |= 0x00000001;
    GPIOA->AFR[1] &= 0xFFFFFFF1;

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
    GPIOA->OSPEEDR=GPIOA->OSPEEDR|0x33F0000;
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

int keypad_scan(){
    bool yes_return = false;
    int flag_keypad=GPIOB->IDR&10111<<5;
    if(flag_keypad!=0){
        int flag_debounce = 1;
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
        return 1;
    }
    return -1;
}


void InitializeTimer(uint32_t presc){

	RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
	TIM2->CR1 &= 0xFFFFFF8F; // count up & Edge-aligned
    TIM2->CR1 |= 0x80;

	TIM2->ARR = (uint32_t)100;//Reload value
	TIM2->PSC = (uint32_t)presc;//Prescaler
	TIM2->EGR = TIM_EGR_UG;//Reinitialize the counter

    TIM2->CCMR1 |= 6 << 4;
    TIM2->CCMR1 |= 1 << 3;

    TIM2->CCR1 = 50;

    TIM2->CCER |= 1;
    TIM2->BDTR |= 1<<15;
    TIM2->CR1 |= TIM_CR1_CEN;
}

int main(){
    int Table[4][4] = {
            {0, 81, 115, 153},
            {0, 76, 102, 136},
            {0, 0, 91, 121},
            {0, 0, -2, -1}
    };
    InitializeTimer(500);
	Init_GPIO();
    keypad_init();
    bool add_pressed = false;
    bool minus_pressed = false;
    int unpressed = 0;

    while(1){
        if( keypad_scan() == 1){
            unpressed = 0;
            bool yes_sound = false;
            for(int i=0;i<4;++i){
                for(int j=0;j<4;++j){
                    if(pressed[i][j] == true){
                        TIM2->PSC = Table[i][j];
                        if(Table[i][j] == -1){
                            add_pressed = true;
                            //TIM2->CCR1 = TIM2->CCR1 < 90 ? TIM2->CCR1+5 : TIM2->CCR1;
                        }
                        else if(Table[i][j] == -2){
                            minus_pressed = true;
                            //TIM2->CCR1 = TIM2->CCR1 > 10 ? TIM2->CCR1-5 : TIM2->CCR1;
                        }
                        if(Table[i][j] > 0)
                            yes_sound = true;
                    }
                }
            }
            if(yes_sound == true)
                TIM2->CR1 |= TIM_CR1_CEN;
            else
                TIM2->CR1 &= ~TIM_CR1_CEN;
        }
        else{
            unpressed++;
            if(unpressed < 500)
                continue;
            for(int i=0;i<4;++i){
                for(int j=0;j<4;++j){
                    pressed[i][j] =false;
                }
            }
            TIM2->CR1 &= ~TIM_CR1_CEN;
            if(add_pressed == true)
                TIM2->CCR1 = TIM2->CCR1 < 90 ? TIM2->CCR1+5 : TIM2->CCR1;
            if(minus_pressed == true)
                TIM2->CCR1 = TIM2->CCR1 > 10 ? TIM2->CCR1-5 : TIM2->CCR1;

            add_pressed = minus_pressed = false;
        }

    }

}
