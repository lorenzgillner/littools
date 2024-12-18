PREFIX = ${HOME}/.local

tools = mklitentry.sh mklitdb.sh mkiidx.pl iidxlookup.pl litsearch.sh

.PHONY: install uninstall

install:
	cp $(tools) $(PREFIX)/bin/
	cp litsearch.png $(PREFIX)/share/icons/
	cp icon.gif /var/lib/litsearch/
	cp litsearch.desktop $(PREFIX)/share/applications/
	mkdir -p $(HOME)/.config/litsearch

uninstall:
	rm $(addprefix $(PREFIX)/bin/, $(tools))
	rm $(PREFIX)/share/applications/litsearch.desktop
	rm $(PREFIX)/share/icons/litsearch.png
	rm /var/lib/litsearch/icon.gif
