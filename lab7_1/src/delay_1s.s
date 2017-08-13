.global delay_1s

	.equ one_second_count, 270000

delay_1s:
	push {lr}
	push {r0-r6}

	mov r0, #0 // i
	ldr r1, =one_second_count
	delay_1s_for_loop:
		add r0, r0, #1
		cmp r0, r1
		blt delay_1s_for_loop

	pop {r0-r6}
	pop {pc}
