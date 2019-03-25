		.cr	Z80
		.tf	demo_ctc_3.hex,INT
		.lf	demo_ctc_3.lst
		.in ca80.inc		
		
CTC_CH0 .eq     $F8		
CTC_CH1 .eq     $F9     
        .sm     CODE    		
		.or 	$4000		
main:	
        ld      SP,$FF66
        ;inicjacja CTC
        ld		A, %01010101
        out     (CTC_CH0),A
        ld      A,100
        out     (CTC_CH0),A        
        ;
        ld      A,50
        ld      (DUTY),A
loop:        
        ld      A, %01010101
        out     (CTC_CH1),A
        ;zaladuj DUTY
        ld      A,(DUTY)
        out     (CTC_CH1),A        
        ; pokaz duty
        call    bin2bcd
        call    SYS_LBYTE               
        .db     $20
        ; czy klawisz?   
        call    SYS_CSTS
        call    C,processKey
        ; a jak nie to delay i czekaj dalej
        call    delay
        jp      loop        
        ;
        inc     (HL)        
        ; procedura zmienia DUTY zależnie czy kl [0] czy [1]
processKey:
        push    AF
        cp      0
        call    Z,decrementDuty
        cp      1
        call    Z,incrementDuty
        pop     AF
        ret
        ;
decrementDuty:
        push    AF
        ld      A,(DUTY)
        dec     A       ; duty--
        ld      (DUTY),A
        pop     AF
        ret
        ;
incrementDuty:
        push    AF
        ld      A,(DUTY)
        inc     A       ; duty++
        ld      (DUTY),A
        pop     AF
        ret
        ;
        ;----------------------------------------------------
        ; procedura konwersji BIN na BCD
        ; we: ACC - bin (0..99)
        ; wy: ACC - bcd
bin2bcd:
        push    bc
        ld  c, a
        ld  b, 8
        xor a
.loop:
        sla c
        adc a, a
        daa
        djnz .loop
        pop bc
        ret        
        ;----------------------------------------------------
        ; niewielki delay
delay:  push    bc
        ld      b,30
.delay1:
        halt        
        djnz    .delay1
        pop     bc
        ret        
        ;
        ;----------------------------------------------------        
        ;        
        .sm     RAM
        .no     $c000        
DUTY    .bs     1        
        ;
        
