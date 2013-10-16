CC=coffee
CFLAGS=--bare

all:
	${CC} ${CFLAGS} --output lib/ src/

clean:
	rm -rf lib

.PHONY: all clean
