PREFIX = ~/.local/bin

tools = mklitdb.sh mkiidx.pl

.PHONY: install

install:
	cp $(tools) $(PREFIX)/

