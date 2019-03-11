#define ZK_01  0x06  // 1 1 0 
#define ZK_02  0x05  // 1 0 1
#define ZK_03  0x03  // 0 1 1

#define ZK_04   0x07
#define ZK_05   0x08
#define ZK_06   0x06
#define ZK_07   0x09
#define ZK_08   0x0F
#define ZK_09   0x0A
#define ZK_10   0x0B
#define ZK_11   0x0C
#define ZK_12   0x0D
#define ZK_13   0x0E

#define HOLD_TIME  15000

unsigned char kbdState[ 0x10 ]; // bitowy obraz matrycy kbd
int keyPressedCounter = 0;    // licznik przytrzymania klaw.
char rxByte = 0x00;         //znaczek z mastera
unsigned char select = 0;   // indeks hashmapy klawiatury
int kbdLock = 1; // inicjalnie blokuj kbd przed czlowiekiem

void setup() {  
  DDRC  = 0b00000000;  // C-in
  DDRD  = 0b00111100;  // D-2/5 out   
  PORTD = 0b00011100;
  // zwolnienie klawiszy
  memset ( kbdState, 7, sizeof( kbdState ) );  
  Serial.begin( 9600 );
}

void loop() {
  select = PINC & 0x0F; // stan skanowania z CA80   
  PORTD = ( kbdLock ? 0x00 : 0x20 ) | ( kbdState[ select ] << 2 );
  if ( Serial.available() > 0 ) {
      rxByte = Serial.read();            
      switch ( rxByte ) {
        case 'r':
                DDRD  = 0b00100000; // linie kbd na IN 
                PORTD = 0b00100000; // zgas diodke
                kbdLock = 0;
                break;
        case 'l':
                DDRD  = 0b00111100; // kbd na out
                PORTD = 0b00011100; // zapal diodke                
                kbdLock = 1;
                break;                
        case 'm': kbdState[ ZK_06 ] = ZK_02;  break;
        case '0': kbdState[ ZK_11 ] = ZK_01;  break;
        case '1': kbdState[ ZK_12 ] = ZK_01;  break;
        case '2': kbdState[ ZK_13 ] = ZK_03;  break;
        case '3': kbdState[ ZK_13 ] = ZK_02;  break;
        case '4': kbdState[ ZK_11 ] = ZK_03;  break; 
        case '5': kbdState[ ZK_10 ] = ZK_03;  break; 
        case '6': kbdState[ ZK_10 ] = ZK_02;  break; 
        case '7': kbdState[ ZK_11 ] = ZK_02;  break; 
        case '8': kbdState[ ZK_08 ] = ZK_03;  break; 
        case '9': kbdState[ ZK_07 ] = ZK_03;  break; 
        case 'a': kbdState[ ZK_07 ] = ZK_02;  break; 
        case 'b': kbdState[ ZK_08 ] = ZK_02;  break; 
        case 'c': kbdState[ ZK_05 ] = ZK_03;  break; 
        case 'd': kbdState[ ZK_04 ] = ZK_03;  break; 
        case 'e': kbdState[ ZK_04 ] = ZK_02;  break; 
        case 'f': kbdState[ ZK_05 ] = ZK_02;  break; 
        case 'g': kbdState[ ZK_09 ] = ZK_02;  break; 
        case '.': kbdState[ ZK_12 ] = ZK_02;  break; 
        case '=': kbdState[ ZK_13 ] = ZK_01;  break;
        default: rxByte = 0x00;  break;         
      } 
      if ( rxByte ) {
        // "wciskaj" tylko zdefiniowane klawisze
        keyPressedCounter = HOLD_TIME;        
      }
  }
  if ( keyPressedCounter != 0 ) {
    keyPressedCounter--;
    if ( keyPressedCounter == 0 ) {
      // "zwolnij" klawisz
      memset ( kbdState, 7, sizeof( kbdState ) );
      Serial.write( rxByte ); // echo      
    }
  }
}
