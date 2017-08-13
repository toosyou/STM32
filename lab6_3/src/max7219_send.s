
.syntax unified
.cpu cortex-m4
.thumb
	.global max7219_send
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
	.equ clock_huze, 10
	.equ one_second_count, 1050000

max7219_send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push {lr}
	push {r0-r6}

	// cs = 0
	ldr r2, =GPIOC_ODR
	ldr r3, [r2]
	and r3, r3, #0xF7
	strh r3, [r2]

	// clk = 1
	ldr r2, =GPIOC_ODR
	ldr r3, [r2]
	orr r3, r3, #0x20
	strh r3, [r2]

	// clk = 0
	bl delay_1ms

	//for i = 0 - 3, output addr[3-i]
	mov r2, #0 // i
	mov r3, #0b1000 // mask
	ldr r5, =GPIOC_ODR
	max_send_addr_for:
		and r4, r0, r3 // r4 = addr & mask
		lsl r4, r4, r2 // r4 <<= i
		lsl r4, r4, #1 // r4 <<= 1

		ldr r6, [r5] // r6 = GPIOA_ODR
		and r6, r6, #0xEF
		orr r6, r6, r4 // GPIOA_ODR[4] = r4
		strh r6, [r5]

		// clk = 1
		bl delay_1ms
		// clk = 0
		bl delay_1ms

		lsr r3, r3, #1 // mask >>= 1
		add r2, r2, #1
		cmp r2, #4 // for i < 4
		blt max_send_addr_for

	// clk = 0
	// for i = 0 - 7, output data[7-i]
	mov r2, #0 // i
	mov r3, #0b10000000 // mask
	ldr r5, =GPIOC_ODR
	max_send_data_for:
		and r4, r1, r3 // r4 = data & mask
		lsl r4, r4, r2 // r4 <<= i
		lsr r4, r4, #3 // r4 >>= 3

		ldr r6, [r5] // r6 = GPIOA_ODR
		and r6, r6, #0xEF
		orr r6, r6, r4 // GPIOA_ODR[4] = r4
		strh r6, [r5]

		// clk = 1
		bl delay_1ms
		// clk = 0
		bl delay_1ms

		lsr r3, r3, #1 // mask >>= 1
		add r2, r2, #1

		cmp r2, #8 // for i < 8
		blt max_send_data_for

	// cs = 1
	ldr r2, =GPIOC_ODR
	ldr r3, [r2]
	orr r3, r3, #0x8
	strh r3, [r2]

	// clk = 1
	bl delay_1ms
	// clk = 1
	bl delay_1ms

	// cs = 0
	ldr r2, =GPIOC_ODR
	ldr r3, [r2]
	and r3, r3, #0xF7
	strh r3, [r2]

	pop {r0-r6}
	pop {pc}


delay_1ms:
	push {lr}
	push {r0-r6}

	mov r0, #0
	ldr r1, =clock_huze

	delay_1ms_while:
		add r0, r0, #1
		cmp r0, r1
		blt delay_1ms_while

	// clk = ~clk
	// GPIOA_ODR[5] = !GPIOA_ODR[5]
	mov r0, #1
	lsl r0, r0, #5
	ldr r2, =GPIOC_ODR // r2 = &GPIOA_ODR
	ldr r1, [r2] // r1 = GPIOA_ODR
	eor r1, r1, r0 // r1 = GPIOA_ODR xor 100000
	strh r1, [r2]

	pop {r0-r6}
	pop {pc}
