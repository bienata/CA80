		.cr	Z80
		.tf	TLC549-termometr-2.bin, BIN
		.lf	TLC549-termometr-2.lst
		.sf TLC549-termometr-2.sym
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
		;
		call showTemperature		
		call delayLong		; time to observe readings
		call scrollDownSequence
		;		
			call showTime
			call delayLong		; time to observe readings
			call scrollDownSequence
			;
		call showTemperature
		call delayLong		; time to observe readings
		call scrollDownAll
		;		
			call showTime
			call delayLong		; time to observe readings
			call scrollDownAll
			;
		call showTemperature
		call delayLong		; time to observe readings
		call scrollLeft
		;		
			call showTime
			call delayLong		; time to observe readings
			call scrollLeft
			;
		jp 	.forever

		;---------------------------------------------------------------
		; specjal effects on display
		; all operates directly on 7-seg buffer
		;
scrollLeft:
		push AF
		push BC
		push HL
		push DE
		; 7->x, 6->7, 5->6,...0->1, x->0
		ld B,8
.scroll:		
		ld A,(CYF6)
		ld (CYF7),A
			ld A,(CYF5)
			ld (CYF6),A
		ld A,(CYF4)
		ld (CYF5),A
			ld A,(CYF3)
			ld (CYF4),A
		ld A,(CYF2)
		ld (CYF3),A
			ld A,(CYF1)
			ld (CYF2),A
		ld A,(CYF0)
		ld (CYF1),A
			ld A,0
			ld (CYF0),A
		call delay
		djnz .scroll
		pop DE
		pop HL
		pop BC
		pop AF
		ret

		;-------------------------------------------------------------

scrollDownSequence:
		push	AF
		push 	BC
		push	HL
		ld	HL,CYF0
		ld  B,8
.loop1:
		push BC
		ld B, 3
.loop11
		ld  A,(HL)
		call scrollDown
		ld  (HL),A
		call delay
		djnz .loop11
		pop BC
		inc HL
		djnz .loop1		
		pop HL
		pop BC
		pop AF
		ret 

		;-------------------------------------------------------------

		; special effects
scrollDownAll:
		push	AF
		push 	BC
		push	HL
		; 3 steps
		ld B,3
.loop1:
		push BC
		ld	HL,CYF0
		ld  B,8
.loop11:		
		ld  A,(HL)
		call scrollDown
		ld  (HL),A
		inc L
		djnz .loop11
		call delay
		pop BC
		djnz .loop1
		pop HL
		pop BC
		pop AF
		ret

		;-------------------------------------------------------------
				
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

		;---------------------------------------------------------------
		; shows current time
showTime:
		push	AF
		push 	BC
		push	HL
		ld HL,$FFED
		call SYS_CZAS
		pop HL
		pop BC
		pop AF
		ret

		;---------------------------------------------------------------
		; shows outdoor temperature
showTemperature:
		push	AF
		push 	BC
		push	HL
		call SYS_CLR	; clear disp.
		.db	$80			; pwys - full displ
		ld HL,message
		call SYS_PRINT
		.db	$80			; pwys
		call getADC		; A - raw data from TLC549
		; do something with sample		
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

		pop HL
		pop BC
		pop AF
		ret

message	.db $5C,$1C,$00,$00,$00,$00,$63,$39,$FF		; |ou__-nn`C|



		;---------- helpers, ADC, conv, delays -------------

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

		;-------------------------------------------------------------

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
		;-------------------------------------------------------------
delay:
		push BC
		ld B,50
.del11	halt
		djnz .del11
		pop BC
		ret
		;
		;-------------------------------------------------------------
		;
delayLong:
		push BC
		ld B,15
.del11	call delay
		djnz .del11
		pop BC
		ret
		;
		;
		; :)
