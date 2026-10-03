// ============================================================ 
//
// tracktwo.c
//
// This program decodes magnetic stripe Track 2 data from
// hexadecimal input. It uses previously developed functions
// to expand hex into binary and extract 5-bit characters.
// The program locates the start sentinel, validates the
// account number, separator, additional data, and end
// sentinel, then displays the results on the LCD.
//
// Author: Elaine Nguyen
// For: CYBR 2250
//
// ============================================================

int main( int ac, char *av[] ) 
{ 
    for( unsigned i = 0; i < sizeof( data ) / sizeof( data[ 0 ] ); i++ ) 
    { 
        expand( data[ i ], expanded ); 

        int start = -1;

        //  Find start sentinel
        for (int pos = 0; pos < 160; pos++) {
            char c = byte_at(pos, expanded);

            if (c == START) {
                start = pos;
                break;
            }
        }

        // No start sentinel
        if (start == -1) {
            swi_lcd_string(0, 0, "No start sentinel");
            swi_button_wait();
            swi_clear();
            continue;
        }

        // Build decoded string (29 characters)
        char decoded[30];
        int tempPos = start;

        for (int j = 0; j < 29; j++) {
            decoded[j] = byte_at(tempPos, expanded);
            tempPos += 5;
        }
        decoded[29] = '\0';

        // Display decoded data on top line
        swi_lcd_string(0, 0, decoded);

        int pos = start + 5;

        // Check 16-digit account number
        if (!digits(pos, 16, expanded)) {
            swi_lcd_string(0, 1, "Bad account number");
            swi_button_wait();
            swi_clear();
            continue;
        }

        // Save account number
        char account[17];
        int accPos = pos;
        for (int j = 0; j < 16; j++) {
            account[j] = byte_at(accPos, expanded);
            accPos += 5;
        }
        account[16] = '\0';

        pos += 16 * 5;

        // Check separator '='
        char c = byte_at(pos, expanded);

        if (c != SEP) {
            swi_lcd_string(0, 1, "Missing separator");
            swi_button_wait();
            swi_clear();
            continue;
        }

        pos += 5;

        // Check next 10 digits
        if (!digits(pos, 10, expanded)) {
            swi_lcd_string(0, 1, "Bad extra data");
            swi_button_wait();
            swi_clear();
            continue;
        }

        // Save extra data
        char extra[11];
        int extraPos = pos;
        for (int j = 0; j < 10; j++) {
            extra[j] = byte_at(extraPos, expanded);
            extraPos += 5;
        }
        extra[10] = '\0';

        pos += 10 * 5;

        // Check end sentinel '?'
        c = byte_at(pos, expanded);

        if (c != END) {
            swi_lcd_string(0, 1, "Missing end sentinel");
            swi_button_wait();
            swi_clear();
            continue;
        }

        //
        swi_lcd_string(0, 1, "This was a good card.");

        // Display details (like your example)
        swi_lcd_string(0, 2, "Account:");
        swi_lcd_string(9, 2, account);

        swi_lcd_string(0, 3, "YYMMAAABBB:");
        swi_lcd_string(12, 3, extra);

        // wait for the users to press a button before moving on
        swi_button_wait();
        swi_clear();
    } 

    return( 0 ); 
}