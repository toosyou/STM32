/*
 * main.s
 *
 *  Created on: 2016年10月12日
 *      Author: Evan
 */


  	.syntax unified
  	.cpu cortex-m4
  	.thumb

.data
  	#X: .word 100
  	str: .asciz "Hello World!"

.text
  	.global main
  	.equ AA, 0x55
	.equ X, 100

main:
	ldr r1, =X
	ldr r0, [r1]
	movs r2, #AA
	adds r2, r2, r0
	str r2, [r1]
	ldr r1, =str
	ldr r2, [r1]
	
L:B L
