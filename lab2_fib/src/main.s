.text
   	.global main
	.equ N, 40

fib: //TODO

	push {r0-r3}

	cmp r0, #1
	bge continue_1
		mov r4, #0
		sub r4, r4, #1
		b return

	continue_1:
	cmp r0, #100
	ble continue_2
		mov r4, #0
		sub r4, r4, #1
		b return

	continue_2:

	mov r1, #2 // i = 0
	mov r3, #1 // prev
	mov r4, #1 // now

	for_i: // for i < n

		mov r2, r4 		// tmp = now
		add r4, r4, r3	// now = now + prev
		mov r3, r2		// prev = tmp

		add r1, r1, #1 // i++
		cmp r1, r0 // i < n
		blt for_i

	return:
	pop {r0-r3}
	bx lr

main:
	movs R0, #N
	bl fib
	mov r1, r2

L: b L
