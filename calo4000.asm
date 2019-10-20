; 
; calo - simple z80-sio oriented intel hex loader
;        location:  NVRAM @ 4000h
;        resources: channel B @ 19200,8,N,1 
; tasza, 2019
;   
            .cr	Z80
		    .tf	calo4000.hex,INT
		    .lf	calo4000.lst
		    .sf	calo4000.sym

            .in ca80.inc            ; deklaracje systemowe  


            .sm RAM
            .or $FF66
rx_buffer:      .bs 80              ; rx buffer
rx_buffer_len:  .eq  $-rx_buffer    ; size         
user_stack:     .eq $+2   



            .sm CODE                ; kod w RAM od 4000
            .or $4000  
main:
            ld  SP,user_stack
            ; setup SIO, channel A
            call sioInit
            ; napisz 'cALo'
            ld HL,caloMessage
            call PRINT
            .db $44            
main_loadloop:
            call loadHex
            jr C,main_loaderError
            call checkCRC
            jr NZ,main_loaderError
            ; data czy EOF
            call isEOF
            jr Z,main_loaderDone
            call procHex
            jr C,main_loaderError
            call sendAck
            jr main_loadloop
main_loaderDone:
            call sendDone
            jp $0000                       
main_loaderError:
            call sendErr
            ; beep?
            jp $0000           

            ; cALo 
caloMessage: 
            .db $58, $77, $38, $5c, $FF 
            
checkCRC:
            ld HL,rx_buffer        
            ld C,$00
checkCRC_loop:            
            call ascii2byte
            add C
            ld C,A
            inc HL
            inc HL              ; natepna para
            ld A,(HL)
            cp $0
            jr NZ,checkCRC_loop
            ld A,C
            cp $0               ; czy suma bajtów i CRC == 0?
            ret                 ; Z=1 -> OK,  Z=0 - lipa
                            
procHex:    ; process hex - wypakowanie danych
            ld HL,rx_buffer
            ; +0, +1 - dlugosc
            call ascii2byte
            ld B,A              ; len w B !!!!
            ld HL,rx_buffer+2  ; ustaw sie na adres                        
            call ascii2byte            
            cp calo_app_end>>8+1    ; adresy <= 42 - err
            jp C,procHex_err     ; `access violation`, exit
            ld D,A              ; HI address (DE)
            inc HL
            inc HL            
            call ascii2byte
            ld E,A              ; LO adress (DE)
            ; pokaż
            push DE
            pop HL
            call LADR
            .db $40
             ; przeskocz typ rekordu, ustaw na dane
            ld HL,rx_buffer+8  ; ustaw sie na adres                         
            ; bierz kolejne dane
procHex_next:
            call ascii2byte     ; 
            ld (DE),A           ; 
            inc DE              ; pMem++
            inc HL              
            inc HL                          
            djnz procHex_next            
procHex_done:            
            scf
            ccf
            ret         ; OK -> CY=0
procHex_err:
            scf
            ret         ; lipa, CY=1
            
ascii2byte:     ; bin z dwóch kolejnych ascii wskazanych via HL
            push HL
            push BC
            ld A,(HL)
            call char2bin
            rrca                ; << 4
            rrca
            rrca
            rrca            
            ld B,A              
            inc HL
            ld A,(HL)
            call char2bin
            or B
            pop BC
            pop HL
            ;mamy bajta z dwóch ascii
            ret
      
      
      
            
isEOF:
            ld HL,rx_buffer+7
            ld A,(HL)
            cp '1'
            ret     ;   Z==1 -> EOF
            
         
         
         
         
loadHex:
            ld HL,rx_buffer
            ld B,$00          ; licznik znaków
loadHex_wait:
            call getChar
            cp ':'
            jr NZ,loadHex_wait
loadHex_load:            
            call getChar
            cp 13          ; CR precz
            jp Z,loadHex_load
            cp 10          ; LF - finito
            jr Z,loadHex_done
            ld (HL),A       ; do bufora
            inc HL          ; ptr++
            xor A
            ld (HL),A       ; zero na koniec
            inc B           ; i++
            ld A,rx_buffer_len
            sub B
            jr C,loadHex_buffOver                        
            jr loadHex_load         ; i dalej
loadHex_done:            
            scf
            ccf
            ret         ; OK -> CY=0
loadHex_buffOver:
            scf
            ret         ; lipa, CY=1

            
            
            
            ; case-aware konwersja ASCII '0'..'f'/'F' na 0..F
            ; 30...39 0-9 
            ; 41...46 A-F    
            ; 61...66 a-f
char2bin:
            ; czy > 60
            cp $60
            jr NC,char2bin_lo
            cp $40
            jr NC,char2bin_up            
            ; digit
            sub '0'
            ret
char2bin_lo:
            sub $20
char2bin_up:
            sub $37
            ret
            
            
            
            
sendAck:
            ld A,'.'
            call putChar
            jr send_LF
sendDone:
            ld A,'-'
            call putChar
            jr send_LF
sendErr:
            ld A,'!'
            call putChar
send_LF:            
            ld A,10
            call putChar
            ret

            
sioInit:
            ld A,0
            out (SIO_B_CMD),A           ; WR0

            ld A,1
            out (SIO_B_CMD),A           ; ustaw WR1 
            ld A,0
            out (SIO_B_CMD),A           ; WR1 := 0
        
            ld  A,4
            out (SIO_B_CMD),A           ; ustaw WR4        
            ld A,$04+$40          ; weź baudy 9600 (bity B7,D6) nałóż 1 stop, no parity
                                        ; 0x80 - 9600, 0x40 - 19200
            out (SIO_B_CMD),A           ;
        
            ld  A,3
            out (SIO_B_CMD),A           ; ustaw na WR3
            ld  A,$C1         ; 8 bit, Rx enable
            out (SIO_B_CMD),A
        
            ld  A,5
            out (SIO_B_CMD),A           ; ustaw WR5
            ld  A,$EA         ; 8bit, Tx enable
            out (SIO_B_CMD),A        
            ret
       
       
       
putChar:
            push AF     ; zabezpiecz znaczek
putChar_wait:
            ld A,0
            out (SIO_B_CMD),A            ; wybierz RR0 wskazanego kanału
            in  A,(SIO_B_CMD)           ; daj RR0
            bit 2,A             ; czy Transfer Buffer Empty? (D2==1)
            jr Z,putChar   ; to czekaj dalej
            pop AF          
            out (SIO_B_DAT),A           ; i wyślij
            ret             
                        
getChar:
            ld A,0
            out (SIO_B_CMD),A   ; RR0
            in  A,(SIO_B_CMD)   ; status
            and A,1    ; sprawdź D0 Receive Character Available
            jr Z,getChar
            in  A,(SIO_B_DAT)   ; weź znaczek z RxD
            ret 
calo_app_end:   
            ;
            ; qniec :)

        
