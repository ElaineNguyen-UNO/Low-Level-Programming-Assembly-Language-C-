@ ============================================================
@
@ Program 2 Assignment 2/20/2026
@
@ Garage Door Program
@
@ Author: Elaine Nguyen
@ For: CYBR 2250
@
@ ============================================================

	.equ SWI_LED, 0x201
	.equ SWI_KEYPAD, 0x203

	.text
	.global	_start

_start:	
	ldr	sp, =0x2000		@ Set up stack pointer
	
	mov	r5, #0			@ Door starts Down (r5=0 means down)
	mov	r0, #0x01		@ LEFT LED on = door is down (initial state)
	swi	SWI_LED	
	
MainLoop:
	bl	GetDigit		@ Get first digit (2 -> bit 2 -> 0x04)
	cmp	r0, #0x04
	bne	Error
	
	bl	GetDigit		@ Get second digit (2 -> 0x04)
	cmp	r0, #0x04
	bne	Error
	
	bl	GetDigit		@ Get third digit (5 -> bit 5 -> 0x20)
	cmp	r0, #0x20
	bne	Error
	
	bl	GetDigit		@ Get fourth digit (0 key = button 13 -> 0x2000)
	ldr	r1, =0x2000
	cmp	r0, r1
	bne	Error
	
WaitMove:
	swi	SWI_KEYPAD
	cmp	r0, #0
	beq	WaitMove
	
	ldr	r1, =0x1000		@ Up button = bit 12
	cmp	r0, r1
	beq	TryUp
	
	ldr	r1, =0x4000		@ Down button = bit 14
	cmp	r0, r1
	beq	TryDown
	
	b	WaitMove		@ Anything else, keep waiting

TryUp:	
	cmp	r5, #0			@ Door must be Down to go Up
	bne	Error			@ If already up, error
	
	mov	r5, #1			@ Mark door as Up
	mov	r0, #0x02		@ Turn on RIGHT LED (door up)
	swi	SWI_LED
	b	WaitReleaseAndRestart
	
TryDown:
	cmp	r5, #1			@ Door must be Up to go Down
	bne	Error			@ If already down, error
	
	mov	r5, #0			@ Mark door as Down
	mov	r0, #0x01		@ Turn on LEFT LED (door down)
	swi	SWI_LED
	b	WaitReleaseAndRestart

Error:
	mov	r4, #4			@ Blink 4 times

BlinkLoop:
	mov	r0, #0x01
	swi	SWI_LED
	bl	Delay
	
	mov	r0, #0x02
	swi	SWI_LED
	bl	Delay
	
	subs	r4, r4, #1
	bne	BlinkLoop
	
	@ Restore correct LED based on door state
	cmp	r5, #0
	beq	RestoreDown
	
	mov	r0, #0x02		@ Door is up -> right LED
	swi	SWI_LED
	b	WaitReleaseAndRestart
	
RestoreDown:
	mov	r0, #0x01		@ Door is down -> left LED
	swi	SWI_LED
	b	WaitReleaseAndRestart


WaitReleaseAndRestart:
	push	{lr}
	bl	WaitRelease
	pop	{lr}
	b	MainLoop

@ --------------------------------------------------
@ GetDigit: waits for a digit keypress, ignoring
@ Up (0x1000) and Down (0x4000) buttons.
@ Returns the keypad bitmask value in r0.
@ --------------------------------------------------
GetDigit:
	push	{r1, lr}		@ Save lr and r1

WaitPress:
	swi	SWI_KEYPAD
	cmp	r0, #0
	beq	WaitPress		@ Nothing pressed, keep waiting

	@ Ignore the Up button (0x1000)
	ldr	r1, =0x1000
	cmp	r0, r1
	beq	IgnoreKey

	@ Ignore the Down button (0x4000)
	ldr	r1, =0x4000
	cmp	r0, r1
	beq	IgnoreKey

	@ Valid digit pressed — save it, wait for release, return
	push	{r0}
	bl	WaitRelease
	pop	{r0}
	pop	{r1, lr}
	mov	pc, lr

IgnoreKey:
	@ Not a digit key — wait for release then loop back
	bl	WaitRelease
	b	WaitPress

@ --------------------------------------------------
@ WaitRelease: spins until keypad reads 0
@ --------------------------------------------------
WaitRelease:
ReleaseLoop:
	swi	SWI_KEYPAD
	cmp	r0, #0
	bne	ReleaseLoop
	mov	pc, lr

@ --------------------------------------------------
@ Delay: simple busy-wait loop
@ --------------------------------------------------
Delay:
	ldr	r3, =150000
	
DelayLoop:
	subs	r3, r3, #1
	bne	DelayLoop
	mov	pc, lr

End:
	b	End
