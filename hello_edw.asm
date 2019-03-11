		.cr	Z80
		.tf	hello_edw.hex,INT
		.lf	hello_edw.lst
		.in 	ca80.inc	; deklaracje systemowe	
		.sm     CODE	    ; kod w RAM od C000
		.or 	$C000		
main:	ld		SP,$ff66    ; ustaw stos		
		ld      HL, msg1    ; adres komunikatu
		call    SYS_PRINT   ; pokaz
		.db     $80		    ; na caly wyswietlacz
.loop:  jp      .loop       ; while(1)
		; hello.edw
msg1:   .db     $74, $79, $38, $38
        .db     $dc, $79, $5e, $1c 
        .db     EOM


