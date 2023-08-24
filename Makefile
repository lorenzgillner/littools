PREFIX = ~/.local/bin

tools = mklitentry mkiidx

.PHONY: install

install:
	cp $(tools) $(PREFIX)/

