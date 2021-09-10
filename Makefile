all: gt2mini2 example.prg example.sid

clean:
	rm -f gt2mini2
	rm -f *.prg
	rm -f *.sid

gt2mini2: gt2mini2.c fileio.c
	gcc gt2mini2.c fileio.c -o gt2mini2

example.prg: gt2mini2 mw4title.sng prgexample.s player.s
	./gt2mini2 mw4title.sng musicmodule.s -s1000
	dasm musicmodule.s -omusicmodule.bin -p3 -f3
	dasm prgexample.s -oexample.prg -p3

example.sid: gt2mini2 mw4title.sng sidexample.s player.s
	./gt2mini2 mw4title.sng musicdata.s
	dasm sidexample.s -oexample.sid -p3 -f3