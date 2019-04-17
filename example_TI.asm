        .cr z80                     
        .tf example_TI.hex,int   
        .lf example_TI.lst
        .sf example_TI.sym       
        .in ca80.inc                
        .sm code                    ; 
        .or $c000                   ; U12/C000
        ;
CODE_DOT    .eq     $80             ; .
CODE_EQU    .eq     $48             ; =
		ld  SP,$ff66                ; 
.begin	
        call TI                     ; pobierz znaczek z kbd
        .db $10                     ; echo na prawej pozycji
        jr Z,.dotOrEual             ; [.] lub [=]
        jr .begin
        ; obsluga .=
.dotOrEual:        
        ld  C,CODE_EQU       ; może ustaw =
        jr  C,.dotOrEualNext
        ld  C,CODE_DOT       ; a jednak ustaw .
.dotOrEualNext        
        call CLR
        .db $10
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
        
