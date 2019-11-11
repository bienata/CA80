/*
This example program makes use of the simple
sound library to generate a sine wave and write the
output to sound.wav.
For complete documentation on the library, see:
http://www.nd.edu/~dthain/courses/cse20211/fall2013/wavfile
Go ahead and modify this program for your own purposes.
*/

/*
	intel hex 2 wav, tasza (c) 2019

	gcc -o hex2wav hex2wav.c wavfile.c -lm



*/
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <errno.h>
#include "wavfile.h"
#include <unistd.h>

#define	CARRIER_FREQ 		3500			// nosna generatorka magnetofonu
#define OMAG_BAUDS_15		240				//
#define OMAG_BAUDS_25		140				// parametr OMAG, 25h, domyslny
#define OMAG_BAUDS_35		100				//
#define OMAG_SYNCH_LEN		32				// liczba bajtow synchronizacji
#define SIG_VOL_HIGH 		32000			// amplituda dla 16 bit próbek


typedef struct {
	int bVerbose;
	int bInFileName;
	int bProgName;
	int bAddress;
	int bMagId;
	int bSynchLen;
	int bCarrierFreq;
	int bOutFileName;
	int nSynchLen;
	int nCarrierFreq;
	int nMagSpeed;
	unsigned short nAddress;
	unsigned char  uchProgName;
	char inFileName[ 0xFF ];
	char outFileName[ 0xFF ];
	int nSamplesPerBit;
} THex2WavSetup;

#define HEX2WAV_OPTIONS		":vi:n:e:m:s:f:o:"

THex2WavSetup	h2wSetup;		// globalna strukturka na ustawienia


//------------------------------------------------------------------------------------

// zmiana ciagu znaczkow ASCII na bin-a
long hex2bin( char *s ){
    char *p = s;
    long n = 0;
    while( *p != 0 ){
        n <<= 4;
        n +=  ( *p < 'A' ) ? *p & 0xF : ( *p & 0x7 ) + 9;
        p++;
    }
    return n;
}

//------------------------------------------------------------------------------------

// rozpoznawanie zachciewajek uzytkownika
int processOptions( int argc, char *argv[], THex2WavSetup *pSetup ) {
	int opt;

	memset ( pSetup, 0x00, sizeof(THex2WavSetup) );

	pSetup->nCarrierFreq = CARRIER_FREQ;
	pSetup->nSynchLen = OMAG_SYNCH_LEN;

	while(( opt = getopt( argc, argv, HEX2WAV_OPTIONS )) != -1 ) {
		switch( opt ) {
			case 'v':
				pSetup->bVerbose = 1;
				break;
			case 'i':
				strcpy ( pSetup->inFileName, optarg );
				pSetup->bInFileName = 1;
				break;
			case 'n':
				pSetup->uchProgName = hex2bin( optarg );
				pSetup->bProgName = 1;
				break;
			case 'e':
				pSetup->nAddress = hex2bin( optarg );
				pSetup->bAddress = 1; // dodawaj EOF
				break;
			case 'm':
				pSetup->bMagId = atoi( optarg );
				break;
			case 's':
				pSetup->nSynchLen = atoi( optarg );
				pSetup->bSynchLen = 1;
				break;
			case 'f':
				pSetup->nCarrierFreq = atoi( optarg );
				pSetup->bCarrierFreq = 1;
				break;
			case 'o':
				strcpy ( pSetup->outFileName, optarg );
				pSetup->bOutFileName = 1;
				break;
		}
	}

	if ( !pSetup->bInFileName && !pSetup->bAddress ) {
		printf("address is required for EOF record\n");
		return 1;
	}

	if (!pSetup->bOutFileName) {
		printf("output file name is mandatory\n");
		return 1;
	}

	if (!pSetup->bProgName) {
		printf("program name (id) is mandatory\n");
		return 1;
	}

	switch ( pSetup->bMagId ) {
		case 15:
			pSetup->nMagSpeed = OMAG_BAUDS_15;
			break;
		case 0:
		case 25:
			pSetup->nMagSpeed = OMAG_BAUDS_25;
			break;
		case 35:
			pSetup->nMagSpeed = OMAG_BAUDS_35;
			break;
		default:
			printf("magspeed error, select one of: 15 (240b/s), 25 (140b/s) or 35 (100b/s)\n");
			return 1;
	}

	pSetup->nSamplesPerBit = WAVFILE_SAMPLES_PER_SECOND/pSetup->nMagSpeed;

	return 0;
}

//------------------------------------------------------------------------------------

// dodaje 1 bit danych do strumienia próbek ##__ dla 1,  __## dla 0
void appendDataBit (unsigned char aBit, short *pWave, long *pSamplesCntr ){
	int b;
	int nibbleVolume;
	for ( b = 0; b < h2wSetup.nSamplesPerBit; b++ ) {
		if ( b < h2wSetup.nSamplesPerBit/2 ) {
			// gorna polowka bajta (hi nibble)
			nibbleVolume = aBit ? SIG_VOL_HIGH : 0;
		}
		else {
			// dolna polowka
			nibbleVolume = aBit ? 0 : SIG_VOL_HIGH;			
		}
		// dziedzina czasu zrobiona z kolejnych próbek
		double t = (double)(*pSamplesCntr)/WAVFILE_SAMPLES_PER_SECOND;	
		// dodaj próbki lub cisze
		pWave[ *pSamplesCntr ] = nibbleVolume * sin( h2wSetup.nCarrierFreq * t * 2*M_PI );
		(*pSamplesCntr)++;	// przesuń znacznik
	}
}

//------------------------------------------------------------------------------------

// dodaje cisze o dlugosci 1 bitu
void appendStopBit (short *pWave, long *pSamplesCntr ){
	int b;
	for (b = 0; b < h2wSetup.nSamplesPerBit; b++ ) {
		pWave[ *pSamplesCntr ] = 0;
		(*pSamplesCntr)++;
	}
}

//------------------------------------------------------------------------------------

// dodaje bajt - bit startu+8xbit danych (od lsb), 2 bity stopu/ciszy
void appendByte (unsigned char uchByte, short *pWave, long *pSamplesCntr ){
	if ( h2wSetup.bVerbose ) {
		printf( "%02X ", uchByte );
	}
	int n;
	//bit startu
	appendDataBit( 1, pWave, pSamplesCntr );
	// 8 bitow danych
	for (n = 0; n < 8; n++ ) {
		appendDataBit( (uchByte >> n ) & 0x01 , pWave, pSamplesCntr );
	}
	//dwa bity stopu
	appendStopBit( pWave, pSamplesCntr );
	appendStopBit( pWave, pSamplesCntr );
}

//------------------------------------------------------------------------------------

//  dodaje znacznik EOF 
void appendEOF (unsigned char uchName, unsigned short startAddress, short *pWave, long *pSamplesCntr ) {
	unsigned char crc = 0;
	unsigned char loAddress = startAddress;
	unsigned char hiAddress = startAddress >> 8 ;

	crc = uchName + loAddress + hiAddress;
	crc = 0x100 - crc;
	// zpr :)
	appendByte( 0xFD,  pWave, pSamplesCntr  );
	appendByte( 0xE2,  pWave, pSamplesCntr  );
	// nazwa
	appendByte( uchName,  pWave, pSamplesCntr  );
	// len = 0!
	appendByte( 0x00,  pWave, pSamplesCntr  );
	//adr wejscia 
	appendByte( loAddress,  pWave, pSamplesCntr  );
	appendByte( hiAddress,  pWave, pSamplesCntr  );
	// SUMN
	appendByte( crc,  pWave, pSamplesCntr  );
	if ( h2wSetup.bVerbose ) {
		printf("\n");
	}
}

//------------------------------------------------------------------------------------

// oblicza rozmiar bufora w bajtach, tak aby zmiescic w nim dane z IHEX
// bierze pod uwage narzut formatu magnetofonowego (znaczniki, sumy kontrolne etc)
// kazda linijka z IHEX to: N - danych, 8 - systemowe opakowanie
// 
// opakowanie:  2 - Znacznik Początku Rekordu, 1 - nazwa, 1 - dlugosc, 2 - adres, 1 - suma naglowka, 1 - suma rekordu
// calosciowo 6 bajtow
//
int calculateDataSize ( FILE *pF ) {
	int cntr = 0;
	char szLine [0xFF];
	char s[8];
	while( fgets( szLine, sizeof(szLine), pF) != NULL ) {
		// eof - omin, 7/8 znaczek , skip jak 01
		if ( strncmp( szLine+7, "01",2 ) == 0 ) {
			continue;
		}
		// ile bajtow w rekordzie?
		memset ( s, 0x00, sizeof(s) );
		strncpy ( s, szLine + 1, 2 );
		cntr += hex2bin( s ) + 8; // 8 = ZPR.2 + NAZ.1 + DL.1 + ADR.2 + SUMN.1 + SUMD.1
    }
	fseek ( pF , 0 , SEEK_SET );
	return cntr;
}

//------------------------------------------------------------------------------------

// dodaje rozbiegowke - 32 bajty 0x00 na synchronizacje
void appendSynch ( short *pWave, long *pSamplesCntr ) {
	int p;
	for ( p = 0; p < h2wSetup.nSynchLen; p++ ) {
		appendByte( 0x00, pWave, pSamplesCntr );
	}
	if ( h2wSetup.bVerbose ) {
		printf("\n");
	}
}

//------------------------------------------------------------------------------------

// dodaje dane z rekordu IHEX opakowane w naglowek i sumy kontrl. 
void appendHex (char *pHex, unsigned char uchName, short *pWave, long *pSamplesCntr ) {
	unsigned char crc = 0;
	unsigned char bytesNum;
	int i;	
	char s [8];
	
	// ile bajtów w rekordzie?
	memset ( s, 0x00, sizeof(s) );
	strncpy ( s, pHex + 1, 2 );
	bytesNum = hex2bin( s );
	
	// adres rekordu
	strncpy ( s, pHex + 3, 2 ); s[2] = 0x00;
	unsigned char hiAddress = hex2bin (s);
	strncpy ( s, pHex + 5, 2 ); s[2] = 0x00;
	unsigned char loAddress = hex2bin (s);

	// dodaj naglowek
	appendByte( 0xFD,  pWave, pSamplesCntr  );
	appendByte( 0xE2,  pWave, pSamplesCntr  );
	appendByte( uchName,  pWave, pSamplesCntr  );
	appendByte( bytesNum, pWave, pSamplesCntr  );
	appendByte( loAddress, pWave, pSamplesCntr  );
	appendByte( hiAddress, pWave, pSamplesCntr  );
	// suma kontrolna naglowka
	crc = uchName + bytesNum + hiAddress + loAddress;
	crc = 0x100 - crc;
	appendByte( crc,  pWave, pSamplesCntr  );
	crc = 0;
	// blok danych
	for ( i = 0; i < bytesNum; i++ ) {
		strncpy ( s, pHex + 9 + i*2, 2 ); s[2] = 0x00;
		unsigned char byte = hex2bin (s);
		crc += byte;
		appendByte( byte, pWave, pSamplesCntr  );
	}
	crc = 0x100 - crc;
	// suma kontrolna danych
	appendByte( crc,  pWave, pSamplesCntr  );
	if ( h2wSetup.bVerbose ) {
		printf("\n");
	}
}

//------------------------------------------------------------------------------------

// czyta IHEX linia po lini, omija EOF-a, dodaje kolejne rekordy(linie) 
void processHexRecords (FILE *pF, unsigned char uchName, short *pWave, long *pSamplesCntr ) {
	char szLine [0xFF];
	while( fgets( szLine, sizeof(szLine), pF) != NULL ) {
		// eof - omin, 7/8 znaczek , skip 01
		if ( strncmp( szLine+7, "01", 2 ) == 0 ) {
			continue;
		}
		appendHex ( szLine, uchName, pWave, pSamplesCntr );
    }
}


//------------------------------------------------------------------------------------


int main( int argc, char *argv[] ) {
	long samplePtr = 0;
	int bytesToSave = 0;

	FILE *pHex = NULL;

	printf("hex2wav, simple CA80 hex to audio converter, tasza (c) 2019\n");
	if ( processOptions( argc, argv, &h2wSetup ) != 0 ) {
		printf("usage:\n");
		printf("       hex2wav [-i input_file] -n NN [-e AAAA ] [-m MM] [-s SS] [-f FREQ] -o output_file\n");
		printf("       NN   - program name, 2 hex digits\n");
		printf("       AAAA - start address for *G command\n");
		printf("       SS   - synch bytes, 32 by default, at least 1\n");
		printf("       MM   - tape speed id 15-240b/s, 25-140b/s(default), 35-100b/s, use *7 command to setup CA80\n");
		printf("       FREQ - carrier frequency, 2800..3500(default)..4000 \n");
		return 1;
	}

	// podany plik wejsciowy
	if ( h2wSetup.bInFileName ) {
		pHex = fopen( h2wSetup.inFileName, "rt" );
		if( !pHex ) {
			printf( "Unable to open [%s]\n", h2wSetup.inFileName );
			return 1;
		}
		// oblicz rozmiar danych z pliku
		bytesToSave = calculateDataSize( pHex );
		bytesToSave += 32; // rozbiegówka przed blokami danych
	}

	if ( h2wSetup.bAddress ) {
		bytesToSave += 32 + 7; // rozbiegówka i rozmiar EOF-a
	}

	long wavSamplesBufferSize = (long)bytesToSave * 11 * ( WAVFILE_SAMPLES_PER_SECOND / h2wSetup.nMagSpeed );

	// raport ustawien
	if ( h2wSetup.bVerbose ) {
		printf( "input file name:      %s\n", h2wSetup.bInFileName ? h2wSetup.inFileName : "empty (!) EOF only mode" );
		printf( "program ID     :      %02X %s\n", h2wSetup.uchProgName, h2wSetup.bProgName ? "" : " (by default)" );
		if ( h2wSetup.bAddress ) {
			printf( "EOF address    :      %04X\n", h2wSetup.nAddress );
		}
		else{
			printf( "EOF address    :      none (no EOF at all)\n" );
		}
		printf( "tape bit rate  :      %d\n", h2wSetup.nMagSpeed );
		printf( "synch seq. len :      %d %s\n", h2wSetup.nSynchLen, h2wSetup.nSynchLen ? "" : " (by default)" );
		printf( "carrier freq.  :      %d %s\n", h2wSetup.nCarrierFreq, h2wSetup.bCarrierFreq ? "" : " (by default)" );
		printf( "samples per bit:      %d\n", h2wSetup.nSamplesPerBit );
		printf( "samples total  :      %ld\n", wavSamplesBufferSize );
		printf( "output file    :      %s\n", h2wSetup.outFileName );

	}

	// alokacja pamieci na probki ( dat+eof_
	short *waveform = (short*)malloc( wavSamplesBufferSize * 2 );

	if ( h2wSetup.bInFileName ) {
		// rozbiegówka-synchronizacja przed danymi
		appendSynch ( waveform, &samplePtr );
		// nagraj dane
		processHexRecords( pHex, h2wSetup.uchProgName, waveform, &samplePtr );
	}

	if ( h2wSetup.bAddress ) {
		// rozbiegówka-synchronizacja przed EOF
		appendSynch ( waveform, &samplePtr );
		// i EOF
		appendEOF( h2wSetup.uchProgName, h2wSetup.nAddress, waveform, &samplePtr );
	}

	FILE *f = wavfile_open( h2wSetup.outFileName );
	if( f == NULL ) {
		printf("Couldn't open [%s] for writing: %s\n", h2wSetup.outFileName, strerror(errno) );
		return 1;
	}

	wavfile_write( f, waveform, wavSamplesBufferSize );
	
	wavfile_close(f);

	free ( waveform );
	printf("Done.\n");
	return 0;
}

