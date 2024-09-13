rrn
===

Regular expression ReName - v1.0.0 (2012-06-19)
Copyright 2012 by Nathan Roberts <nroberts@tardislabs.com>

`rrn` is a program that renames files using regular expressions. It is
similar to programs such as `rename` and `prename` but with more 
functionality.

`rrn` is written in Perl, and should run under any system that has Perl
5.8 installed. Earlier versions may work but have not been tested.

Downloads
---------

`rrn` may be downloaded from the [releases page][1] on the Github repo.

[1]: https://github.com/nathanrsfba/rrn/tags

Installation
------------

`make install` should perform as expected. By default, it will install to
`/usr/local`, but this can be overridden with `make install PREFIX=/usr` or
suchlike.

By default, the binary is placed in $PREFIX/bin, with the `.pl` extension
stripped, a folder is created in $PREFIX/doc for the documentation, and a
manpage is placed in $PREFIX/man/man1. Take a look at the second variable block
in the makefile for customization options.

`make uninstall` will remove these files. Note that if a custom prefix (or
other variable) was specified at install, the same settings will need to be
given for uninstall.

Documentation
-------------

See the rrn(1) manpage, or the text or HTML versions of same in rrn.txt or
rrn.html, or the [Markdown version][2] on the Github repo.

[2]: https://github.com/nathanrsfba/rrn/blob/main/rrn.md

License
-------

rrn is licensed under the GPL. See the `LICENSE` file for details.

