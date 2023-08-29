PREFIX = ~/.local/bin

tools = mklitentry.sh mklitdb.sh mkiidx.pl iidxlookup.pl litsearch.sh

.PHONY: install

install:
	cp $(tools) $(PREFIX)/
