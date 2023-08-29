PREFIX = ~/.local

tools = mklitentry.sh mklitdb.sh mkiidx.pl iidxlookup.pl litsearch.sh

.PHONY: install

install:
	cp $(tools) $(PREFIX)/bin/
	cp litsearch.desktop $(PREFIX)/share/applications/
