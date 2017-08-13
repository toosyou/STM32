.syntax unified
.cpu cortex-m4
.thumb
.global GPIO_init
.equ RCC_AHB2ENR,	0x4002104C
.equ GPIOB_MODER,	0x48000400
.equ GPIOB_OTYPER,	0x48000404
.equ GPIOB_OSPEEDR, 	0x48000408
.equ GPIOB_PUPDR, 	0x4800040C
.equ GPIOB_ODR, 	0x48000414
.equ DECODE_MODE, 0x9
.equ DISPLAY_TEST,0xF
.equ SCAN_LIMIT, 0xB
.equ INTENSITY, 0xA
.equ SHUTDOWN, 0xC
.equ clock_huze, 1
.equ one_second_count, 1050000


GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS

	//TODO: Initial LED GPIO pins as output 	and CLK
	movs r0, #0x2	//pb
	ldr r1, =RCC_AHB2ENR
	str r0,[r1]

	// pb

	ldr r0, =#0b010101000000	//output:A0,A1,A2
	LDR r1, =GPIOB_MODER
	ldr r2, [r1]
	and r2, #0xFFFFC03F
	orrs r2,r2,r0
	str r2,[r1]

	ldr r0, =#0b101010000000
	ldr r1, =GPIOB_OSPEEDR
	strh r0, [r1]

	ldr r12, =GPIOB_ODR

	BX LR
