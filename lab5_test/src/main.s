	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	arr: .byte 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, x0 //TODO: put 0 to F 7-Seg LED pattern here

	clk: .word 1 // clock now
.text
	.global main
	.equ RCC_AHB2ENR,	0x4002104C
	.equ GPIOB_MODER,	0x48000400
	.equ GPIOB_OTYPER,	0x48000404
	.equ GPIOB_OSPEEDR, 	0x48000408
	.equ GPIOB_PUPDR, 	0x4800040C
	.equ GPIOB_ODR, 	0x48000414
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
	.equ clock_huze, 10000
	.equ one_second_count, 1050000

main:

	BL GPIO_init

	BL max7219_init

	B Display0toF

	program_end:
		b program_end

GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS

	//TODO: Initial LED GPIO pins as output 	and CLK
	movs r0, #0x4	//pc
	ldr r1, =RCC_AHB2ENR
	str r0,[r1]

	// pb

	ldr r0, =#0b010101000000	//output:A0,A1,A2
	LDR r1, =GPIOC_MODER
	ldr r2, [r1]
	and r2, #0xFFFFC03F
	orrs r2,r2,r0
	str r2,[r1]

	ldr r0, =#0b101010000000
	ldr r1, =GPIOC_OSPEEDR
	strh r0, [r1]

	ldr r12, =GPIOC_ODR

	BX LR

Display0toF:
	//TODO: Display 0 to F at first digit on 7-SEG LED. Display one per second.
	push {lr}
	push {r0-r6}

	mov r2, #0 // i
	mov r0, #1 // addr
	mov r1, #0 // data
		run_run_run:
		ldr r1, =0b1111110//0
		bl MAX7219Send
		bl Delay
		ldr r1, =0b110000//1
		bl MAX7219Send
		bl Delay
		ldr r1, =0b1101101//2
		bl MAX7219Send
		bl Delay
		ldr r1, =0b1111001//3
		bl MAX7219Send
		bl Delay
		ldr r1, =0b110011//4
		bl MAX7219Send
		bl Delay
		ldr r1, =0b1011011//5
		bl MAX7219Send
		bl Delay
		ldr r1, =0b1011111//6
		bl MAX7219Send
		bl Delay
		ldr r1, =0b1110000//7
		bl MAX7219Send
		bl Delay
		ldr r1, =0b1111111//8
		bl MAX7219Send
		bl Delay
		ldr r1, =0b1111011//9
		bl MAX7219Send
		bl Delay
		ldr r1, =0b1110111//A
		bl MAX7219Send
		bl Delay
		ldr r1, =0b11111//b
		bl MAX7219Send
		bl Delay
		ldr r1, =0b1001110//C
		bl MAX7219Send
		bl Delay
		ldr r1, =0b111101//d
		bl MAX7219Send
		bl Delay
		ldr r1, =0b1001111//E
		bl MAX7219Send
		bl Delay
		b run_run_run
	pop {r0-r6}
	pop {pc}

MAX7219Send:
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

		ldr r6, [r5] // r6 = GPIOB_ODR
		and r6, r6, #0xEF
		orr r6, r6, r4 // GPIOB_ODR[4] = r4
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

		ldr r6, [r5] // r6 = GPIOB_ODR
		and r6, r6, #0xEF
		orr r6, r6, r4 // GPIOB_ODR[4] = r4
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

max7219_init:
	//TODO: Initialize max7219 registers
	push {r0, r1, r2, lr}
	ldr r0, =#DECODE_MODE
	ldr r1, =#0x00	//
	BL MAX7219Send
	ldr r0, =#DISPLAY_TEST
	ldr r1, =#0x0
	BL MAX7219Send
	ldr r0, =#SCAN_LIMIT
	ldr r1, =#0x0	//
	BL MAX7219Send
	ldr r0, =#INTENSITY
	ldr r1, =#0xA
	BL MAX7219Send
	ldr r0, =#SHUTDOWN
	ldr r1, =#0x1
	BL MAX7219Send
	pop {r0, r1, r2, pc}


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
	// GPIOB_ODR[5] = !GPIOB_ODR[5]
	mov r0, #1
	lsl r0, r0, #5
	ldr r2, =GPIOC_ODR // r2 = &GPIOB_ODR
	ldr r1, [r2] // r1 = GPIOB_ODR
	eor r1, r1, r0 // r1 = GPIOB_ODR xor 100000
	strh r1, [r2]

	pop {r0-r6}
	pop {pc}

Delay:
	//TODO: Write a delay 1sec function
	push {lr}
	push {r0-r6}

	mov r0, #0
	ldr r1, =one_second_count

	delay_one_second_while:
		add r0, r0, #1
		cmp r0, r1
		blt delay_one_second_while

	pop {r0-r6}
	pop {pc}
