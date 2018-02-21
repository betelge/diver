diver.nes : diver.o
	ld65 -o diver.nes -t nes diver.o

diver.o : diver.s palette.dat tiles.chr sprites.chr
	ca65 diver.s

clean :
	rm diver.o diver.nes
