        .cr z80                     ; oczywiscie procesor Z80
        .tf example_draft.hex,int   ; kompilacja do intel hex
        .lf example_draft.lst		; poprosimy listing
        .sf example_draft.sym       ; i tablice symboli
                                    ; plik z deklaracjami 
        .in ca80.inc                ; procedur i stałych 
                                    ; systemowych                                            
        .sm     code                ; typowy start kodu uzytkownika
        .or     $c000               ; bank U12, adres $C000
        ;
		ld  SP,$ff66                ; ustawienie stosu 
        ;
        .co
        tu dajemy upust swej kreatywności
        .ec
        ;
        jp  $                       ; martwa pętla 
        rst $30                     ; lub powrót do Monitora
		;
        
