#define Z80_MREQ      2   
#define Z80_WR        3   
#define Z80_BUSREQ    4   
#define DATA_SIN      5   
#define ADR_HI_SIN    6   
#define BUS_ENABLE    7   
#define BUS_LOAD      8   
#define BUS_CLK       9   
#define Z80_RESET     10  
#define ADR_LO_SIN    12  
#define Z80_RD        18
#define Z80_IORQ      19
#define LED           13

typedef struct {
  unsigned char QA : 1;
  unsigned char QB : 1;  
  unsigned char QC : 1;
  unsigned char QD : 1;  
  unsigned char QE : 1;
  unsigned char QF : 1;  
  unsigned char QG : 1;  
  unsigned char QH : 1;    
} T74595OUT;

typedef struct {
  unsigned char D0 : 1;  
  unsigned char D1 : 1;  
  unsigned char D2 : 1;    
  unsigned char D3 : 1;
  unsigned char D4 : 1;    
  unsigned char D5 : 1;
  unsigned char D6 : 1;  
  unsigned char D7 : 1;
} TData;

typedef struct {
  unsigned char A0 : 1;  
  unsigned char A1 : 1;  
  unsigned char A2 : 1;    
  unsigned char A3 : 1;
  unsigned char A4 : 1;    
  unsigned char A5 : 1;
  unsigned char A6 : 1;  
  unsigned char A7 : 1;
} TAddressLo;

typedef struct {
  unsigned char A8 : 1;  
  unsigned char A9 : 1;  
  unsigned char A10 : 1;    
  unsigned char A11 : 1;
  unsigned char A12 : 1;    
  unsigned char A13 : 1;
  unsigned char A14 : 1;  
  unsigned char A15 : 1;
} TAddressHi;

typedef union {
  unsigned char rawByte;
  TData         data;
  TAddressHi    addrHi;  
  TAddressLo    addrLo;    
  T74595OUT     outs;
} TWires;

unsigned char wireDataBus( unsigned char in ) {
  TWires z80pins, serReg;
  z80pins.rawByte = in;
  serReg.outs.QC = z80pins.data.D7;
  serReg.outs.QE = z80pins.data.D6;  
  serReg.outs.QF = z80pins.data.D5;
  serReg.outs.QH = z80pins.data.D4;  
  serReg.outs.QG = z80pins.data.D3;
  serReg.outs.QD = z80pins.data.D2;  
  serReg.outs.QA = z80pins.data.D1;
  serReg.outs.QB = z80pins.data.D0;  
  return serReg.rawByte;
}

unsigned char wireAddrHi( unsigned char in ) {
  TWires z80pins, serReg;
  z80pins.rawByte = in;
  serReg.outs.QA = z80pins.addrHi.A15;
  serReg.outs.QB = z80pins.addrHi.A14;  
  serReg.outs.QC = z80pins.addrHi.A13;  
  serReg.outs.QD = z80pins.addrHi.A12;           
  serReg.outs.QE = z80pins.addrHi.A11;         
  serReg.outs.QF = z80pins.addrHi.A10;         
  serReg.outs.QG = z80pins.addrHi.A9;       
  serReg.outs.QH = z80pins.addrHi.A8;    
  return serReg.rawByte;
}


unsigned char wireAddrLo( unsigned char in ) {
  TWires z80pins, serReg;
  z80pins.rawByte = in;
  serReg.outs.QA = z80pins.addrLo.A7;
  serReg.outs.QH = z80pins.addrLo.A6;  
  serReg.outs.QB = z80pins.addrLo.A5;  
  serReg.outs.QC = z80pins.addrLo.A4;           
  serReg.outs.QD = z80pins.addrLo.A3;         
  serReg.outs.QE = z80pins.addrLo.A2;         
  serReg.outs.QF = z80pins.addrLo.A1;       
  serReg.outs.QG = z80pins.addrLo.A0;      
  return serReg.rawByte;
}

void releaseBus() {
  // zwracamy szyny do Z80
  pinMode( Z80_WR, INPUT );
  pinMode( Z80_MREQ, INPUT );
  pinMode( Z80_RD, INPUT );
  pinMode( Z80_IORQ, INPUT );
  digitalWrite( BUS_ENABLE, HIGH );
  digitalWrite( Z80_BUSREQ, HIGH );
  digitalWrite( LED, LOW );           
}

void requestBus() {
  // zabieramy szyny Z80
  digitalWrite( Z80_BUSREQ, LOW );
  pinMode( Z80_WR, OUTPUT );    digitalWrite( Z80_WR, HIGH );  
  pinMode( Z80_MREQ, OUTPUT );  digitalWrite( Z80_MREQ, HIGH );    
  pinMode( Z80_RD, OUTPUT );    digitalWrite( Z80_RD, HIGH );  
  pinMode( Z80_IORQ, OUTPUT );  digitalWrite( Z80_IORQ, HIGH );      
  digitalWrite( BUS_ENABLE, LOW ); // dawaj!
  digitalWrite( LED, HIGH );           
}

void resetZ80() {
  digitalWrite( Z80_RESET, HIGH ); 
  delay (200);
  digitalWrite( Z80_RESET, LOW );   
}

void setup() {
  pinMode( BUS_ENABLE, OUTPUT ); digitalWrite( BUS_ENABLE, HIGH );  
  pinMode( BUS_LOAD, OUTPUT ); digitalWrite( BUS_LOAD, LOW ); 
  pinMode( BUS_CLK, OUTPUT ); digitalWrite( BUS_CLK, LOW ); 
  pinMode( DATA_SIN, OUTPUT ); digitalWrite( DATA_SIN, LOW );
  pinMode( ADR_LO_SIN, OUTPUT ); digitalWrite( ADR_LO_SIN, LOW );  
  pinMode( ADR_HI_SIN, OUTPUT ); digitalWrite( ADR_HI_SIN, LOW );    
  pinMode( Z80_BUSREQ, OUTPUT ); digitalWrite( Z80_BUSREQ, HIGH );       
  pinMode( Z80_RESET, OUTPUT ); digitalWrite( Z80_RESET, LOW );         
  releaseBus();
  Serial.begin( 19200 );

  pinMode( LED, OUTPUT ); digitalWrite( LED, LOW );         
}

void setMemoryLocation (unsigned short address, unsigned char data ) {
    unsigned char addressHi = wireAddrHi ( address >> 8 );
    unsigned char addressLo = wireAddrLo ( address & 0xFF );    
    unsigned char memData = wireDataBus( data );
    // wyslij adres i dane
    digitalWrite( BUS_LOAD, LOW );
    for (int i = 0; i < 8 ; i++ ) {
      digitalWrite( ADR_HI_SIN, 0x80 & (addressHi << i) );    
      digitalWrite( ADR_LO_SIN, 0x80 & (addressLo << i) );    
      digitalWrite( DATA_SIN, 0x80 & (memData << i) );    
      digitalWrite( BUS_CLK, HIGH ); 
      digitalWrite( BUS_CLK, LOW );             
    } 
    digitalWrite( BUS_LOAD, HIGH );    
    // cykl zapisu /MEMR=L, /WR=L
    digitalWrite( Z80_MREQ, LOW );    
    digitalWrite( Z80_WR, LOW );  
    digitalWrite( Z80_WR, HIGH );          
    digitalWrite( Z80_MREQ, HIGH );        
}

char ch = 0;
String rxFrame = "";

void processFrame( char *pS ) {
  char szTemp[5] = "";
  int  recLen = 0;
  unsigned char data = 0;
  unsigned short address = 0;

  strncpy(szTemp, pS+1, 2 );  szTemp[ 2 ] = 0x00;
  recLen = (int)strtol( szTemp, 0, 16 );
  
  strncpy(szTemp, pS+3, 4 );  szTemp[ 4 ] = 0x00;
  address = (unsigned short)strtol( szTemp, 0, 16 );

  for (int i = 0; i < recLen; i++ ) {
    strncpy(szTemp, pS+9 + i*2, 2 );  szTemp[ 2 ] = 0x00;
    data = (unsigned char)strtol( szTemp, 0, 16 );
    setMemoryLocation( address + i , data );     
  }
}

int isHexFrame ( char *f ) {
  // przepraszam za to :(
  return (strlen(f) > 11 ) && ( f[0] == ':' ) && (f[7] == '0') && (f[8] == '0');
}


void loop() {  
  if (Serial.available() > 0) {
    char ch = Serial.read();            
    if ( ch == 0x0D /*CR*/) {
      return;
    }
    if ( ch == 0x0A /*LF*/ ) {      
      if ( rxFrame == ":00000001FF" ) {
          releaseBus();  
          Serial.println("30 bus released" );                    
      }      
      if ( rxFrame == ":reset" ) {      
          resetZ80();                          
          Serial.println("40 cpu reset" );                    
      }      
      if ( rxFrame == ":dml" ) {
          requestBus();    
          Serial.println("10 bus captured" );          
      }      
      if ( rxFrame == ":ini" ) {
        Serial.println( "00 CA80 Direct Memory Loader, tasza (c) 2019" );        
      }
      if ( isHexFrame( rxFrame.c_str() ) ) {
        processFrame( rxFrame.c_str() );
        Serial.println( "20 " + rxFrame.substring(3, 7) );
      }
      rxFrame = "";          
    }
    else {
      rxFrame += ch;      
    }
  }
}
