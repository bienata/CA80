			; ciagle uzupelniam ...
USER8255	.eq		$E0
PA			.eq		0
PB			.eq		1
PC			.eq		2
CTRL		.eq		3
			;			


Z80SIO      .eq     $E8        
SIO_A_DAT   .eq     Z80SIO+0
SIO_B_DAT   .eq     Z80SIO+1
SIO_A_CMD   .eq     Z80SIO+2
SIO_B_CMD   .eq     Z80SIO+3

Z80CTC      .eq     $F8		
CTC_CH0     .eq     Z80CTC+0
CTC_CH1     .eq     Z80CTC+1
CTC_CH2     .eq     Z80CTC+2
CTC_CH3     .eq     Z80CTC+3


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
TI          .eq $0007   ; TI - pobranie znaku z echem
PARAM       .eq $01F4   ; PARAM - pobranie liczby 16-bit do HL z echem
HILO        .eq $023b   ; HILO - iterator, HL++, CY = !(DE >= HL)
ZMAG        .eq $0626   ; zapis bloku pamięci na magnetofon
ZEOF        .eq $067b   ; zapis rekordu EOF 
OMAG        .eq $071B   ; odczyt bloku danych lub EOF-a o zadanej nazwie pod adres zapisany w zbiorze
            ;
EOM         .eq $FF            


