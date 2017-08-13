.syntax unified
.cpu cortex-m4
.thumb

.global GPIO_init
	.equ GPIOB_MODER,	0x48000400
	.equ GPIOB_OTYPER,	0x48000404
	.equ GPIOB_OSPEEDR, 0x48000408
	.equ GPIOB_PUPDR, 	0x4800040C
	.equ GPIOB_IDR, 	0x48000410
	.equ GPIOB_ODR, 	0x48000414
	.equ GPIOB_BSRR,	0x48000418
	.equ GPIOB_LCKR, 	0x4800041C
	.equ GPIOB_AFRL, 	0x48000420
	.equ GPIOB_AFRH, 	0x48000424
	.equ GPIOB_BRR, 	0x48000428
	.equ GPIOB_ASCR, 	0x4800042C
	.equ DECODE_MODE, 0x9
	.equ DISPLAY_TEST,0xF
	.equ SCAN_LIMIT, 0xB
	.equ INTENSITY, 0xA
	.equ SHUTDOWN, 0xC
	.equ clock_huze, 10
	.equ one_second_count, 1050000

GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS

	//TODO: Initial LED GPIO pins as output 	and CLK
	movs r0, #0x2	//PB3
	ldr r1, =RCC_AHB2ENR
	str r0,[r1]


	ldr r0, =#0xFFFFFF3F	//input:PB3
	LDR r1, =GPIOB_MODER
	ldr r2, [r1]


	ldr r0, =#0xFFFF
	ldr r1, =GPIOB_OSPEEDR
	strh r0, [r1]


	BX LR
