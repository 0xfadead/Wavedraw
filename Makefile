.PHONY: all clean debug

all : compile run

compile:
	$(MAKE) -C src

debug:
	$(MAKE) -C src debug
	./build/main


run:
	./build/main

clean:
	rm -f build/*
