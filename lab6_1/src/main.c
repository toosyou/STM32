#include <stdlib.h>
#include <stdio.h>

//These functions inside the asm file
extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char data);
/**
* TODO: Show data on 7-seg via max7219_send
* Input:
* data: decimal value
* num_digs: number of digits will show on 7-seg * Return:
* 0: success
* -1: illegal data range(out of 8 digits range) */
int display(int data, int num_digs){

	if(data / 100000000 != 0)
		return -1;

	for(int i=0;i<num_digs;++i){
		max7219_send(i+1, data%10);
		data = data / 10;
	}

	for(int i=0;i<(8-num_digs);++i){
		max7219_send(8-i, 0xF);
	}

	return 0;
}
int main(){

  int student_id = 316313;
  GPIO_init();
  max7219_init();
  display(student_id, 6);

  return 0;
}
