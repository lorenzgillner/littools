PREFIX = ~/.local/bin

tools = mklitentry.sh mklitdb.sh mkiidx.pl bibo.pl

.PHONY: install

install:
	cp $(tools) $(PREFIX)/
