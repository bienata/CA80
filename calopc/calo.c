//
// CA80 simple hex loader
// build:  gcc calo.c -o calo
// tasza, 2019

#include <stdio.h>
#include <fcntl.h>
#include <termios.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

char getResponse ( int hSerial ) {
    int bytes_read;
    char ch;
    while ( ( bytes_read = read( hSerial, &ch, 1 ) > 0 ) ) {    
        if ( ( ch == '.' ) || ( ch == '-') || (ch == '!') ) {
            return ch;
        }
    }    
    return '?'; 
}

int setupSerial( int hSerial, int bauds ) {
    
    struct termios cfg;
    // odczytaj bieżący setup
    if ( tcgetattr( hSerial, &cfg ) < 0 ) {
        printf("11,err, tcgetattr, handle %d\n", hSerial );        
        return -1;
    }
    cfsetispeed( &cfg , bauds );        // rx
    cfsetospeed( &cfg , bauds );        // tx
    // 8N1
    cfg.c_cflag &= ~PARENB;             // bez parzystości
    cfg.c_cflag &= ~CSTOPB;             // 1 stop
    cfg.c_cflag &= ~CSIZE;	        // zmiana rozmiaru ramki
    cfg.c_cflag |=  CS8;                             // nowy rozmiar 8
    cfg.c_cflag &= ~CRTSCTS;                         // wyłacz kontrolę sprzętową
    cfg.c_cflag |= CREAD | CLOCAL;                   // RX on, ignoruj linie modemowe
    cfg.c_iflag &= ~(IXON | IXOFF | IXANY);          // bez XON/XOFF
    // https://www.gnu.org/software/libc/manual/html_node/Canonical-or-Not.html
    cfg.c_iflag &= ~(ICANON | ECHO | ECHOE | ISIG);  // tryb niekanoniczny
    cfg.c_oflag &= ~OPOST;                           // nie przetwarzaj wyjścia
    // timeout-y
    // https://www.gnu.org/software/libc/manual/html_node/Noncanonical-Input.html#Noncanonical-Input
    // https://blog.mbedded.ninja/programming/operating-systems/linux/linux-serial-ports-using-c-cpp/#reading    
    cfg.c_cc[VMIN] = 0;                              // odczytaj co najmniej 1 znaczek
    cfg.c_cc[VTIME] = 2;                             // czekaj 100ms * 2
    tcsetattr( hSerial, TCSANOW, &cfg );
}



int main( int argc, char *argv[] ) {
    
    int hSerial;
    FILE *hFile;
    char szLine[0xFF];
    
    char szFileName[0xFF];
    char szPortName[0xFF];    
        
    printf( "calo, simple CA80 hex serial loader, tasza (c) 2019\n" );
    
    if ( argc != 3) {
       printf( "usage example:      first, run loader app on CA80  \n" );
       printf( "then type in shell: calo /dev/ttyUSB1 myprogram.hex\n" );
       return -1;
    }

    strcpy ( szPortName, argv[1] );
    strcpy ( szFileName, argv[2] );    
    
    printf( "[%s] file to send via [%s] device\n", szFileName, szPortName );    
    // otworz hexa i policz linie
    if( ( hFile = fopen( szFileName, "r" ) ) == NULL ) {
        printf("01,err,unable to open %s file\n", szFileName );
        return -1;
    }
        
    if ( (hSerial = open( szPortName, O_RDWR | O_NOCTTY )) == -1 ) {
        printf("02,err,unable to open %s port\n", szPortName );
        return -1;
    }

    if ( setupSerial( hSerial,  B19200 ) ) {
        printf("03,err,unable to setup %s port\n", szPortName );
        return -1;
    }

    tcflush( hSerial, TCIFLUSH );      // wietrzenie buforów

    printf("loading\n");
    // czytaj i wysylaj 
    while( fgets( szLine, sizeof(szLine), hFile) != NULL ) {
        write ( hSerial, szLine, strlen( szLine ) );
        printf("%s", szLine );                            
        char resp = getResponse( hSerial );
        if ( resp == '.' ) {            
            continue;
        }
        else if ( resp == '-' ) {            
            printf("done\n");
            break;
        }
        else if ( resp == '!' ) {
            printf("88,err,load error (CA80 reported) on %s\n", szLine );                
            close( hSerial );
            return -1;
        }
        else {
            printf("77,err,CA80 link failure\n" );                
            close( hSerial );
            return -1;            
        }
    }    
    close( hSerial );
    return 0;
}

