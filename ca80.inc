			;
USER8255	.eq		$E0
PA			.eq		0
PB			.eq		1
PC			.eq		2
CTRL		.eq		3
			;			
CYF0	.eq	$FFF7
CYF1	.eq	$FFF8
CYF2	.eq	$FFF9
CYF3	.eq	$FFFA
CYF4	.eq	$FFFB
CYF5	.eq	$FFFC
CYF6	.eq	$FFFD
CYF7	.eq	$FFFE

			
SYS_CLR		.eq		$0010		; CLR - clear display			
SYS_LBYTE	.eq		$0018		; LBYTE - display ACC as hex
SYS_CZAS	.eq		$022D		; CZAS - prints cuttent time/date HL=FFED/FFF1
SYS_COM		.eq		$01AB		; COM - prints 7seg from C
SYS_PRINT	.eq		$01D4		; PRINT - message ptr in HL

