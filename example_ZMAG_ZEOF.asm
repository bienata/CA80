        .cr z80                     
        .tf example_ZMAG_ZEOF.hex,int   
        .lf example_ZMAG_ZEOF.lst
        .sf example_ZMAG_ZEOF.sym       
        .in ca80.inc                
        .sm code                    ; 
        .or $c000                   ; U12/C000
        ;
		ld  SP,$ff66                ; 

        ld B,$AA                    ; nazwa zbioru
        ld HL,data                  ; adres początkowy
        ld DE,dataEnd-1             ; adres końcowy (ostatniego bajtu bloku)
		call ZMAG                    ; zapisz blok
		;
		ld B,$AA                  ; nazwa zbioru
		ld HL,$1234               ; adres wejścia (wartość PC użytkownika w zleceniu *G)
		call ZEOF                 ; zapisz EOF
        ;
        rst $30                     ; powrót do Monitora
        
		.no $d000
data:		
        .db $00,$11,$22,$33,$44,$55,$66,$77
        .db $88,$99,$AA,$BB,$CC,$DD,$EE,$FF
dataEnd:		        
		;
        
