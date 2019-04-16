        .cr z80                     
        .tf example_COM.hex,int   
        .lf example_COM.lst
        .sf example_COM.sym       
        .in ca80.inc                
        .sm code                ; 
        .or $c000               ; U12/C000
		ld  SP,$ff66                ; 
		;
.begin		
		ld B,semiTableEnd-semiTable ; B-licznik elementów tabeli
		ld HL,semiTable             ; adres tabeli znaczków
.loop		
		ld C,(HL)	                ; wez element tabeli
		call COM                    ; pokaż znaczek
		.db $17                     ; pozycja lewa skrajna (7)
        call COM                    ; pokaż znaczek
        .db $15                     ; pozycja lewa (5)
		call delay                  ; opóznienie
		inc HL                      ; indeks++
		djnz .loop                  ; while (--licznik)
		jp .begin
        ;
semiTable:
        .db $01,$02,$04,$08,$10,$20,$40,$80
semiTableEnd:        
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
        
