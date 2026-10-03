// ============================================================
//
// validate.c
//
// Author: Elaine Nguyen
// Course: CYBR 2250
//
// Description:
// This program reads password/message pairs from a file
// and determines whether each message is valid based on
// the given password. The validation is performed using
// an ARM assembly function (check.s).
//
// The program converts both the password and message to
// lowercase before passing them to the assembly function
// for case-insensitive comparison.
//
// ============================================================

        .text                   @ Place following code in the text (code) section
        .align 4                @ Align instructions on 4-byte boundary (required for ARM)

#============================================================
# check
#
# R0: password base address (points to start of password string)
# R1: message base address  (points to start of message string)
# R2: password index        (offset into password array)
# R3: message index         (offset into message array)
# R4: password char         (current character from password)
# R5: message char          (current character from message)
#
# Return:
#   R0 = 1 (TRUE)  if valid
#   R0 = 0 (FALSE) if invalid
#============================================================

        .global check          @ Make function visible so C code can call it
check:
        mov     r2, #0         @ Initialize password index to 0 (start at first char)
        mov     r3, #0         @ Initialize message index to 0 (start at first char)

#------------------------------------------------------------
# LOOP through message
#------------------------------------------------------------
loop:
        ldrb    r5, [r1, r3]   @ Load 1 byte from memory: message[r3] → r5
                               @ This gets the current character from the message

        cmp     r5, #0         @ Compare message character to null terminator '\0'
                               @ '\0' means end of the string in C

        beq     fail           @ If we reached end of message BEFORE finishing password
                               @ then the message is invalid → branch to fail

        ldrb    r4, [r0, r2]   @ Load 1 byte from memory: password[r2] → r4
                               @ This gets the current character we are trying to match

#------------------------------------------------------------
# Compare characters (already lowercase from C)
#------------------------------------------------------------
        cmp     r4, r5         @ Compare password character with message character

        beq     match          @ If equal, we found the next required character
                               @ → branch to match section

        add     r3, r3, #1     @ If not equal, increment message index (r3++)
                               @ Move to next character in message

        b       loop           @ Repeat loop to check next message character

#------------------------------------------------------------
# MATCH
#------------------------------------------------------------
match:
        add     r2, r2, #1     @ Increment password index (r2++)
                               @ Move to next character in password

        ldrb    r4, [r0, r2]   @ Load next password character into r4

        cmp     r4, #0         @ Check if this character is '\0'
                               @ '\0' means we reached end of password

        beq     success        @ If end of password reached, all chars matched
                               @ → message is valid → branch to success

        add     r3, r3, #1     @ Move to next character in message (continue scanning)

        b       loop           @ Continue searching for next password character

#------------------------------------------------------------
# SUCCESS
#------------------------------------------------------------
success:
        mov     r0, #1         @ Set return value to 1 (TRUE / valid message)

        bx      lr             @ Return to caller (back to C program)
                               @ lr = link register (stores return address)

#------------------------------------------------------------
# FAIL
#------------------------------------------------------------
fail:
        mov     r0, #0         @ Set return value to 0 (FALSE / invalid message)

        bx      lr             @ Return to caller
