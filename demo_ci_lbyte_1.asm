		.cr	Z80
		.tf	demo_ci_lbyte_1.hex,INT
		.lf	demo_ci_lbyte_1.lst
        .in     ca80.inc    ; deklaracje systemowe  
        .sm     CODE        ; kod w RAM od C000
        .or     $C000       
        ld      SP,$ff66    ; ustaw stos        
forever:	
        call    SYS_CI      ; sprawdz klawisz
		call    SYS_LBYTE   ; pokaz kod klawisza
		.db     $44
        jp      forever     ; i od nowa
        ;
        
