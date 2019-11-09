        .cr z80                     
        .tf example_OMAG.hex,int   
        .lf example_OMAG.lst
        .sf example_OMAG.sym       
        .in ca80.inc                
        .sm code                    ; 
        .or $8000                   
        ;
		ld  SP,$ff66                ; 

        ld B,$AA                    ; nazwa zbioru
		call OMAG                   ; odczytaj z taśmy
        ;
        rst $30                     ; powrót do Monitora        

        
