@ ========================================
@
@ Program 3 Support Functions
@
@ This program contains helper functions
@ used by the main program. The functions
@ convert hexadecimal characters to binary,
@ extract 5-bit values from the binary
@ string, and display characters on the LCD.
@
@ Author: Elaine Nguyen
@ For: CYBR 2250
@
@ ========================================

.text

@ --------------------------------------------------
@ lcd
@ Displays a single character on the LCD screen.
@
@ Inputs:
@   r0 = x position (0-39)
@   r1 = y position (0-14)
@   r2 = character to display
@
@ Output:
@   Character appears on the LCD
@ --------------------------------------------------

.global lcd
lcd:
    swi 0x207          @ software interrupt to display char on LCD
    mov pc, lr         @ return to the calling function



@ --------------------------------------------------
@ expand
@ Converts a hexadecimal string into a binary string.
@
@ Example:
@   Input:  "A3"
@   Output: "10100011"
@
@ r0 = pointer to hex string
@ r1 = pointer to destination buffer
@ --------------------------------------------------

.global expand
expand:

    push {r4-r6, lr}   @ save registers that will be modified

    mov r5, #'1'       @ store ASCII value of '1'
    mov r6, #'0'       @ store ASCII value of '0'

main_loop:

    ldrb r4, [r0], #1  @ load next hex character and move pointer forward
    cmp r4, #0         @ check for end of string (null terminator)
    beq expand_done    @ if end reached, exit function

    cmp r4, #'9'       @ determine if char is 0-9
    ble digit          @ branch if numeric digit

    sub r4, r4, #0x37  @ convert ASCII A-F to numeric value (10-15)
    b convert_bits     @ process bits of the hex value

digit:
    sub r4, r4, #0x30  @ convert ASCII 0-9 to numeric value


@ --------------------------------------------------
@ convert_bits
@ Converts the numeric hex value (0-15) into
@ four binary digits and stores them as
@ ASCII characters '0' or '1'.
@ --------------------------------------------------

convert_bits:

    @ check bit 8 (most significant bit)
    tst r4, #8
    beq bit8_zero
    strb r5, [r1], #1  @ store '1'
    b bit8_done
bit8_zero:
    strb r6, [r1], #1  @ store '0'
bit8_done:

    @ check bit 4
    tst  r4, #4
    beq  bit4_zero
    strb r5, [r1], #1
    b 	 bit4_done
bit4_zero:
    strb r6, [r1], #1
bit4_done:

    @ check bit 2
    tst  r4, #2
    beq  bit2_zero
    strb r5, [r1], #1
    b 	 bit2_done
bit2_zero:
    strb r6, [r1], #1
bit2_done:

    @ check bit 1 (least significant bit)
    tst  r4, #1
    beq  bit1_zero
    strb r5, [r1], #1
    b 	 bit1_done
bit1_zero:
    strb r6, [r1], #1
bit1_done:

    b main_loop        @ repeat for next hex character


expand_done:

    pop {r4-r6, pc}    @ restore registers and return



@ --------------------------------------------------
@ byte_at
@
@ Reads five binary characters from a binary string
@ and converts them into a number (0-31). The number
@ is then used as an index into a lookup table to
@ obtain the corresponding ASCII character.
@
@ Inputs:
@   r0 = starting index within binary string
@   r1 = pointer to binary string
@
@ Output:
@   r0 = ASCII character from conversion table
@ --------------------------------------------------

.global byte_at
byte_at:

    add r1, r1, r0     @ move pointer to starting position in binary string

    mov r0, #0         @ initialize result value

    @ read first bit (value 16)
    ldrb  r2, [r1], #1
    cmp   r2, #'1'
    orreq r0, r0, #16

    @ read second bit (value 8)
    ldrb  r2, [r1], #1
    cmp   r2, #'1'
    orreq r0, r0, #8

    @ read third bit (value 4)
    ldrb  r2, [r1], #1
    cmp   r2, #'1'
    orreq r0, r0, #4

    @ read fourth bit (value 2)
    ldrb  r2, [r1], #1
    cmp   r2, #'1'
    orreq r0, r0, #2

    @ read fifth bit (value 1)
    ldrb  r2, [r1], #1
    cmp   r2, #'1'
    orreq r0, r0, #1

    @ lookup character from conversion table
    ldr  r1, =convert
    ldrb r0, [r1, r0]

    mov  pc, lr         @ return to caller



@ --------------------------------------------------
@ conversion lookup table
@
@ Maps numbers 0-31 to ASCII characters used
@ to draw the LCD message.
@ --------------------------------------------------

.data

convert:
    .ascii "E12E4EE78EE;E=>E0EE3E56EE9:E<EE?"