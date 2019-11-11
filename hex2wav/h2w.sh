rm *.wav

#hexFile=../example_PRINT.hex
hexFile=../print_LOAD.hex  

# na CA80 [7][2510][=] - domyślna szybkość transmisji, 140b/s, rekord 16 bajtów

# podstawowe, minimalne wywlołanie
./hex2wav -v -i ${hexFile} -n 55 -o ${hexFile}.55.prg.wav

# podstawowe wywlołanie z EOF-em na C000
./hex2wav -v -i ${hexFile} -n 66 -e C000 -o ${hexFile}.66.C000.eof.wav


# wywlołanie z EOF-em na C000, tylko 4 bajty synchronizacji
./hex2wav -v -i ${hexFile} -n 77 -e C000 -s 4 -o ${hexFile}.4.77.c000.eof.wav

# wywlołanie z EOF-em na C000, tylko 4 bajty synchronizacji, nośna 3kHz
./hex2wav -v -i ${hexFile} -n 88 -e C000 -s 4 -f 3000 -o ${hexFile}.3kHz.4.88.c000.eof.wav

# na CA80 [7][3510][=] - mniejsza szybkość transmisji, 100b/s, rekord 16 bajtów

# podstawowe wywlołanie z EOF-em na C000
./hex2wav -v -i ${hexFile} -n 99 -e C000 -m 35 -o ${hexFile}.slow.99.C000.eof.wav

# na CA80 [7][1510][=] - podwyższona szybkość transmisji, 240b/s, rekord 16 bajtów

# podstawowe wywlołanie z EOF-em na C000
./hex2wav -v -i ${hexFile} -n AA -e C000 -m 15 -o ${hexFile}.fast.AA.C000.eof.wav


