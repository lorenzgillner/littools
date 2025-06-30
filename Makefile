PREFIX = ${HOME}/.local
VERSION = $(shell head -n 1 VERSION)

tools = mklitentry.sh mklitdb.sh mkiidx.pl iidxlookup.pl

.PHONY: install uninstall

install:
	cp $(tools) $(PREFIX)/bin/
	cp litsearch.svg $(PREFIX)/share/icons/
	cp icon.gif $(PREFIX)/share/icons/litsearch.gif
	cp litsearch.desktop $(PREFIX)/share/applications/
	cp litsearchrc $(HOME)/.config/
	sed 's/__VERSION__/$(VERSION)/' litsearch.sh > $(PREFIX)/bin/litsearch
	chmod +x $(PREFIX)/bin/litsearch

uninstall:
	rm $(addprefix $(PREFIX)/bin/, $(tools))
	rm $(PREFIX)/share/applications/litsearch.desktop
	rm $(PREFIX)/share/icons/litsearch.svg
	rm $(PREFIX)/share/icons/litsearch.gif
