        .cr z80                     
        .tf example_PRINT.hex,int   
        .lf example_PRINT.lst
        .sf example_PRINT.sym       
        .in ca80.inc                
ADDR_LO .eq 0
ADDR_HI .eq 1               
        .sm code                    ; 
        .or $c000                   ; U12/C000
		ld  SP,$ff66                ; 
		;
.begin	
        ld IX,messageTable          ; adres tabeli komunikatów
        ld B,messageTableLength     ; licznik komunikatów 
.loop        
		ld L,(IX+ADDR_LO)                 ; do HL adres wybranego via wskaznik 
        ld H,(IX+ADDR_HI)                 ; z IX komunikatu w kolejności LSB, MSB 
		call PRINT                  ; pokaż znaki
		.db $80                     ; na cały wyświetlacz
		call delay                  ; opóznienie
        inc IX                      ;
        inc IX                      ; IX += 2 kolejny wskaźnik       		
        djnz .loop                  ; while(--licznik)    		
		jp .begin
		;
messageTable:
        .dw message1 
        .dw message2
        .dw message3
messageTableLength  .eq $-messageTable/2
		;
message1:
        .db     $00,$00,$00, $74, $79, $38, $38, $5c, EOM        
message2:
        .db     $5c,$5c,$5c, $5c, $00, $00, $00, $00, EOM        
message3:
        .db     $00, $00, $00, $00, $5c,$5c,$5c, $5c, EOM        
        ;
delay:  push    BC
        push    AF
        ld      B,$FF
.delay        
        halt            ; 2ms
        djnz    .delay  ; while( --B )
        pop     AF
        pop     BC
        ret

		;
        
