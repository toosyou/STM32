.syntax unified
.cpu cortex-m4
.thumb
.global GPIO_init
.equ RCC_AHB2ENR,	0x4002104C
.equ GPIOA_MODER,	0x48000000
.equ GPIOA_OTYPER,	0x48000004
.equ GPIOA_OSPEEDR, 0x48000008
.equ GPIOA_PUPDR, 	0x4800000C
.equ GPIOA_IDR, 	0x48000010
.equ GPIOA_ODR, 	0x48000014
.equ GPIOA_BSRR,	0x48000018
.equ GPIOA_LCKR, 	0x4800001C
.equ GPIOA_AFRL, 	0x48000020
.equ GPIOA_AFRH, 	0x48000024
.equ GPIOA_BRR, 	0x48000028
.equ GPIOA_ASCR, 	0x4800002C
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
	movs r0, #0x1	//pa, pb, pc
	ldr r1, =RCC_AHB2ENR
	str r0,[r1]

	// pb

	ldr r0, =#0b010101000000	//output:A0,A1,A2
	LDR r1, =GPIOA_MODER
	ldr r2, [r1]
	and r2, #0xFFFFC03F
	orrs r2,r2,r0
	str r0,[r1]

	ldr r0, =#0b111111000000
	ldr r1, =GPIOA_OSPEEDR
	strh r0, [r1]

	ldr r12, =GPIOA_ODR

	BX LR
