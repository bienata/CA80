		.cr	Z80
		.tf	napis1.hex,INT
		.lf	napis1.lst
		.in ca80.inc		
        ;--------------------
		.sm     RAM
	    .or     $ffea		    
TIME:   .bs     2		
        ;--------------------
        .sm     CODE    		
		.or 	$C000		
napis:	
        ld		C, 2
		call    SYS_EXPR
		.db     $40
		pop     BC
		ld      B,C
konkom:
        pop     HL
        push    HL
et1:
        ld      A,(HL)
        cp      $FF
        jp      Z,konkom
        ld      C,(HL)
        inc     HL
        call    SYS_COM
        .db     $80
        call    delay
        jp      et1
        ;
delay:  
        ld      A,B
        ld      (TIME),A
de1:
        ld      A,(TIME)
        cp      0
        jp      NZ,de1
        ret
		; 
		;--------------------
		.no     $c100
message:
        .db     $76, $79, $38, $38, $3f, $00
        .db     $00, $00, $00, $ff		
        ;
        
