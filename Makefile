CC=gcc
CFLAGS=-std=c11 -Wall -Werror -Wextra -pedantic -g

sfile: sfile.c Makefile
	$(CC) $(CFLAGS) -o sfile sfile.c

clean:
	rm -f *.o
	rm -f file

test:
	./test.sh

.PHONY: clean
