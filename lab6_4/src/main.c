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
bool been_pressed = false;
int keypressed = 0;
int number_so_far = 0;
bool first_number_pressed = false;
int last_op = 1; // +
float result = 0.0f;
float tmp_result = 0.0f;
int tmp_op = 0;
bool yes_tmp = false;
bool error_occured = false;


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
    if(yes_return == true){
        return 1;
    }
    else{
        return -1;
    }
}

void display(int data){

	if(data / 100000000 != 0)
		return ;

    if(data == -1){
        for(int i=0;i<8;++i)
            max7219_send(i+1, 0xF);
        return;
    }
    if(data == -2){
        for(int i=0;i<8;++i)
            max7219_send(i+1, 0xF);
        max7219_send(1, 1);
        max7219_send(2, 0b1010);
        return;
    }
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

int get_digit(int input){
    if(input == 0)
        return 1;
    int rtn = 0;
    while(input > 0){
        input /= 10;
        rtn += 1;
    }
    return rtn;
}

void display_result(float result){
    int digit_so_far = 0;
    int digit_last = 0;
    char output_str[10] = {0};
    sprintf(output_str, "%-9f", result);
    for(int i=0;i<9 && digit_so_far <= 8;++i){
        if(output_str[i] == '-'){
            max7219_send(8-digit_so_far, 0b1010);
            digit_so_far++;
            continue;
        }
        else if(output_str[i] == '.'){
            max7219_send(8-digit_so_far+1, digit_last + 0b10000000);
            continue;
        }
        max7219_send(8-digit_so_far, output_str[i] - '0');
        digit_so_far++;
        digit_last = output_str[i] - '0';
    }
    return;
}


int main(){
    int Table[4][4] = {
            {14, 7, 4, 1},
            {0, 8, 5, 2},
            {15, 9, 6, 3},
            {13, 12, 11, 10}
    };
	Init_GPIO();
    max7219_init();
    keypad_init();
    display(-1);

    while(1){
        if(keypad_scan() == 1){
            been_pressed = true;
            for(int i=0;i<4;++i){
                for(int j=0;j<4;++j){
                    if(pressed[i][j] == true){
                        keypressed = Table[i][j];
                    }
                }
            }
        }
        else if(been_pressed == true){
            been_pressed = false;
            //number
            if(keypressed >= 0 && keypressed <= 9){
                if(get_digit(number_so_far) < 3){
                    number_so_far *= 10;
                    number_so_far += keypressed;
                }
                display(number_so_far);
                first_number_pressed = true;
            }
            else if(keypressed >= 10 && keypressed <= 13){
                if(first_number_pressed == false){
                    error_occured = true;
                    continue;
                }

                if(keypressed == 10 || keypressed == 11){ // +, -
                    if( last_op == 1 || last_op == 0 ){ // +
                        result += number_so_far;
                    }
                    else if(last_op == 2){ // -
                        result -= (float)number_so_far;
                    }
                    else if(last_op == 3){ // *
                        result *= (float)number_so_far;
                        if(yes_tmp == true){
                            if(tmp_op == 1){ // +
                                result += tmp_result;
                            }
                            else if(tmp_op == 2){ // -
                                result = tmp_result - result;
                            }
                            yes_tmp = false;
                        }
                    }
                    else if(last_op == 4){ // /
                        result /= (float)number_so_far;
                        if(yes_tmp == true){
                            if(tmp_op == 1){ // +
                                result += tmp_result;
                            }
                            else if(tmp_op == 2){ // -
                                result = tmp_result - result;
                            }
                            yes_tmp = false;
                        }
                    }
                    last_op = keypressed - 9;

                }
                else if(keypressed == 12 || keypressed == 13){ // *, /
                    if( last_op == 1 ){ // +
                        yes_tmp = true;
                        tmp_result = result;
                        tmp_op = 1;
                        result = (float)number_so_far;
                    }
                    else if(last_op == 2){ // -
                        yes_tmp = true;
                        tmp_result = result;
                        tmp_op = 2;
                        result = (float)number_so_far;
                    }
                    else if(last_op == 3){ // *
                        result *= (float)number_so_far;
                    }
                    else if(last_op == 4){ // /
                        result /= (float)number_so_far;
                    }
                    last_op = keypressed - 9;
                }
                number_so_far = 0;
                first_number_pressed = false;
                display(-1);
            }
            else if(keypressed == 14){ // =
                if(error_occured == true){
                    display(-2);
                    continue;
                }
                if(last_op == 1){ // +
                    result += (float)number_so_far;
                }
                else if(last_op == 2){ // -
                    result -= (float)number_so_far;
                }
                else if(last_op == 3){ // *
                    result *= (float)number_so_far;
                }
                else if(last_op == 4){ // /
                    result /= (float)number_so_far;
                }
                if(yes_tmp == true){
                    if(tmp_op == 1){ // +
                        result += tmp_result;
                    }
                    else if(tmp_op == 2){ // -
                        result = tmp_result - result;
                    }
                    yes_tmp = false;
                }
                display_result(result);
            }
            else if(keypressed == 15){ // c
                first_number_pressed = false;
                error_occured = false;
                number_so_far = 0;
                last_op = 1; // +
                result = 0.0f;
                tmp_result = 0.0f;
                tmp_op = 0;
                yes_tmp = false;
                display(-1);
            }
        }
    }
    return 0;
}
