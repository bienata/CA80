		.cr	Z80
		.tf	demo_com_1.hex,INT
		.lf	demo_com_1.lst
		.in ca80.inc		
        .sm     CODE    		
		.or 	$C000		
demo1:	
        ld		C, $73
		call    SYS_COM
		.db     $17
        jp      $
        ;
        
