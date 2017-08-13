.syntax unified
.cpu cortex-m4
.thumb

.data
	Leds: .byte 0
	positions: .word 0xFFFFFFF9 // 1111, 1111, 1111, 1001
	direction: .word 0 // 0: left, 1: right
	state: .word 0 // 0: going, 1: stop
	button_read: .word 0
	button_state: .word 0 // 0: unpressed, 1: pressing

.text
	.equ X, 100000
	.equ left_bound, 0xFFFFFE7F // 1111, 1110, 0111, 1111
	.equ right_bound, 0xFFFFFFF9
	.equ left_bound_next, 0xFFFFFF9F
	.equ right_bound_next, 0xFFFFFFFE7

.global main
	.equ RCC_AHB2ENR,	0x4002104C
	.equ GPIOB_MODER,	0x48000400
	.equ GPIOB_OTYPER,	0x48000404
	.equ GPIOB_OSPEEDR, 	0x48000408
	.equ GPIOB_PUPDR, 	0x4800040C
	.equ GPIOB_IDR, 	0x48000410
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

main:
	//enable AHB2 clock
	BL GPIO_init

Loop:
//TODO: Write the display pattern into leds variable
	BL DisplayLED
	BL Delay
	B Loop

GPIO_init:
	//TODO: Initial LED GPIO pins as output
	mov r0, #0x6
	ldr r1, =RCC_AHB2ENR
	str r0,[r1]

	// pb
	MOVS r0, #0x1540
	LDR r1, =GPIOB_MODER
	ldr r2, [r1]
	and r2, #0xFFFFC03F
	orrs r2,r2,r0
	str r2,[r1]

	movs r0,#0x2A80
	ldr r1, =GPIOB_OSPEEDR
	strh r0, [r1]

	//pc 13
	ldr r1, =GPIOC_MODER
	ldr r0, [r1]
	ldr r2, =#0xF3FFFFFF
	and r0, r2
	str r0, [r1]

	ldr r1, =GPIOB_ODR

	BX LR

DisplayLED:
	// r1 : GPIOB_ODR address
	push {r0-r6}
	ldr r0, =positions
	ldr r0, [r0]

	ldr r2, =direction
	ldr r2, [r2] // r2 = direction
	cmp r2, #0 // left
	bne move_right
		//move left
		lsl r0, #1
		orr r0, r0, #1
		b done_move
	move_right:
		//move right
		asr r0, #1
		b done_move
	done_move:

	ldr r2, =left_bound
	cmp r0, r2 // 1111, 1110, 0111, 1111
	bne no_change_right
		//change direction to right
		ldr r2, =direction
		mov r3, #1 // right
		str r3, [r2] // direction = 1
		ldr r0, =left_bound_next // 1111, 1111, 1001, 1111
	no_change_right:


	ldr r2, =right_bound
	cmp r0, r2 // 1111, 1111, 1111, 1001
	bne no_change_left
		//change direction to left
		ldr r2, =direction
		mov r3, #0 // right
		str r3, [r2] // direction = 0
		ldr r0, =right_bound_next // 1111, 1111, 1110, 0111
	no_change_left:

	//change LEDs
	strh r0, [r1]
	//store postions
	ldr r2, =positions
	str r0, [r2]

	pop {r0-r6}
	BX LR


Delay:
	//TODO: Write a delay 1sec function
	push {r0-r6}
	movs r4, #0
	ldr r6, =X
	count:
		ldr r5, =state
		ldr r5, [r5] // r5 = state
		cmp r5, #0 // state = going
		bne stop
			add r4,r4,#1
		stop:

		//do button thing
		//bl check_button_state
		ldr r2, =GPIOC_IDR
		ldr r3, [r2]
		movs r5, #1
		lsl r5, #13 // r5 = 10 0000 0000 0000
		cmp r3, r5
		beq no_pressing
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
				mov r3, #1
				str r3, [r2]
			not_long_enough:

			b done_button_check
		no_pressing:
			//check button_state if it's been pressing
			ldr r2, =button_state
			ldr r2, [r2]
			cmp r2, #1
			bne not_been_pressing
				//check led state
				ldr r2, =state
				ldr r3, [r2]
				cmp r3, #0 //going
				bne not_going
					//change to stop
					mov r3, #1
					str r3, [r2]
					b done_changing_state
				not_going:
					//change to going
					mov r3, #0
					str r3, [r2]
					b done_changing_state
				done_changing_state:
			not_been_pressing:

			//change button_state to unpressed
			ldr r2, =button_state
			mov r3, #0
			str r3, [r2]

			//change button_read to zero
			ldr r2, =button_read
			mov r3, #0
			str r3, [r2]
		done_button_check:

		cmp r4,r6
		blt count

	pop {r0-r6}
	BX LR
