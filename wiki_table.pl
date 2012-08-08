
use strict;
use List::MoreUtils qw(apply);

sub esc_camel {
    return apply {s/(\b([A-Z][a-z]+){2,}\b)/!$1/g} (@_ ? @_ : $_);
}

my @line;
while (<>) {
    chomp;

    # skip separators (empty lines or +--------+----------+ )
    next if /^[+-]*$/;

    my @cols = split(/[ ]*[\|\t][ ]*/, $_, -1);
    @cols = splice(@cols, 1, -1) if $cols[0] eq '';
    push @line, [@cols];
}

my $header = shift @line;
print "||'''", join("'''||'''", map {esc_camel} @$header), "'''||\n";
for my $ln (@line) {
    print '||', join('||', map {esc_camel} @$ln), "||\n";
}
