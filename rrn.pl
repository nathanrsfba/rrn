#!/usr/bin/perl

# rrn: Regular expression ReName
# Copyright (C) 2012  Nathan Roberts
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

use strict;
use Getopt::Std;

our $VERSION = "1.0.0";
my $DATE = "2012-06-19";

# Get command-line options and transfer them to meaningful variable names

my %opts;

getopts( '@tavgc:f:Eeib:Fh', \%opts );

my( $nolist, $test, $ask, $verbose, $noglobal, $cmd, $func, $expr, $casein,
    $keepext, $begin, $force, $help ) = @opts{ qw( @ t a v g c f E i e b F h )};

# Print help message if requested

if( $help )
{
    HELP_MESSAGE();
    exit;
}

# Grab the 'from' and 'to' portions (regex parameters) if appropriate

my( $from, $to );

if( !$cmd && !$func )
{
    $from = shift;
    $to = shift;
}

# die "Missing parameter\n" if( $from eq '' && $cmd eq '' && $func eq '' );
HELP_MESSAGE() if( $from eq '' && $cmd eq '' && $func eq '' );

# Some debugging output that really isn't necessary anymore
#
# if( $cmd )
# {
#     print "Command: $cmd\n";
# }
# elsif( $func )
# {
#     print "Function: $func\n";
# }
# else
# {
#     print "From: $from\nTo: $to\n";
# }

# Get the list of files to rename

my @dir = @ARGV;

if( @dir && $^O eq 'MSWin32' )
{
    # We have to glob our own wildcards under Win32
    @dir = <@dir>;
}

# Expand @lists

if( !$nolist )
{
    my @temp = @dir;
    @dir = ();

    foreach my $file (@temp)
    {
	if( $file =~ /@(.+)/ )
	{
	    open my $handle, $1 
		or die "Erorr reading $1: $@\n";
	    my @foo = <$handle>;
	    chomp @foo;
	    push @dir, @foo;
	    close $handle;
	}
	else
	{
	    push @dir, $file;
	}
    }
}

if( !@dir )
{
    opendir( DIR, "./" );
    @dir = sort readdir( DIR );
}

# Figure out regex flags

my $opts;

if( !$noglobal )
{
    $opts .= 'g';
}

if( $casein )
{
    $opts .= 'i';
}

# Execute the init statement, if given

if( $begin )
{
    no strict;
    eval $begin;
    use strict;
    die $@ if( $@ );
}

# Figure out new names

my @renames;

foreach (@dir)
{
    next if( /^\.{1,2}$/ ); # Skip . and .. directories

    my $old = $_;

    # Save the file extension (if requested) and the pathname

    my $ext;
    if( $keepext )
    {
	($_, $ext) = /(.*)(\..*)/ or $_ = $old;
    }
    # FIXME: We ought to be using dirname and basename for this
    my $path;
    ($path, $_) = m!(.*/)?([^/]+)!;

    # Determine the new name, depending on which mode we're in
    # Note that 'strict' is temporarily turned off so that the user
    # can use variables without having to declare them first

    if( $cmd )
    {
	no strict;
	eval $cmd;
	use strict;
	die $@ if( $@ );
    }
    elsif( $func )
    {
	no strict;
	$_ = eval $func;
	use strict;
	die $@ if( $@ );
    }
    else
    {
	# Escape forward slashes, just in case, even though they'll
	# probably never be used, since they're not valid in a filename

	$from =~ s!/!\\/!g;
	$to =~ s!/!\\/!g;

	no strict;
	if( $expr )
	{
	    eval "s/$from/\${\\($to)}/$opts";
	}
	else
	{
	    eval "s/$from/$to/$opts";
	}
	use strict;
	die $@ if( $@ );
    }

    # Restore the extension and path

    $_ .= $ext if( $keepext );
    $_ = "$path$_";

    # No-op if name hasn't changed

    next if( $old eq $_ || $_ eq '' );

    # Store the new name

    push @renames, [$old, $_];
}

# Do test, if necessary
if( $test || $ask )
{
    for my $rename (@renames)
    {
	my( $old, $new ) = @$rename;

	print "$old --> $new\n";
    }
}

exit if( $test );

if( $ask )
{
    print "Apply? [y/N] ";
    my $response = <STDIN>;
    if( $response !~ /^y/i )
    {
	print "Aborted.\n";
	exit;
    }
}

# Do the acual rename

for my $rename (@renames)
{
    my( $old, $new ) = @$rename;

    if( -e $new && !$force )
    {
	warn "Skipped $old: $new already exists\n";
	next;
    }
    elsif( !rename( $old, $new ))
    {
	warn "Could not rename $old: $!\n";
	next;
    }
    print "$old --> $_\n" if( $verbose );
}

sub HELP_MESSAGE
{
    print "
rrn: Regular expression ReName - v$VERSION ($DATE)

Syntax:
  rrn [-tavgieFE] [-b INIT] FROM TO [FILES | \@LISTFILE]
  rrn [-taveF] [-b INIT] [-c | -f] CMD [FILES | \@LISTFILE]

  -t     Test: Only show what changes would have been made
  -a     Ask: Show changes (like -t) then confirm
  -v     Verbose: Show the files as they are being renamed
  -g     No global: Apply substitution to only the first occurance
  -i     Ignore case: Pattern matching will be case-insensitive
  -e     Don't change file extension
  -b     Execute INIT expression before any substitutions
  -F     Force: Rename even if new name already exists.

  -c     Perform a command on filenames instead of substitution
  -f     Perform a function on filenames instead of substitution
  -E     TO is a perl expression instead of a regex parameter

  -@     Don't process \@LISTFILE arguments

";
exit;
}

sub VERSION_MESSAGE
{
    print "rrn v$VERSION\n";
    exit;
}

__END__

=head1 NAME

rrn - Regular expression ReName

=head1 SYNOPSIS

B<rrn> [I<options>] I<FROM> [I<TO>] [I<FILES> | I<@LISTFILE>]

B<rrn> [I<options>] [B<-c>|B<-f>] I<CMD> [I<FILES> | I<@LISTFILE>]

=head1 DESCRIPTION

B<rrn> is a program which will rename a set of files using
Perl-style regular expressions to specify how files should be
renamed.

The general syntax is as follows:

=over

B<rrn> I<FROM> I<TO> [I<FILES> | I<@LISTFILE>]

=back

where I<FROM> is the part of a filename that should be changed, I<TO> is
what it should be changed to, and [I<FILES>] is an optional list of files
to process.  If no files are specified, all files in the current
directory are processed.

Optionally, instead of (or in addition to) a list of I<FILES>, you can also
specify a I<@LISTFILE>, where I<LISTFILE> is a text file containing the list
of files to rename, one per line. Use the B<-@> option to inhibit this 
behavior.

The simplest instance is renaming all instances of a word in a
filename to a different word.  For instance:

=over

C<rrn .htm .html>

=back

is a quick and dirty way to rename files with the extension I<.htm> to
files with an extension of I<.html>.  In this case it is very similar
to the rename(1) command found in the util-linux package.

You can also use perl-style regular expressions to specify the text
that should be changed:

=over

C<rrn '\s+' ' '>

=back

will replace strings of multiple spaces in a filename with a single
space.  Another example might look like the following:

=over

C<rrn '([a-z])([A-Z])' '$1 $2'>

=back

which would insert a space in between any lowercase letter followed by
an upper case letter, thus changing a name like
I<DigitalCameraPictures> to I<Digital Camera Pictures>.

If you're unfamiliar with Perl-style regexps, have a look at the
perlre(1), perlrequick(1), and/or perlretut(1) manpages that come with
Perl.

For those that are familiar with Perl, this script basically runs each
file name through an C<s/I<FROM>/I<TO>/g> command, and renaming it to
whatever comes out.  Obviously, if the substitution results in the
same name as the original, the file will not be renamed.

=head1 OPTIONS

=over

=item B<-t>

Test.  Only shows what changes would be made, without actually making
them

=item B<-a>

Ask.  Shows the changes that are about to be made, then ask whether to
apply them

=item B<-v>

Verbose.  Shows the names of files and what they're renamed to as it's
renaming them.  By default B<rrn> produces no output unless an error
occurs

=item B<-g>

No global.  Applies the substitution to only the first occurance of
I<FROM>.  This is like removing the /g from the end of the s// regexp
in Perl.

=item B<-i>

Case insensitive.  Letters will be matched against the I<FROM> pattern
without regards to capitality.  Note that the matched portion of the
name will still be replaced with the I<TO> text exactly as you
specified it.  Therefore, C<rrn -i a b> will change a
capital 'A' to a lowercase 'b'. This is like adding an /i to the end
of the s// operator

=item B<-e>

Don't change the file's extension.  (Extension is defined as the
portion of the filename including and following the final '.' character in
the file, if there is one)  This removes the extension before substitution,
and replaces it after substitution, so your I<FROM> pattern won't even
match it.

=item B<-c> I<CMD>

Perform I<CMD>, which is a Perl expression.  If this option is
specified, the I<FROM> and I<TO> parameters must be left off.  The
original file name will be found in the $_ variable; your command
should in some fashion modify that variable to what you want the new
name to be.  C<rrn -c 's/FROM/TO/g'> is equivalent to
C<rrn FROM TO>

Note that if the B<-e> option is used, the extension will be removed
from the $_ variable.  This way you can append something to the end of
the name, and it will appear between the end of the filename and the
start of the extension.

=item B<-f> I<CMD>

Similar to B<-c>, but the result of the evaluated expression is used as the new
name.  C<rrn -f lc> is a quick way to convert a filename to all-lowercase
characters.  (Or use C<uc> for uppercase.) As with B<-c>, the original filename
is found in $_, and whatever function you call should access that variable.
Many Perl builtin functions will implicitely acecss $_, so you can simply say,
for instance, C<lc> instead of C<lc($_)>.

Note that this doesn't have to be an actual function, it can be any
expression that returns a value.  So you can say:

=over

C<rrn -f '$foo++ . "_$_"'>

=back

to prepend a number before the filename.

=item B<-E>

A distant cousin to B<-f> and B<-c>, if this is specified then the I<FROM>
parameter is a regex (as usual), but the I<TO> parameter is a Perl expression,
not a regex. Thus, it is somewhat of a hybrid between the B<-f>/B<-c> options
and the defualt behaviour.  Thus,

=over

C<rrn -E '(^\d)' '$1 + 1'>

=back

will increment the number at the start of the filename.

This option is equivalent to C<rrn FROM '${\(TO)}'>.

=item B<-b> I<INIT>

Evaluates the expression I<INIT> before processing any files.  This is
useful if you want to reference a variable in your command, but need
it to be initialized to something first.  For instance:

=over

C<rrn -b '$foo = 1' -f '$foo++ . "_$_"'>

=back

will prepend a number and an underscore to the filename.

=item B<-F>

Force: Renames the file even if a file with the new name already exists.
B<Use with caution!>

=item B<-@>

This will prevent B<rrn> from treating files with names starting with an @
symbol as list files.

=back

=head1 DIAGNOSTICS

=over

=item Skipped I<FILE>: I<NAME> already exists

A file wasn't renamed because the filename it was to be
renamed to was already in use.

=item Could not rename I<FILE>: I<ERROR>

A file wasn't renamed because an OS error occured

=back

=head1 BUGS

Renaming a file to a name with different capitalization but otherwise the
same under Windows will complain about the file already existing.

Probably more, but I use this program all the time so the major ones should be
long since squashed.

=head1 SEE ALSO

rename(1), perlre(1), perlrequick(1), perlretut(1), perlfunc(1), and
other documentation referenced in perl(1)

=head1 AUTHOR

Nathan Roberts <nroberts@tardislabs.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2012 by Nathan Roberts <nroberts@tardislabs.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

=cut
