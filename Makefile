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

PREFIX=/usr/local
BINDIR=$(PREFIX)/bin
DOCPREFIX=$(PREFIX)/doc
DOCDIR=$(DOCPREFIX)/$(BASE)-$(VERSION)
MANPREFIX=$(PREFIX)/man
MANDIR=$(MANPREFIX)/man$(MANSECTION)

VERSION=$(shell perl $(EXE) --version | sed "s/$(BASE) v//")
DATE=$(shell perl $(EXE) | grep -m 1 $(BASE) | sed 's/.*(\(.*\).*)/\1/')

OUTPUT=$(CURDIR)

DISTGARBAGE=*.zip *.gz *.t?z *~ .*~ *.bak *.swp
GARBAGE=*.html *.txt rrn.md $(DISTGARBAGE)

.DEFAULT_GOAL=all

DOCFILES=$(BASE).txt $(BASE).html README.md LICENSE
ARCFILES=$(EXE) $(MANPAGE) $(BASE).txt $(BASE).html README.md LICENSE

$(MANPAGE): $(POD)
	pod2man -c $(TITLE) -r "$(NAME) v$(VERSION)" -d $(DATE) $< $@

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

# Remove garbage, including anything make regenerates
clean:
	rm -f $(GARBAGE)
	cd slackbuild; rm -f $(GARBAGE)

# Remove garbage, leaving anything shipped in the repo
distclean:
	rm -f $(DISTGARBAGE)
	cd slackbuild; rm -f $(DISTGARBAGE)

doc: $(MANPAGE) $(BASE).txt $(BASE).html
arc: $(BASE).zip $(BASE).tar.gz
web: $(BASE).md

install: doc
	install -D $(EXE) $(BINDIR)/$(BASE)
	install -m 0644 -D -t $(DOCDIR) $(DOCFILES)
	install -m 0644 -D -t $(MANDIR) $(MANPAGE)

uninstall:
	rm -rf $(BINDIR)/$(BASE) $(DOCDIR) $(MANDIR)/$(MANPAGE)

slackbuild/v$(VERSION).tar.gz: Makefile $(ARCFILES)
	tar cvaf $@ --transform=s/^/$(BASE)-$(VERSION)\\// Makefile $(ARCFILES)

slackpkg: slackbuild/v$(VERSION).tar.gz
	VERSION=$(VERSION) OUTPUT=$(realpath $(OUTPUT)) sh slackbuild/rrn.SlackBuild 

all: doc web

.PHONY: doc web arc clean distclean all install uninstall slackpkg
