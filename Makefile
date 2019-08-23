EMUL_DIR = ~/work/retro/px8/emul/

all: BASIC.ROM

BASIC.ROM: basic

basic: main.c
	zcc +cpm -subtype=px8 -create-app -obasic main.c

clean:
	rm BASIC.ROM basic

run:
	cp BASIC.ROM $(EMUL_DIR)
	wine $(EMUL_DIR)/px8.exe
