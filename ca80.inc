			; ciagle uzupelniam ...
USER8255	.eq		$E0
PA			.eq		0
PB			.eq		1
PC			.eq		2
CTRL		.eq		3
			;			
CYF0	    .eq	$FFF7
CYF1	    .eq	$FFF8
CYF2	    .eq	$FFF9
CYF3	    .eq	$FFFA
CYF4	    .eq	$FFFB
CYF5	    .eq	$FFFC
CYF6	    .eq	$FFFD
CYF7	    .eq	$FFFE
			
CLR		    .eq	$0010	; CLR - kasowanie wyswietlacza
LBYTE	    .eq	$0018	; LBYTE - wyswietlenie Aku w HEX
LADR        .eq $0020   ; LADR - wyswietlenie HL w HEX
CZAS	    .eq	$022D	; CZAS - pokazuje czas/date
COM		    .eq	$01AB	; COM - pokazuje znak 7-seg z rejestru C
PRINT	    .eq	$01D4	; PRINT - drukuje komunikat z (HL)
EXPR        .eq $0213   ; EXPR - pobranie ciagu liczb 16bit na stos
CSTS        .eq $FFC3   ; CSTS - test czy klawisz nacisniety
CI          .eq $FFC6   ; CI - pobranie znaku z klawiatury
CO          .eq $01E0   ; CO - wyswietlenie cyfry hex
            ;
EOM         .eq $FF            


