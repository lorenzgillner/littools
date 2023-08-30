PREFIX = ${HOME}/.local

tools = mklitentry.sh mklitdb.sh mkiidx.pl iidxlookup.pl litsearch.sh

.PHONY: install uninstall

install:
	cp $(tools) $(PREFIX)/bin/
	cp litsearch.png $(PREFIX)/share/icons/
	cp litsearch.desktop $(PREFIX)/share/applications/

uninstall:
	rm $(addprefix $(PREFIX)/bin/, $(tools))
	rm $(PREFIX)/share/applications/litsearch.desktop
	rm $(PREFIX)/share/icons/litsearch.png