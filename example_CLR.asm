        .cr z80                     
        .tf example_CLR.hex,int   
        .lf example_CLR.lst
        .sf example_CLR.sym       
        .in ca80.inc                
        .sm code                    ; 
        .or $c000                   ; U12/C000
		ld  SP,$ff66                ; 
		;
.begin	
        ld HL, message1             ; testowa treść
		call PRINT                  ; pokaż 
		.db $80                     ; na cały wyświetlacz
		call delay                  
		
		call CLR                    ; 7 6 5 4 3 2 1 0
		.db  $22                    ; _._._._.#.#._._.
        call delay                  
        
        call CLR 
        .db  $24                    ; _._.#.#._._._._.
        call delay                  
		
        call CLR 
        .db  $20                    ; _._._._._._.#.#.
        call delay                  

        call CLR 
        .db  $26                    ; #.#._._._._._._
        call delay                  

        jp .begin
		;
message1:
        .db     $5c,$5c,$5c, $5c, $63, $63, $63, $63, EOM        
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
        
