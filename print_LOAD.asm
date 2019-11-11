        .cr z80                     
        .tf print_LOAD.hex,int   
        .lf print_LOAD.lst
        .sf print_LOAD.sym       
        .in ca80.inc                
        .sm code                    ; 
        .or $c000                   ; U12/C000
		ld  SP,$ff66                ; 
		ld	HL,msgLoad
		call PRINT                  ; pokaż znaki
		.db $80                     ; na cały wyświetlacz
		jr $
		;
msgLoad:
        .db     $38,$5c,$77,$5e,$40,$23,$1c,$40,EOM        
		;
        
