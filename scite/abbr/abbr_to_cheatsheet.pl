
use strict; use warnings;
use Template;
use autodie;

my $abbr_filename = shift
    or die "syntax: perl $0 abbr.properties\n";
open my $in,"<",$abbr_filename;

my @abbr;
my $items;
while(<$in>) {
    chomp;

    # skip empty lines
    next if /^\s*$/;

    # first section or comment in abbr file
    if(! defined $items || /^\s*#\s*(.*)$/) {
        my $section = { heading => $1 || "general", items => [] };
        push @abbr, $section;
        $items = $section->{items};
        next;
    }

    # abbreviation
    my ($name, $text) = split /\s*=\s*/, $_, 2;

    # expand text entities
    for($text) {
        s/(?<!\\)\\n/\n/g;    # translate "\\n" -> "\n", but not "\\\\n"
        s/\\t/\t/g;
        s/\\\\/\\/g;
    }

    push @$items, { name => $name, text => $text };
}

my $tt = Template->new;
$tt->process(\*DATA, { abbr => \@abbr }) or die $tt->error();

__DATA__
[% FOREACH section IN abbr %]
== [% section.heading %] ==

[% FOREACH item IN section.items %]
-- [% item.name %] --

[% item.text %]
[% END %]
[% END %]
