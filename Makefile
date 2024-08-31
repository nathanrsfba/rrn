# This is mainly to automatically regenerate the documentation, web site,
# and archives. There's no need to actually run 'make' before install.

TITLE="Regular Expression Rename"
BASE=rrn
EXT=pl
EXE=$(BASE).$(EXT)
POD=$(EXE)
VERSION="`./$(EXE) --version`"

.DEFAULT_GOAL=all

ARCFILES=$(EXE) $(BASE).1 $(BASE).txt $(BASE).html README LICENSE

$(BASE).1: $(POD)
	pod2man -c $(TITLE) -r $(VERSION) $< $@

$(BASE).txt: $(POD)
	pod2text $< $@

$(BASE).html: $(POD)
	pod2html --infile=$< --outfile=$@ --title=$(TITLE)
	rm pod2htm*.tmp

index.html: index.mkd
	markdown $< > $@

$(BASE).zip: $(ARCFILES)
	rm -f $@
	zip $@ $^

$(BASE).tar.gz: $(ARCFILES)
	tar -c -v -f $@ $^

clean:
	rm -f *.1 *.txt *.html *.zip *.gz *~

doc: $(BASE).1 $(BASE).txt $(BASE).html
web: doc index.html README LICENSE
arc: $(BASE).zip $(BASE).tar.gz
all: web arc

.PHONY: doc web arc clean all
