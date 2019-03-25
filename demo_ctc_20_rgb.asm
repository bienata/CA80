		.cr	Z80
		.tf	demo_ctc_20_rgb.hex,INT
		.lf	demo_ctc_20_rgb.lst
		.in ca80.inc		
		
CTC_CH0 .eq     $F8		
CTC_CH1 .eq     $F9
CTC_CH2 .eq     $FA     
        .sm     CODE    		
		.or 	$4000		
main:	
        ld      SP,$FF66
        ;inicjacja CTC
        ld		A, %01010101
        out     (CTC_CH0),A
        out     (CTC_CH1),A
        out     (CTC_CH2),A
        ld      A,50            ; na polowe gwizdka
        out     (CTC_CH0),A
        out     (CTC_CH1),A                
        out     (CTC_CH2),A                
        ;
        ld      (DUTY_R),A
        ld      (DUTY_G),A
        ld      (DUTY_B),A                
loop:        
        ld      A, %01010101
        out     (CTC_CH0),A
        ;zaladuj DUTY_R
        ld      A,(DUTY_R)
        out     (CTC_CH0),A        
        ; pokaz duty
        call    bin2bcd
        call    SYS_LBYTE               
        .db     $26         ; NNxxxxxx
        ;
        ld      A, %01010101
        out     (CTC_CH1),A
        ;zaladuj DUTY_G
        ld      A,(DUTY_G)
        out     (CTC_CH1),A        
        ; pokaz duty
        call    bin2bcd
        call    SYS_LBYTE               
        .db     $23         ; xxxNNxxx
        ;
        ld      A, %01010101
        out     (CTC_CH2),A
        ;zaladuj DUTY_G
        ld      A,(DUTY_B)
        out     (CTC_CH2),A        
        ; pokaz duty
        call    bin2bcd
        call    SYS_LBYTE               
        .db     $20         ; xxxxxxNN
        ;
        ; czy klawisz?   
        call    SYS_CSTS
        call    C,processKey
        ; a jak nie to delay i czekaj dalej
        call    delay
        ;
        jp      loop        
        ;
        ;--------------------------------
        ; [0] - RED--       [4] - RED++        
        ; [1] - GREEN--     [5] - GREEN++
        ; [2] - BLUE--      [6] - BLUE++                        
processKey:
        push    AF
        push    HL        
        ;
        ld      HL, DUTY_R
        cp      0
        call    Z,decrementDuty
        cp      4
        call    Z,incrementDuty
        ;
        ld      HL, DUTY_G
        cp      1
        call    Z,decrementDuty
        cp      5
        call    Z,incrementDuty
        ;
        ld      HL, DUTY_B
        cp      2
        call    Z,decrementDuty
        cp      6
        call    Z,incrementDuty
        ;
        pop     HL
        pop     AF
        ret
        ;
decrementDuty:
        push    AF
        push    HL
        ld      A,(HL)
        dec     A
        cp      0
        jp      Z,dontDec
        ld      (HL),A
dontDec:        
        pop     HL
        pop     AF
        ret
        ;
incrementDuty:
        push    AF
        push    HL        
        ld      A,(HL)
        inc     A
        cp      100
        jp      Z,dontInc
        ld      (HL),A        
dontInc:
        pop     HL
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
DUTY_R    .bs     1
DUTY_G    .bs     1
DUTY_B    .bs     1        
        ;
        
