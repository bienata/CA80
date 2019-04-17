        .cr z80                     
        .tf example_CSTS.hex,int   
        .lf example_CSTS.lst
        .sf example_CSTS.sym       
        .in ca80.inc                
        .sm code                    ; 
        .or $c000                   ; U12/C000
		ld  SP,$ff66                ; 
		;
.begin	
        ld HL, welcomeMessage       ; ------
		call PRINT                  ; pokaż 
		.db $80                     ; na cały wyświetlacz
        call CSTS                   ; sprawdz klawisze
        jr  NC,.begin               ; czekaj dalej
		; w A kod klawisza
		cp  $C
		call Z,whenCKeyPressed      ; dla C
		cp  $D
		call Z,whenDKeyPressed      ; D
        cp  $E
        call Z,whenEKeyPressed      ; E
        jr .begin                   ; powtarzaj
		;
whenCKeyPressed:
        ld HL, keyCmessage          ; właściwy komunikat
        jr whenPressedCommon        ; do cześci wspólnej
whenDKeyPressed:
        ld HL, keyDmessage
        jr whenPressedCommon
whenEKeyPressed:
        ld HL, keyEmessage        
whenPressedCommon:        
        call PRINT
        .db $80
.waitRelease:
        call CSTS
        jr C,.waitRelease
        ret
        ;		
welcomeMessage:
        .db     $80,$80,$80,$80,$80,$80,$80,$80, EOM        
keyCmessage:        
        .db     $01,$01,$01,$01,$01,$01,$01,$01, EOM        
keyDmessage:        
        .db     $40,$40,$40,$40,$40,$40,$40,$40, EOM        
keyEmessage:        
        .db     $08,$08,$08,$08,$08,$08,$08,$08, EOM        
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
        
