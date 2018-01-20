		.cr	Z80
		.tf	TLC549-termometr-3.bin, BIN
		.lf	TLC549-termometr-3.lst
		.sf TLC549-termometr-3.sym
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
		ld	A,0
		call showTemperature		
		call delayLong		
		call scrollDownSequence
		;		
		call showTime
		call delayLong		
		call scrollDownSequence
		;
		ld A,1
		call showTemperature
		call delayLong		
		call scrollDownSequence
		;		
		call showTime
		call delayLong		
		call scrollDownSequence
		;
			ld	A,0
			call showTemperature		
			call delayLong		
			call scrollDownAll
			;		
			call showTime
			call delayLong		
			call scrollDownAll
			;
			ld A,1
			call showTemperature
			call delayLong		
			call scrollDownAll
			;		
			call showTime
			call delayLong		
			call scrollDownAll
		;
		ld	A,0
		call showTemperature		
		call delayLong		
		call dotEater
		;		
		call showTime
		call delayLong		
		call dotEater
		;
		ld A,1
		call showTemperature
		call delayLong		
		call dotEater
		;		
		call showTime
		call delayLong		
		call dotEater
		;
			ld	A,0
			call showTemperature		
			call delayLong		
			call scrollLeft
			;		
			call showTime
			call delayLong		
			call scrollLeft
			;
			ld A,1
			call showTemperature
			call delayLong		
			call scrollLeft
			;		
			call showTime
			call delayLong		
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
		; dot eater
dotEater:
		push AF
		push BC
		push HL
		push DE
		; 7->x, 6->7, 5->6,...0->1, x->0
		ld B,8
		ld HL, CYF0
.scroll
		ld A, $80
		ld (HL),A
		inc HL
		call delay
		djnz .scroll
		ld B,8
		ld HL, CYF0
.scroll1
		ld A, $0
		ld (HL),A
		inc HL
		call delay
		djnz .scroll1
		pop DE
		pop HL
		pop BC
		pop AF
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
		; shows indoor/outdoor temperature, A=1 - out, A=0 - in
showTemperature:
		push	AF
		push 	BC
		push 	DE
		push	HL
		ld D,A			; save mode in/out

		call SYS_CLR	; clear disp.
		.db	$80			; pwys - full displ

		ld HL,messageIn	; load `deafult` IN message
		ld A,D	
		cp A,1			; is OUT mode?
		jp NZ,.stayIndoor
		; change message for outdoor
		ld HL,messageOut
.stayIndoor
		call SYS_PRINT
		.db	$80			; pwys
		ld  A,D			; set MUX channel
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
		pop DE
		pop BC
		pop AF
		ret

		;                                             |76543210|
messageIn
		.db $04,$54,$5e,$00,$00,$00,$63,$39,$FF		; |ind-nn`C|
messageOut
		.db $5C,$1C,$78,$00,$00,$00,$63,$39,$FF		; |out-nn`C|


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
		; 8255.PC3 - MUX.A0 line
		;
		; 8255.PC7 - DATA (i)		
		;
		; result in ACC
getADC:
		push BC
		push DE
		; << prep MUX control bit (bit no 3)
		rlca
		rlca
		rlca
		and A,$08
		ld D,A			; keep channel in D for easy OR
		;
		; dummy read sequence to skip old result 
		; and force conversion with brand new channel set		
		ld	A,%0000.0000		; /CS = L
		or A,D					; keep channel bit (D.3)
		out	(USER8255+PC),A		
		ld B, 8
.dummy:
		ld	A,%0000.0010		; clock _/~\_
		or A,D					; keep channel bit (D.3)
		out	(USER8255+PC),A		; /cs = L, CLK = H
		ld	A,%0000.0000	
		or A,D					; keep channel bit (D.3)
		out	(USER8255+PC),A		; /cs = L, CLK = L
		djnz .dummy				; do next tick
		; release /CS
		ld	A,%0000.0001		; /CS = H
		or A,D					; keep channel bit (D.3)
		out	(USER8255+PC),A		; /cs = H, CLK = L
		;
		halt					; 2ms
		; 
		; /CS = L
		ld	A,%0000.0000
		or A,D			; keep channel bit (D.3)
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
		or A,D					; keep channel bit (D.3)
		out	(USER8255+PC),A		; /cs = L, CLK = H
		ld	A,%0000.0000	
		or A,D					; keep channel bit (D.3)
		out	(USER8255+PC),A		; /cs = L, CLK = L
		; get next bit 
		djnz .continue		
		; /CS = H
		ld	A,%0000.0001	
		or A,D					; keep channel bit (D.3)
		out	(USER8255+PC),A		; /cs = H, CLK = L
		ld A,C					; result	
		pop	DE
		pop	BC
		ret
		;
		;
		;-------------------------------------------------------------
delay:
		push BC
		ld B,30
.del11	halt
		djnz .del11
		pop BC
		ret
		;
		;-------------------------------------------------------------
		;
delayLong:
		push BC
		ld B,25
.del11	call delay
		djnz .del11
		pop BC
		ret
		;
		;
		; :)
