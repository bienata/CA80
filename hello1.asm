		.cr	Z80
		.tf	hello1.hex,INT
		.lf	hello1.lst
		.in 	ca80.inc		
		.sm     CODE	
		.or 	$C000		
main:	
		ld		SP,$ff66		
		ld      HL, message
		call    SYS_PRINT
		.db     $50		
.loop:
        jp      .loop
		; 
message
        .db     $76, $79, $38, $38, $3f, $ff		

