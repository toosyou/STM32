.syntax unified
.cpu cortex-m4
.thumb

.data
	user_stack:	.zero 128
	expr_result: .word 0

.text
	.global main
	postfix_expr: .asciz "-1;;;;00 10 20 + - 10 +"


main:
	LDR R0, =postfix_expr // str
	//TODO: Setup stack pointer to end of user_stack and calculate the expression using PUSH, POP operators, and store the result into expr_result
	// set stack_pointer to user_stack
		ldr sp, =user_stack
		add sp, sp, #128

	// r9: stack size
	mov r9, #0

	calculate_while:
		// check if next expression is number or operation
			// operation type.
			// 1: number
			// 2: operation
			mov r3, #1
			//if str[0] == '+'/'-' and str[1] == ' '/'\0', operation
			ldrb r2, [r0] // r2 = str[0]
			cmp r2, #43 // '+'
			beq space_check
			cmp r2, #45 // '-'
			beq space_check
			b no_space_check
			space_check:
				mov r2, r0
				add r2, r2, #1 // r2 = str + 1
				ldrb r2, [r2] // r2 = str[1]
				cmp r2, #32 // ' '
				beq operation_checked
				cmp r2, #0 // '\0'
				beq operation_checked
				b no_space_check

				operation_checked: // it's operation
					mov r3, #2

			no_space_check:

		//if operation_type == 1, do number things
		//else if operation_type == 2, do operation things
		cmp r3, #1 // number
		beq do_number_things
		cmp r3, #2 // operation
		beq do_operation_things

		do_number_things:
			bl atoi // r1 = atoi( str )
			push {r1}
			add r9, r9, #1
			b move_to_next_exp_while

		do_operation_things:
			// check if it's '+' or '-'
			ldrb r2, [r0] // r2 = str[0]
			// if str[0] == '+', do plus
				cmp r2, #43 // '+'
				beq do_plus_things
			// if str[1] == '-', do minus
				cmp r2, #45 // '-'
				beq do_minus_things

			do_plus_things:
				// pop two numbers to r1, r2
				pop {r1}
				pop {r2}
				sub r9, r9, #2
				add r1, r1, r2
				b push_back
			do_minus_things:
				// pop two numbers to r1, r2
				pop {r1}
				pop {r2}
				sub r9, r9, #2
				sub r1, r2, r1
				b push_back

			push_back:
				push {r1}
				add r9, r9, #1

				// handling stack error
				cmp r9, #0
				ble error_accured

			b move_to_next_exp_while

		// mov r0 to next expression or end everything
		move_to_next_exp_while:
			add r0, r0, #1 // str = str + 1
			ldrb r2, [r0] // r2 = str[0]
			// if str[0] == ' ', str++; break
			cmp r2, #32 // ' '
			beq do_number_things_break
			// if str[0] == '\0', return
			cmp r2, #0
			beq main_return
			b move_to_next_exp_while

			do_number_things_break:
				add r0, r0, #1
				b calculate_while

	main_return:
		pop {r1}
		sub r9, r9, #1

		// handling stack error
		cmp r9, #0
		bne error_accured

		// restore answer
		ldr r2, =expr_result
		str r1, [r2]
	program_end:
		B program_end
strlen:
	//TODO: implement a “calculate the string length” function
	//r0 : input string address
	//r1 : length of the input string
	push {r0, r2}
	mov r1, 0
	strlen_for_i:
		mov r2, r0
		add r2, r2, r1 // r2 = str + i
		ldrb r2, [r2] // r2 = *r2 = str[i]
		//if str[i] == 0, return
		cmp r2, #0
		beq strlen_return
		add r1, r1, 1
		b strlen_for_i

	strlen_return:
		pop {r0, r2}
		bx lr

atoi:
	//TODO: implement a “convert string to integer” function
	//r0: str, input string address
	//r1: rtn, output integer
	push {r2-r5}
	push {r0}

	mov r2, #0
	//if str[0] == '+'/'-', r2 = 1/2.
	//otherwise, r2 = 0
	ldrb r3, [r0] // r3 = str[0]
	cmp r3, #43 // +
	bne atoi_no_mark_plus
		mov r2, #1
		b atoi_done_mark

	atoi_no_mark_plus:
	cmp r3, #45 // -
	bne atoi_done_mark
		mov r2, #2

	atoi_done_mark:

	//if r2 == 1 or 2, r0 += 1
	cmp r2, #1
	beq atoi_address_plus_one
	cmp r2, #2
	beq atoi_address_plus_one
	b atoi_dont_plus_one

	atoi_address_plus_one:
		add r0, r0, #1 // str = str+1

	atoi_dont_plus_one:
	mov r4, #0 // i = 0
	mov r1, #0 // rtn = 0
	atoi_for_i: //
		add r3, r0, r4 // r3 = str + i
		ldrb r3, [r3] // r3 = str[i]
		// if str[i] == ' ' or '\0', return
		cmp r3, #32 // ' '
		beq atoi_return
		cmp r3, #0 // '\0'
		beq atoi_return

		// handling error format
		cmp r3, #48
		blt error_accured
		cmp r3, #57
		bgt error_accured

		// r1 = r1 * 10 + str[i] - 48
		mov r5, #10
		mul r1, r1, r5
		add r1, r1, r3
		sub r1, r1, #48

		add r4, r4, #1
		b atoi_for_i

	atoi_return:
	//if str[0] == '-', rtn = -rtn
	//if r2 == 2, r1 = -r1
	cmp r2, 2
	bne atoi_final_return
		mov r5, #0
		sub r5, r5, #1 // r5 = -1
		mul r1, r1, r5

	atoi_final_return:
	pop {r0}
	pop {r2-r5}

	BX LR

error_accured:
	ldr r0, =expr_result
	mov r1, #0
	sub r1, r1, #1 // r1 = -1
	str r1, [r0] // expr_result = -1
	// move stack_pointer to the right position
	// = pop everything
	ldr sp, =user_stack
	add sp, sp, #128
	b program_end // exit(-1)
