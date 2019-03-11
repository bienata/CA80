		.cr	Z80
		.tf	endless.hex,INT
		.lf	endless.lst
        .in     ca80.inc    ; deklaracje systemowe  
        .sm     CODE        ; kod w RAM od C000
        .or     $C000       
forever:	
        jp      forever     
        
