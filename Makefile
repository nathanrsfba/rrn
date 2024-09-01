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

$(BASE).md: $(POD)
	perldoc -MPod::Perldoc::ToMarkdown -d $@ $<

$(BASE).zip: $(ARCFILES)
	rm -f $@
	zip $@ $^

$(BASE).tar.gz: $(ARCFILES)
	tar -c -v -f $@ $^

clean:
	rm -f *.1 *.txt *.html *.md *.zip *.gz *~

doc: $(BASE).1 $(BASE).txt $(BASE).html
arc: $(BASE).zip $(BASE).tar.gz
web: $(BASE).md

all: doc web

.PHONY: doc web arc clean all
