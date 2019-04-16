        .cr z80                     
        .tf example_LADR.hex,int   
        .lf example_LADR.lst
        .sf example_LADR.sym       
        .in ca80.inc                
        .sm code                ; 
        .or $c000               ; U12/C000
		ld  SP,$ff66                ; 
		;
.begin		
		ld B,bytesTableLength   ; B-licznik elementów tabeli
		ld HL,bytesTable        ; adres tabeli bajtow
.loop		
        call LADR                   ; pokaż adres elementu 
        .db $44                     ; po lewej stronie
		ld A,(HL)	                ; wez element tabeli
		call LBYTE                  ; pokaż wartość
		.db $20                     ; po prawej
		call delay                  ; opóznienie
		inc HL                      ; indeks++
		djnz .loop                  ; while (--licznik)
		jp .begin
        ;
bytesTable:
        .db $00,$11,$22,$33,$44,$55,$66,$77
        .db $88,$99,$aa,$bb,$cc,$dd,$ee,$ff        
bytesTableLength    .eq $-bytesTable
        ;
delay:  push    BC
        push    AF
        ld      B,$50
.delay        
        halt            ; 2ms
        djnz    .delay  ; while( --B )
        pop     AF
        pop     BC
        ret

		;
        
