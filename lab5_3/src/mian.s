	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	fib_now: .word 0
	fib_prev: .word 1
	button_read: .word 0
	button_state: .word 0 // 0: unpressed, 1: pressing
	button_long_pressed: .word 0

.text
	.global main
	.equ pressed, 1
	.equ unpressed, 0
	.equ RCC_AHB2ENR,	0x4002104C
	.equ GPIOB_MODER,	0x48000400
	.equ GPIOB_OTYPER,	0x48000404
	.equ GPIOB_OSPEEDR, 	0x48000408
	.equ GPIOB_PUPDR, 	0x4800040C
	.equ GPIOB_ODR, 	0x48000414

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
	.equ clock_huze, 1
	.equ one_second_count, 1050000
	.equ button_one_second_count, 50000
	.equ one_zero_zero_zero_zero_zero_zero_zero, 10000000

main:

	BL GPIO_init
	BL max7219_init

	// while(1)
		// if button pushed short
			// if fib != -1
				// tmp = fib
				// fib = fib + prev
				// prev = tmp
				// if fib >= 100000000
					// fib = -1
		// if button pushed long enough
			// fib = 0
			// prev = 1

	//display fib
	bl update_fib

	main_while:
		bl button_pressed
		cmp r0, #1 // short pressed
		bne not_short_pressed
			//short pressed
			ldr r0, =fib_now // r0 = &fib_now
			ldr r1, [r0] // r1 = fib_now
			mov r2, #0
			sub r2, r2, #1 // r2 = -1
			cmp r1, r2 // if fib_now == -1, continue
			beq main_while

			//tmp = fib
			mov r2, r1 // r2 = tmp = fib_now
			//prev
			ldr r3, =fib_prev // r3 = &prev
			ldr r4, [r3] // r4 = prev
			// fib += prev
			add r1, r1, r4
			str r1, [r0]
			// prev = tmp
			str r2, [r3]

			//if fib >= 100000000
			ldr r5, =one_zero_zero_zero_zero_zero_zero_zero
			cmp r1, r5
			blt no_overflow
				//overflow, fib = -1
				mov r1, #0
				sub r1, r1, #1 // r1 = -1
				str r1, [r0] // fib_now = -1
			no_overflow:

			bl update_fib

		not_short_pressed:
		cmp r0, #2 // long pressed
		bne not_long_pressed
			//long pressed
			ldr r0, =fib_now
			mov r1, #0
			str r1, [r0] // fib_now = 0

			ldr r0, =fib_prev
			mov r1, #1
			str r1, [r0] // fib_prev = 1

			bl update_fib

		not_long_pressed:

		b main_while

	program_end:
		b program_end

GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS
	push {r0-r6}

	//TODO: Initial LED GPIO pins as output 	and CLK
	movs r0, #0x6	//pb
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

	//pc
	ldr r1, =GPIOC_MODER
	ldr r2, [r1]
	ldr r3, =#0xF3FFFF00
	and r2, r3
	str r2, [r1]

	ldr r12, =GPIOB_ODR

	pop {r0-r6}
	BX LR

MAX7219Send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push {lr}
	push {r0-r6}

	// cs = 0
	ldr r2, =GPIOB_ODR
	ldr r3, [r2]
	and r3, r3, #0xF7
	strh r3, [r2]

	// clk = 1
	ldr r2, =GPIOB_ODR
	ldr r3, [r2]
	orr r3, r3, #0x20
	strh r3, [r2]

	// clk = 0
	bl delay_1ms

	//for i = 0 - 3, output addr[3-i]
	mov r2, #0 // i
	mov r3, #0b1000 // mask
	ldr r5, =GPIOB_ODR
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
	ldr r5, =GPIOB_ODR
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
	ldr r2, =GPIOB_ODR
	ldr r3, [r2]
	orr r3, r3, #0x8
	strh r3, [r2]

	// clk = 1
	bl delay_1ms
	// clk = 1
	bl delay_1ms

	// cs = 0
	ldr r2, =GPIOB_ODR
	ldr r3, [r2]
	and r3, r3, #0xF7
	strh r3, [r2]

	pop {r0-r6}
	pop {pc}

max7219_init:
	//TODO: Initialize max7219 registers
	push {r0, r1, r2, lr}
	ldr r0, =#DECODE_MODE
	ldr r1, =#0xFF	//
	BL MAX7219Send
	ldr r0, =#DISPLAY_TEST
	ldr r1, =#0x0
	BL MAX7219Send
	ldr r0, =#SCAN_LIMIT
	ldr r1, =#0x7	//
	BL MAX7219Send
	ldr r0, =#INTENSITY
	ldr r1, =#0xA
	BL MAX7219Send
	ldr r0, =#SHUTDOWN
	ldr r1, =#0x1
	BL MAX7219Send

	bl clean_led

	pop {r0, r1, r2, pc}

button_pressed:
	//return r0: true for pressed
	push {r1-r6}
	mov r0, #0 // not been pressed, return false
	ldr r2, =GPIOC_IDR
	ldr r3, [r2]
	movs r5, #1
	lsl r5, #13 // r5 = 10 0000 0000 0000
	ands r3, r5
	bne no_pressing
		// pressed
		// button_read++
		ldr r2, =button_read
		ldr r3, [r2]
		add r3, r3, #1
		str r3, [r2]

		//if button_read >= 100, pressing
		cmp r3, #100
		blt not_long_enough
			//change button_state to pressing
			ldr r2, =button_state
			mov r6, #1
			str r6, [r2]

			//check if pressing long enough
			ldr r5, =button_one_second_count
			cmp r3, r5
			blt not_pressing_long_enough
				//long enough
				ldr r4, =button_long_pressed
				mov r5, #1
				str r5, [r4] // button_long_pressed = 1
			not_pressing_long_enough:
		not_long_enough:

		b done_button_check
	no_pressing:
		//check button_state if it's been pressing
		ldr r2, =button_state
		ldr r2, [r2]
		cmp r2, #1
		bne not_been_pressing
			mov r0, #1 // return true (1)
			ldr r4, =button_long_pressed
			ldr r4, [r4]
			add r0, r0, r4 // long enough return 2
		not_been_pressing:

		//change button_state to unpressed
		ldr r2, =button_state
		mov r3, #0
		str r3, [r2]

		//change button_read to zero
		ldr r2, =button_read
		mov r3, #0
		str r3, [r2]

		//change long pressed to zero
		ldr r4, =button_long_pressed
		mov r3, #0
		str r3, [r4]
	done_button_check:

	pop {r1-r6}
	bx lr

update_fib:
	push {lr}
	push {r0-r6}

	bl clean_led

	ldr r5, =fib_now
	ldr r5, [r5] // r5 = fib_now

	// if fib == -1, update -1
	mov r1, #0
	sub r1, r1, #1 // r1 = -1
	cmp r5, r1
	bne not_minus_one
		// fib == -1
		bl clean_led
		mov r0, #2 // addr
		mov r1, #0b1010 // data
		bl MAX7219Send
		mov r0, #1
		mov r1, #1 // data
		bl MAX7219Send

		b update_fib_return
	not_minus_one:

	//for i = 0 - 7, update fib % 10; fib /= 10;
	mov r6, #0 // i
	update_fib_digit_for:

		mov r2, #10
		udiv r3, r5, r2 // r3 = fib_now / 10
		mul r1, r3, r2 // r1 = fib_now / 10 * 10
		sub r1, r5, r1 // r1 = last digit of fib_now // data

		mov r0, r6//addr
		add r0, r0, #1 // addr = i + 1
		bl MAX7219Send

		mov r5, r3 // fib_now /= 10

		// if fib_now == 0, break;
		cmp r5, #0
		beq update_fib_return

		add r6, r6, #1 // i++
		cmp r6, #8 // for i < 8
		blt update_fib_digit_for

	update_fib_return:
	pop {r0-r6}
	pop {pc}

clean_led:
	push {lr}
	push {r0-r6}

	//for i = 0 - 7, set ith led to empty
	mov r0, #1 // i // addr
	mov r1, #0x0F // data
	max_init_empty_for:
		bl MAX7219Send
		add r0, r0, #1
		cmp r0, #9
		blt max_init_empty_for

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
	// GPIOB_ODR[5] = !GPIOB_ODR[5]
	mov r0, #1
	lsl r0, r0, #5
	ldr r2, =GPIOB_ODR // r2 = &GPIOB_ODR
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
