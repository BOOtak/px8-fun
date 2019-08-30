EMUL_DIR = ~/work/retro/px8/emul/

all: BASIC.ROM

BASIC.ROM: basic

basic: main.c test.lib
	zcc +cpm -lm -ltest -subtype=px8 -create-app -obasic main.c

clean:
	rm BASIC.ROM basic

test.o: test.asm
	z80asm test.asm

test.lib: test.o
	z80asm -xtest test.o

run: BASIC.ROM
	cp BASIC.ROM $(EMUL_DIR)
	wine $(EMUL_DIR)/px8.exe
