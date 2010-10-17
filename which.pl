use Pod::Usage;

my $program   = shift;
my @path_dirs = split /;/, $ENV{PATH};

# help message
pod2usage(-verbose => 99, -sections => "DESCRIPTION|SYNOPSIS")
    if ! $program;

# support for simple word searches
if($program !~ /[.*]/) {
    $program .= ".*";
}

my %already_checked = ();

# find program along all dirs from path
for my $dir (@path_dirs) {

    # make directory universally globable
    for($dir) { s/\\$//; tr/\\/\//; s/ /\\ /g; }

    next if $already_checked{"\L$dir"}++;

    # find all requested files within directory
    for my $file (grep {-e $_} glob "$dir/$program") {
        $file =~ s{[/]}{\\}g;
        print "$file\n" if $file =~ /\.(exe|com|bat|cmd|pl|lnk|pif)$/i;
    }
}

=head1 DESCRIPTION

=over

=item B<which>

looks for given program/file along the path directories,
in order they are sought by operating system.

=back

=head1 SYNOPSIS

    which [executable|wildcard]

=cut
