.data
	arr1: .byte 0x19, 0x34, 0x14, 0x32, 0x52, 0x23, 0x61, 0x29
	arr2: .byte 0x18, 0x17, 0x33, 0x16, 0xFA, 0x20, 0x55, 0xAC
	//			   0,	 1,	   2,	 3,    4,    5,    6,    7
.text
   .global main

//void do_sort(byte *r0)
do_sort: // parm: r0 = &arr

	push {r1-r5}

	// i offset in bytes
	mov r1, #0 // i = 0

	i_for: // for i = 0:6

		// j offset in bytes
		mov r2, #7 // j = 7
		j_for: // for j = 7:i

			add r3, r0, r2 // r3 = arr + j
			ldrb r3, [r3] // r3 = arr[j]

			add r4, r0, r2
			sub r4, r4, #1 // r4 = arr + j - 1
			ldrb r4, [r4] // r4 = arr[j-1]

			//if arr[j-1] > arr[j], swap
			cmp r4, r3
			ble no_swap
			//swap
				add r5, r0, r2 // r5 = arr + j
				strb r4, [r5]

				sub r5, r5, #1
				strb r3, [r5]
			no_swap:

			sub r2, r2, #1 // j--
			cmp r2, r1
			bgt j_for

	add r1, r1, #1//i++
	cmp r1, #7
	blt i_for

	pop {r1-r5}

	bx lr

main:
   ldr r0, =arr1
   bl do_sort
   ldr r0, =arr2
   bl do_sort
L: b L
