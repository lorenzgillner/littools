PREFIX = ~/.local/bin

tools = mklitentry mklitdb mkiidx

.PHONY: install

install:
	cp $(tools) $(PREFIX)/
