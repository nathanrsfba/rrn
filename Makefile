# This is mainly to automatically regenerate the documentation, web site,
# and archives. There's no need to actually run 'make' before install.

TITLE="Regular Expression Rename"
NAME="rrn"
BASE=rrn
EXT=pl
EXE=$(BASE).$(EXT)
POD=$(EXE)
MANSECTION=1
MANPAGE=$(BASE).$(MANSECTION)

# PREFIX=/home/nathanr/foo
PREFIX=/usr/local
BINDIR=$(PREFIX)/bin
DOCPREFIX=$(PREFIX)/doc
DOCDIR=$(DOCPREFIX)/$(BASE)-$(VERSION)
MANPREFIX=$(PREFIX)/man
MANDIR=$(MANPREFIX)/man$(MANSECTION)

VERSION=$(shell perl $(EXE) --version | sed "s/$(BASE) v//")

foo:
	echo $(VERSION)
	echo $(PREFIX)
	echo $(DOCPREFIX)
	echo $(DOCDIR)
	echo $(MANPREFIX)
	echo $(MANDIR)

.DEFAULT_GOAL=all

DOCFILES=$(BASE).txt $(BASE).html README.md LICENSE
ARCFILES=$(EXE) $(MANPAGE) $(BASE).txt $(BASE).html README.md LICENSE

$(MANPAGE): $(POD)
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
	rm -f $(MANPAGE) *.html *.txt rrn.md *.zip *.gz *~

doc: $(MANPAGE) $(BASE).txt $(BASE).html
arc: $(BASE).zip $(BASE).tar.gz
web: $(BASE).md

install: doc
	install -D $(EXE) $(BINDIR)/$(BASE)
	install -m 0644 -D -t $(DOCDIR) $(DOCFILES)
	install -m 0644 -D -t $(MANDIR) $(MANPAGE)

uninstall:
	rm -rf $(BINDIR)/$(BASE) $(DOCDIR) $(MANDIR)/$(MANPAGE)

all: doc web

.PHONY: doc web arc clean all install uninstall
