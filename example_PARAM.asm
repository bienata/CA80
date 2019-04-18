        .cr z80                     
        .tf example_PARAM.hex,int   
        .lf example_PARAM.lst
        .sf example_PARAM.sym       
        .in ca80.inc                
        .sm code                    ; 
        .or $c000                   ; U12/C000
        ;
ADDR_LO .eq 0
ADDR_HI .eq 1        
		ld  SP,$ff66                ; 
.begin	
        ld HL,addrPrompt            ; "Adr=____"
        call PRINT
        .db $80                     ; pokaż po lewo
        call PARAM
        .db $40
        jr NC,.begin                ; jak nie [=] to kontynuuj
        ; po [=] w HL mamy wprowadzony 16 bit adres
        ld A,H
        rlca                ; z wartości NNxx.xxxx zawijamy
        rlca                ; << i jest xxxx.xxNN    
        and $03             ; 
        ; tu A jest numerem komunikatu (nazwy banku) 0..3                
        add A               ; a := a*2, adresy są dwubajtowe
        ld  HL,bankNamesArray
        add L               ; wylicz adres nazwy banku
        ld L,A
        push HL             ; dziki transfer 16bit
        pop  IX             ; 
        ld  L,(IX+ADDR_LO)  ; pobierz ptr na komunikat   
        ld  H,(IX+ADDR_HI)  ; po kawałku
        call PRINT          ; i pokaż
        .db $80
        call delay
        jr  .begin           ; i nazat
        ;
bankNamesArray:
        .dw socketU9            ; "U9___rom"
        .dw socketU10           ; "U10__rAm"
        .dw socketU11           ; "U11__rAm"
        .dw socketU12           ; "U12__rAm"                        
        ;
socketU9:
        .db $3e,$6f,$00,$00,$00,$50,$5c,$54,EOM
socketU10:
        .db $3e,$06,$3f,$00,$00,$50,$77,$54,EOM
socketU11:
        .db $3e,$06,$06,$00,$00,$50,$77,$54,EOM
socketU12:
        .db $3e,$06,$5b,$00,$00,$50,$77,$54,EOM
addrPrompt:
        .db $77,$5e,$50,$48,$00,$00,$00,$00,EOM
        ;
delay:  push    BC
        push    AF
        ld      B,$FF
.delay        
        halt            ; 2ms
        halt            ; 2ms
        halt            ; 2ms                
        djnz    .delay  ; while( --B )
        pop     AF
        pop     BC
        ret

		;
        
