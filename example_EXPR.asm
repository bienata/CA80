        .cr z80                     
        .tf example_EXPR.hex,int   
        .lf example_EXPR.lst
        .sf example_EXPR.sym       
        .in ca80.inc
        .in utilities.inc           ; wszelkie przydasie                    
        .sm code                    ; 
        .or $c000                   ; U12/C000
        ;
		ld  SP,$ff66                ; 
.begin	
        ld HL,paramPrompt            ; "PAr=____"
        call PRINT
        .db $80                     ; pokaż po lewo
        ld C,parametersArrayCount   ; tyle parametrów ile elementów tabelki
        call EXPR
        .db $40
        ; pozdejmuj ze stosu i poukładaj w tabeli parametrów
        ; na wierzchołku stosu jest OSTATNIO wprowadzony parametr
        ld B,parametersArrayCount
        ld IX,parametersArrayLast
.saveParams:
        pop HL              
        ld (IX+ADDR_LO),L
        ld (IX+ADDR_HI),H
        dec IX
        dec IX          ; IX := IX-2
        djnz .saveParams
        ;
        ;prezentacja zgromadzonych parametrów
.showLoop:        
        ld B,parametersArrayCount        
.showParams:
        ld      C,$73       ; "P"
        call    COM
        .db     $17         ; po lewo        
        ld      A,parametersArrayCount
        sub     B           ; numer parametru (rosnąco)
        push    AF          ; zachowaj A
        inc     A           ; A+1, aby pokazywać od 1, jak dla ludzi
        call    LBYTE       ; dopisz za "P"
        .db     $25         ; też po lewo
        ; ustal adres parametru na podstawie numeru
        pop     AF          ; mamy stare A z numerem parametru
        ld HL,parametersArray ; i adres początku tabeli               
        add     A           ; A*2
        add     A,L         
        ld      L,A         ; w HL adres parametru
        push    HL          ; dziki transfer
        pop     IX
        LD      L,(IX+ADDR_LO)  ; pozyskaj z pamięci
        LD      H,(IX+ADDR_HI)
        call    LADR            ; pokaż po prawo
        .db     $40                 
        call    delay
        djnz    .showParams         ; while (--B)
        ;
        jp      .showLoop           
        ;        
paramPrompt:
        .db $73,$77,$50,$48,$00,$00,$00,$00,EOM
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
        ; zmienne
        .sm RAM 
        .or $8000
        >BEGINARRAY parametersArray
        .bs 2
        .bs 2
        .bs 2
        .bs 2
        >ENDARRAY parametersArray,2
        ;
		;
        
