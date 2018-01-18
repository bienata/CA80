		.cr	Z80
		.tf	TLC549-termometr-1.bin, BIN
		.lf	TLC549-termometr-1.lst
		.sf TLC549-termometr-1.sym
		;
		.in 	ca80.inc		
		;
		.sm     CODE	
		.or 	$4000

		
main:	
		; stack first
		ld		SP,$ff66		
		; settings for 8255, PC03-out, PC47-in, reszta - coklowiek
		; /CS - PC0
		; CLK - PC1
		; DATA - PC7		
		ld	A,%10001000			
		out (USER8255+CTRL),A
		
.forever:
		call SYS_CLR	; clear disp.
		.db	$44			; pwys

		call getADC		; A - raw data from TLC549
		; do something with sample		

		;fake adc result, comment it!		
		;ld	A,33

		ld	C, $00	; empty place for MINUS
		sub	50		; - 50(0)mV
		jp NC,.whenPositive
		neg
		ld	C,$40			; MINUS code for leter
.whenPositive
		; print '-' or ' '
		push AF
		call SYS_COM
		.db	$14
		pop AF

		call bin2bcd
		call SYS_LBYTE		; print Accu		
		.db	$42				; pwys

		ld	C,$63
		call SYS_COM
		.db	$11
		ld	C,$39
		call SYS_COM
		.db	$10

;
;		ld	HL,celcDeg
;		call SYS_PRINT
;		.db $20			; two digits, from 1-st on right	
;
		call delay

		.co

		; specjal effects - 3 steps down
		ld	HL,CYF0
		ld  B,5
.eff1:
		ld  A,(HL)
		call scrollDown
		ld  (HL),A
		call delay
		ld  A,(HL)
		call scrollDown
		ld  (HL),A
		call delay
		ld  A,(HL)
		call scrollDown
		ld  (HL),A
		call delay
		inc HL
		djnz .eff1		

		.ec

		call delay	; time to observe readings

		ld B,3
.eff2:
		push BC
		ld	HL,CYF0
		ld  B,5
.eff22:		
		ld  A,(HL)
		call scrollDown
		ld  (HL),A
		inc L
		djnz .eff22		
		call delay
		pop BC
		djnz .eff2


		jp	.forever


		
		; A - byte to scroll, in/out
SEG_K	.eq	7
SEG_G	.eq	6
SEG_F	.eq	5
SEG_E	.eq	4
SEG_D	.eq	3
SEG_C	.eq	2
SEG_B	.eq	1
SEG_A	.eq	0

MOVE_SEGMENTS	.ma
			; ]1 --> ]2
			res ]2,D
			bit ]1,A
			jp Z,:leftFaded]2
			set ]2,D
:leftFaded]2
				.em

scrollDown:
		ld D,0
		>MOVE_SEGMENTS SEG_F,SEG_E
		>MOVE_SEGMENTS SEG_G,SEG_D
		>MOVE_SEGMENTS SEG_A,SEG_G
		>MOVE_SEGMENTS SEG_B,SEG_C
		ld A,D
		ret

		; A - bin, A - bcd, 0..99
bin2bcd:
		push	bc
		ld	c, a
		ld	b, 8
		xor	a
.loop:
		sla	c
		adc	a, a
		daa
		djnz .loop
		pop	bc
		ret

celcDeg:
		.db	$63,$39,$FF		; 'C

		; reads 8-bit value from TLC549 a/d converter
		; 8255.PC0 - /CS (o)
		; 8255.PC1 - CLK (o)
		; 8255.PC7 - DATA (i)		
		;
		; result in ACC
getADC:
		push BC
		; /CS = L
		ld	A,%0000.0000	
		out	(USER8255+PC),A		
		; reset vars
		ld	B, 8		    ; bits
		ld  C, 0			; keep A/D val.
.continue:
		; get bit from ADC
		in	A, (USER8255+PC)
		and	A,%1000.0000		
		or A,C					; A := A|C
		rlca 					; >> wziuuuu
		ld C,A					; put in C back		
		; clock _/~\_
		ld	A,%0000.0010	
		out	(USER8255+PC),A		; /cs = L, CLK = H
		ld	A,%0000.0000	
		out	(USER8255+PC),A		; /cs = L, CLK = L
		; get next bit 
		djnz .continue		
		; /CS = H
		ld	A,%0000.0001	
		out	(USER8255+PC),A		; /cs = H, CLK = L
		ld A,C					; result	
		pop	BC
		ret
		;
		;
		;
delay:
		push BC
		ld B, 100
.delay	halt
		djnz .delay
		pop BC
		ret
		;
		; :)
