#include <stdio.h>
#include <stdlib.h>
#include "stm32l476xx.h"

extern void GPIO_init();
extern void delay_1s();

unsigned int system_clock_divied_or[5] = {
		0b1010<<4,
		0b1010<<4,
		0b1010<<4,
		0b1010<<4,
		0b1000<<2
};

unsigned int system_clock_divied_and[5] = {
		0xFFFFFFAF,
		0xFFFFFFAF,
		0xFFFFFFAF,
		0xFFFFFFAF,
		0xFFFFFF8F
};

unsigned int pll_cfgr_or[5] = {
		 //654321098765432109876543210
		 0b111000000000001000000110010,
		 0b011000000000001100000010010,
		 0b001000000000001010000010010,
		 0b001000000000010000000010010,
		 0b001000000000010000000010010
};

unsigned int pll_cfgr_and[5] = {
		 //654321098765432109876543210
	0b11111111111111111001000010111110,
	0b11111011111111111001100010011110,
	0b11111001111111111001010010011110,
	0b11111001111111111010000010011110,
	0b11111001111111111010000010011110
};

void SystemClock_Config(int mode){
	//TODO: Change the SYSCLK source and set the corresponding Prescaler value.
	mode %= 5;

	// hsi on and switch to hsi
	RCC->CR |= RCC_CR_HSION;
	while((RCC->CR & RCC_CR_HSIRDY) == 0); // check hsi ready
	RCC->CFGR |= 0b01;
	RCC->CFGR &= 0xFFFFFFF1;
	while ((RCC->CFGR & 0b11) != 0b01);

	// Turn PLL off
    RCC->CR &= ~RCC_CR_PLLON;
    while(RCC->CR & RCC_CR_PLLRDY);

	RCC->CFGR |= system_clock_divied_or[mode];
	RCC->CFGR &= system_clock_divied_and[mode];

	RCC->PLLCFGR |= pll_cfgr_or[mode];
	RCC->PLLCFGR &= pll_cfgr_and[mode];

	RCC->CR |= RCC_CR_PLLON;
	while((RCC->CR & RCC_CR_PLLRDY) == 0);

	RCC->CFGR |= RCC_CFGR_SW_PLL;
    while ((RCC->CFGR & RCC_CFGR_SWS_PLL) != RCC_CFGR_SWS_PLL);

	return;
}

int user_press_button(){
	static int debounce = 0;
	if( (GPIOC->IDR & 0b0010000000000000) == 0){ // pressed
		debounce = debounce >= 1 ? 1 : debounce+1;
		return 0;
	}
	else if( debounce >= 1 ){
		debounce = 0;
		return 1;
	}
	return 0;
}

int main(){
	SystemClock_Config(0);
	GPIO_init();
	int mode=0;
	while(1){
		if (user_press_button() == 1){
			//TODO: Update system clock rate
			mode++;
			SystemClock_Config(mode);

		}

		GPIOA->BSRR = (1<<5);
		delay_1s();
		GPIOA->BRR = (1<<5);
		delay_1s();
	}
	return 0;
}
