        .cr z80                     
        .tf example_HILO.hex,int   
        .lf example_HILO.lst
        .sf example_HILO.sym       
        .in ca80.inc
        .in utilities.inc           ; wszelkie przydasie                    
        .sm code                    ; 
        .or $c000                   ; U12/C000
        ;
		ld  SP,$ff66                ; 
.begin	
        ld C,3                      ; beginAddr, endAddr, destAddr
        call EXPR
        .db $40
        ; na stosie w kolejnosci dest,end,begin
        pop IX          ; dest
        pop DE          ; end 
        pop HL          ; begin 
.memCopy:
        ld  A,(HL)      
        call    showProgress
        ld  (IX),A
        inc IX          ; dest++
        call    delay                
        call    HILO    ; begin++        
        jp NC,.memCopy
        ;
        call    CLR
        .db     $80
        ;        
        jp  $
        ; pokaz ADDR__NN podczas kopiowania
showProgress:
        push    AF
        push    HL
        push    DE
        call    LBYTE 
        .db     $20   
        call    LADR  
        .db     $44                 
        pop     DE
        pop     HL
        pop     AF
        ret     
        ;
delay:  push    BC
        push    AF
        ld      B,$40
.delay        
        halt            ; 2ms                
        djnz    .delay  ; while( --B )
        pop     AF
        pop     BC
        ret
        ;
        
