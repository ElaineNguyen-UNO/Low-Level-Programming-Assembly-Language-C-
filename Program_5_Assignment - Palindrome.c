// ============================================================
// palindrome.c
// ============================================================

#include <ctype.h>   // <-- THIS is what we're adding

#define IN_SIZE     100
#define TRUE        1
#define FALSE       0
#define READ        0
#define STDOUT      1

int swi_open( const char *name, int mode );
void swi_close( int );
int swi_read( int fd, char *dest, int max_bytes );
void swi_write( int fd, char *str );

__asm( "\n\n\n"
     "@ ============================\n"
     "@ Some glue logic for ARMsim\n"
     "@ ============================\n"
     "swi_open:        swi   0x66\n"
     "                 mov   pc, lr\n\n"
     "swi_close:       swi   68\n"
     "                 mov   pc, lr\n\n"
     "swi_read:        swi   0x6a\n"
     "                 mov   pc, lr\n\n"
     "swi_write:       swi   0x69\n"
     "                 mov   pc, lr\n\n"
     );

char buffer[ IN_SIZE ];

int main( int ac, char *av[] )
{
    int bytes_read;
    int fd = swi_open( "\\Users\\Student\\Desktop\\pal.txt", READ );

    if ( fd < 0 )
    {
        swi_write( STDOUT, "I could not open the file...\n" );
        return( 1 );
    }

    while ( ( bytes_read = swi_read( fd, buffer, IN_SIZE - 1 ) ) > 0 )
    {
        int pal = TRUE;

        buffer[ bytes_read ] = '\0';

        swi_write( STDOUT, "Testing: " );
        swi_write( STDOUT, buffer );
        swi_write( STDOUT, "\n" );

        // ============================================
        // STEP 1: Remove spaces
        // ============================================

        char cleaned[ IN_SIZE ];
        int j = 0;

        for ( int i = 0; buffer[i] != '\0'; i++ )
        {
            if ( !isspace(buffer[i]) )   // <-- CLEAN
            {
                cleaned[j++] = buffer[i];
            }
        }
        cleaned[j] = '\0';

        swi_write( STDOUT, "No spaces: " );
        swi_write( STDOUT, cleaned );
        swi_write( STDOUT, "\n" );

        // ============================================
        // STEP 2: Convert to uppercase
        // ============================================

        for ( int i = 0; cleaned[i] != '\0'; i++ )
        {
            if ( islower(cleaned[i]) )   // <-- optional but clear
            {
                cleaned[i] = toupper(cleaned[i]);
            }
        }

        swi_write( STDOUT, "Uppercase: " );
        swi_write( STDOUT, cleaned );
        swi_write( STDOUT, "\n" );

        // ============================================
        // STEP 3: Palindrome check
        // ============================================

        int left = 0;
        int right = j - 1;

        while ( left < right )
        {
            if ( cleaned[left] != cleaned[right] )
            {
                pal = FALSE;
                break;
            }

            left++;
            right--;
        }

        // ============================================
        // RESULT
        // ============================================

        swi_write( STDOUT, pal ? "It IS!!!\n\n" : "Alas, no...\n\n" );
    }

    swi_close( fd );
    return( 0 );
}