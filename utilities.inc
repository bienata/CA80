                ; 
ADDR_LO         .eq 0
ADDR_HI         .eq 1
                ; 
                ;--------------------------------------------
                ;  makra dla tabel
BEGINARRAY    	.MA   arrayName
]1:       
				.EM
				;
ENDARRAY    	.MA   arrayName,itemSize
]1End:       
]1Size			.eq	 ]1End-]1
]1Count			.eq	 ]1Size/]2
]1Last          .eq  ]1End-]2
				.EM
                ;
                ;--------------------------------------------
                ;
