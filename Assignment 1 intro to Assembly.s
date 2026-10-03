@ ============================================================
@
@ Program 1 Assignment 2/7/2026
@
@ This Program reads from the keyboard
@
@ Author: Elaine Nguyen
@ For: CYBR 2250
@
@ ============================================================


SWI_SETSEG8 = 0x200
SWI_READINT = 0x6c
SWI_HALT = 0x11
	
	.text
	.global	_start
	
_start:	ldr	sp,=0x2000		@ Set up a stack pointer somewhere

	mov 	r0, #0		        @ read input from keyboard
	swi	SWI_READINT	        @ r0 = number typed

	ldr 	r1, =table 	        @ r1 holds address of table
	ldrb	r2, [r1, r0] 	        @ grabs related byte from table into r2

	mov     r0, r2		        @ move segment pattern into r0
	swi	SWI_SETSEG8
	
	b       _start		        @ branch back to the top and repeat


	@ ============================================================
	@ Lookup table for digits 0 through 9
	@ ============================================================
	
	.data

table:	.byte	0xED, 0x60, 0xCE, 0xEA, 0x63
	.byte	0xAB, 0xAF, 0xE0, 0xEF, 0xEB