        .cr z80                     
        .tf example_CO.hex,int   
        .lf example_CO.lst
        .sf example_CO.sym       
        .in ca80.inc                
        .sm code                    ; 
        .or $c000                   ; U12/C000
		ld  SP,$ff66                ; 
		;
.begin	
        ld A,$10
        ld (.displayPos),A                 ; inicjacja PWYS
.loopPositions        
        ld B,$10                     ; zacznij od F
.loopDigits        
        call CLR                    ; skasuj wyswietlacz
        .db $80
        ld A,B                      ; do wyświetlania 
        dec A                       ; wartość -1 (zakres F..0)  
        ld C,A
        call CO                     ; nie mylić z "COM" :-)
.displayPos .bs  1                ; skrajna prawa
        call delay                  
        djnz .loopDigits            ; while (--B)
        ; zmodyfikuj pwys
        ld A,(.displayPos)       ; weź aktualną pozycję
        inc A                   ; kolejna
        cp  $18                 ; czy skrajny lewy ?
        jp  Z,.begin            ; tak, zacznij od nowa
        ld (.displayPos),A       ; zapisz nową
        jp .loopPositions       ; rób cyferki na nowej pozycji 
		;
delay:  push    BC
        push    AF
        ld      B,$50
.delay        
        halt            ; 2ms
        djnz    .delay  ; while( --B )
        pop     AF
        pop     BC
        ret

		;
        
