.syntax unified
.cpu cortex-m4
.thumb
.global max7219_init
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
	.equ GPIOC_MODER,	0x48000800
	.equ GPIOC_OTYPER,	0x48000804
	.equ GPIOC_OSPEEDR, 0x48000808
	.equ GPIOC_PUPDR, 	0x4800080C
	.equ GPIOC_IDR, 	0x48000810
	.equ GPIOC_ODR, 	0x48000814
	.equ GPIOC_BSRR,	0x48000818
	.equ GPIOC_LCKR, 	0x4800081C
	.equ GPIOC_AFRL, 	0x48000820
	.equ GPIOC_AFRH, 	0x48000824
	.equ GPIOC_BRR, 	0x48000828
	.equ GPIOC_ASCR, 	0x4800082C
	.equ DECODE_MODE, 0x9
	.equ DISPLAY_TEST,0xF
	.equ SCAN_LIMIT, 0xB
	.equ INTENSITY, 0xA
	.equ SHUTDOWN, 0xC


max7219_init:
	//TODO: Initialize max7219 registers
	push {r0, r1, r2, lr}
	                  // CPACR is located at address 0xE000ED88
	LDR.W   R0, =0xE000ED88
	// Read CPACR
	LDR R1, [R0]
	                  // Set bits 20-23 to enable CP10 and CP11 coprocessors
	ORR     R1, R1, #(0xF << 20)
	                  // Write back the modified value to the CPACR
	STR     R1, [R0]// wait for store to complete
	DSB
	//reset pipeline now the FPU is enabled
	ISB

	ldr r0, =#DECODE_MODE
	ldr r1, =#0xFF	//
	BL max7219_send
	ldr r0, =#DISPLAY_TEST
	ldr r1, =#0x0
	BL max7219_send
	ldr r0, =#SCAN_LIMIT
	ldr r1, =#7	//
	BL max7219_send
	ldr r0, =#INTENSITY
	ldr r1, =#0xA
	BL max7219_send
	ldr r0, =#SHUTDOWN
	ldr r1, =#0x1
	BL max7219_send

	// init all digit to blank
	mov r2, #0 // i
	max7219_init_for:
		add r0, r2, #1
		mov r1, #0xF
		bl max7219_send

		add r2, r2, #1
		cmp r2, #8
		blt max7219_init_for

	pop {r0, r1, r2, pc}
