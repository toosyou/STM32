#include "stm32l476xx.h"
#include <stdlib.h>

#define TIME_SEC 30
#define TIM_ARR_VAL 65535
#define PLL_DEFAULT_FREQ 4032258

extern void GPIO_init();
extern void max7219_init();
extern void Display();
extern void max7219_send(unsigned char address, unsigned char data);

void Display_f(int value, int digits){
    for(int i=0;i<8;++i){
        int to_be_send = value%10;
        if( value == 0 )
            to_be_send = 0b1111;
        if(i == digits){
            to_be_send += 0b10000000;
        }
        max7219_send(i+1, to_be_send);
        value /= 10;
    }
}

void clock_init(){ // 1Mhz
    RCC->CR &= 0b11111110111111111111111111111111;
    while((RCC->CR & RCC_CR_PLLRDY) == 1);//check HSI16 ready
    RCC->CFGR &= 0xFFFFFBFF;
    RCC->CFGR |= 0xF;
    RCC->CFGR = RCC->CFGR | (0b1011)<<4; //  /16
    RCC->CFGR = RCC->CFGR & 0xFFFFFFBF;
    RCC->CR |= RCC_CR_PLLON;
    while((RCC->CR & RCC_CR_PLLRDY) == 1);
    RCC->PLLCFGR |= 0b00000100000100000; // 
    RCC->PLLCFGR &= 0b1111111111111100000100000100000;
}

void InitializeTimer() {
    RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
    TIM2->CR1 &= 0xFFFFFFEF; // count up
    TIM2->ARR = (uint32_t)TIM_ARR_VAL;//Reload value
    TIM2->PSC = (uint32_t)TIME_SEC*(PLL_DEFAULT_FREQ/(TIM_ARR_VAL+1)) - 1;//Prescalser
    TIM2->EGR = TIM_EGR_UG;//Reinitialize the counte
}
void start_timer(){
    TIM2->CR1 |= TIM_CR1_CEN;//start timer
    int pre_val = 0;
    while(1){
        int timerValue = TIM2->CNT;//polling the counter value
        if(pre_val > timerValue){//check if times up
            TIM2->CR1 &= ~TIM_CR1_CEN;
            Display_f(TIME_SEC*100, 2);
            return;
        }
        pre_val = timerValue;
        int dis_val = TIME_SEC*100*timerValue/TIM_ARR_VAL;//convert counter value to time(seconds)
        Display_f(dis_val, 2);//display the time on the 7-SEG LED
    }
}



int main() {
    GPIO_init();
    max7219_init();
    if(TIME_SEC < 0.01 || TIME_SEC > 10000.00){//out of range
        for(int i=0;i<8;++i){
            max7219_send(i+1, 0b1111);
        }
        max7219_send(1, 0);
        max7219_send(2, 0);
        max7219_send(3, 0b10000000);
        return -1;
    }

    InitializeTimer();
    start_timer();

    return 0;
}
