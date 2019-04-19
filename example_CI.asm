        .cr z80                     
        .tf example_CI.hex,int   
        .lf example_CI.lst
        .sf example_CI.sym       
        .in ca80.inc                
        .sm code                    ; 
        .or $c000                   ; U12/C000
        ;
CODE_DOT    .eq     $80             ; .
CODE_EQU    .eq     $48             ; =
		ld  SP,$ff66                ; 
.begin	
		call CLR                    
		.db $80                     ; na cały wyświetlacz
        call CI                     ; pobierz znaczek z kbd
        jr Z,.dotOrEqual             ; [.] lub [=]
        ;cała raszta, kod znaku jest w Aku :)
        call LBYTE
        .db $20
        call delay
        jr .begin
        ; obsluga .=
.dotOrEqual:        
        ld  C,CODE_EQU       ; może ustaw =
        jr  C,.dotOrEqualNext
        ld  C,CODE_DOT       ; a jednak ustaw .
.dotOrEqualNext        
        call COM             ; pokaż kod 7-seg
        .db $10
        call delay
        jr  .begin           ; i nazat
        ;
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
        
