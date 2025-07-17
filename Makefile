PREFIX = ${HOME}/.local
VERSION = $(shell head -n 1 VERSION)

tools = mklitentry.sh mklitdb.sh mkiidx.pl iidxlookup.pl bookworm.sh

.PHONY: install uninstall

install:
	cp $(tools) $(PREFIX)/bin/
	cp litsearch.gif $(PREFIX)/share/icons/
	cp litsearch.desktop $(PREFIX)/share/applications/
	cp litsearchrc $(HOME)/.config/
	sed 's%##VERSION##%$(VERSION)%;s%##PREFIX##%$(PREFIX)%' litsearch.in > $(PREFIX)/bin/litsearch
	chmod +x $(PREFIX)/bin/litsearch

uninstall:
	rm $(addprefix $(PREFIX)/bin/, $(tools))
	rm $(PREFIX)/share/applications/litsearch.desktop
	rm $(PREFIX)/share/icons/litsearch.gif
