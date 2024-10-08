# NAME

rrn - Regular expression ReName

# SYNOPSIS

**rrn** \[_options_\] _FROM_ \[_TO_\] \[_FILES_ | _@LISTFILE_\]

**rrn** \[_options_\] \[**-c**|**-f**\] _CMD_ \[_FILES_ | _@LISTFILE_\]

# DESCRIPTION

**rrn** is a program which will rename a set of files using
Perl-style regular expressions to specify how files should be
renamed.

The general syntax is as follows:

> **rrn** _FROM_ _TO_ \[_FILES_ | _@LISTFILE_\]

where _FROM_ is the part of a filename that should be changed, _TO_ is
what it should be changed to, and \[_FILES_\] is an optional list of files
to process.  If no files are specified, all files in the current
directory are processed.

Optionally, instead of (or in addition to) a list of _FILES_, you can also
specify a _@LISTFILE_, where _LISTFILE_ is a text file containing the list
of files to rename, one per line. Use the **-@** option to inhibit this 
behavior.

The simplest instance is renaming all instances of a word in a
filename to a different word.  For instance:

> `rrn .htm .html`

is a quick and dirty way to rename files with the extension _.htm_ to
files with an extension of _.html_.  In this case it is very similar
to the rename(1) command found in the util-linux package.

You can also use perl-style regular expressions to specify the text
that should be changed:

> `rrn '\s+' ' '`

will replace strings of multiple spaces in a filename with a single
space.  Another example might look like the following:

> `rrn '([a-z])([A-Z])' '$1 $2'`

which would insert a space in between any lowercase letter followed by
an upper case letter, thus changing a name like
_DigitalCameraPictures_ to _Digital Camera Pictures_.

If you're unfamiliar with Perl-style regexps, have a look at the
perlre(1), perlrequick(1), and/or perlretut(1) manpages that come with
Perl.

For those that are familiar with Perl, this script basically runs each
file name through an `s/_FROM_/_TO_/g` command, and renaming it to
whatever comes out.  Obviously, if the substitution results in the
same name as the original, the file will not be renamed.

# OPTIONS

- **-t**

    Test.  Only shows what changes would be made, without actually making
    them

- **-a**

    Ask.  Shows the changes that are about to be made, then ask whether to
    apply them

- **-v**

    Verbose.  Shows the names of files and what they're renamed to as it's
    renaming them.  By default **rrn** produces no output unless an error
    occurs

- **-g**

    No global.  Applies the substitution to only the first occurance of
    _FROM_.  This is like removing the /g from the end of the s// regexp
    in Perl.

- **-i**

    Case insensitive.  Letters will be matched against the _FROM_ pattern
    without regards to capitality.  Note that the matched portion of the
    name will still be replaced with the _TO_ text exactly as you
    specified it.  Therefore, `rrn -i a b` will change a
    capital 'A' to a lowercase 'b'. This is like adding an /i to the end
    of the s// operator

- **-e**

    Don't change the file's extension.  (Extension is defined as the
    portion of the filename including and following the final '.' character in
    the file, if there is one)  This removes the extension before substitution,
    and replaces it after substitution, so your _FROM_ pattern won't even
    match it.

- **-c** _CMD_

    Perform _CMD_, which is a Perl expression.  If this option is
    specified, the _FROM_ and _TO_ parameters must be left off.  The
    original file name will be found in the $\_ variable; your command
    should in some fashion modify that variable to what you want the new
    name to be.  `rrn -c 's/FROM/TO/g'` is equivalent to
    `rrn FROM TO`

    Note that if the **-e** option is used, the extension will be removed
    from the $\_ variable.  This way you can append something to the end of
    the name, and it will appear between the end of the filename and the
    start of the extension.

- **-f** _CMD_

    Similar to **-c**, but the result of the evaluated expression is used as the new
    name.  `rrn -f lc` is a quick way to convert a filename to all-lowercase
    characters.  (Or use `uc` for uppercase.) As with **-c**, the original filename
    is found in $\_, and whatever function you call should access that variable.
    Many Perl builtin functions will implicitely acecss $\_, so you can simply say,
    for instance, `lc` instead of `lc($_)`.

    Note that this doesn't have to be an actual function, it can be any
    expression that returns a value.  So you can say:

    >     `rrn -f '$foo++ . "_$_"'`

    to prepend a number before the filename.

- **-E**

    A distant cousin to **-f** and **-c**, if this is specified then the _FROM_
    parameter is a regex (as usual), but the _TO_ parameter is a Perl expression,
    not a regex. Thus, it is somewhat of a hybrid between the **-f**/**-c** options
    and the defualt behaviour.  Thus,

    >     `rrn -E '(^\d)' '$1 + 1'`

    will increment the number at the start of the filename.

    This option is equivalent to `rrn FROM '${\(TO)}'`.

- **-b** _INIT_

    Evaluates the expression _INIT_ before processing any files.  This is
    useful if you want to reference a variable in your command, but need
    it to be initialized to something first.  For instance:

    >     `rrn -b '$foo = 1' -f '$foo++ . "_$_"'`

    will prepend a number and an underscore to the filename.

- **-F**

    Force: Renames the file even if a file with the new name already exists.
    **Use with caution!**

- **-@**

    This will prevent **rrn** from treating files with names starting with an @
    symbol as list files.

# DIAGNOSTICS

- Skipped _FILE_: _NAME_ already exists

    A file wasn't renamed because the filename it was to be
    renamed to was already in use.

- Could not rename _FILE_: _ERROR_

    A file wasn't renamed because an OS error occured

# BUGS

Renaming a file to a name with different capitalization but otherwise the
same under Windows will complain about the file already existing.

Probably more, but I use this program all the time so the major ones should be
long since squashed.

# SEE ALSO

rename(1), perlre(1), perlrequick(1), perlretut(1), perlfunc(1), and
other documentation referenced in perl(1)

# AUTHOR

Nathan Roberts <nroberts@tardislabs.com>

# COPYRIGHT AND LICENSE

Copyright 2012 by Nathan Roberts <nroberts@tardislabs.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.
