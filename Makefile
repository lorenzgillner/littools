PREFIX = ~/.local/bin

tools = mklitdb

.PHONY: install

install:
	cp $(tools) $(PREFIX)/

