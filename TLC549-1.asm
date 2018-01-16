		.cr	Z80
		.tf	TLC549-1.bin,bin
		.lf	TLC549-1.lst
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

		call SYS_LBYTE		; print Accu		
		.db	$44			; pwys

		call delay

		jp	.forever
				
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
		ld B, 50
.delay	halt
		djnz .delay
		pop BC
		ret
		;
		; :)
