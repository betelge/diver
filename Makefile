diver.nes : diver.o
	ld65 -o diver.nes -t nes diver.o

diver.o : diver.s
	ca65 diver.s

clean :
	rm diver.o diver.nes
