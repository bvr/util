#!perl
# do_sql.pl        (c) 2007-2011 Beaver
# syntax: perl do_sql.pl [-s server] [-d database] [-e] [-x] file.sql
#
# Does one or more SQL commands specified in file
#

# use strict; use warnings;

use DBI;
use OLE;
use Getopt::Std;
use Config::Auto;
use Text::Trim;
use Try::Tiny;

eval { require Text::TabularDisplay };
use constant HAS_TABULAR => $@ ? 0 : 1;

# configurations of available servers
my %config = %{ Config::Auto::parse('do_sql.ini') };

# process command-line options and setup defaults
my %opt;
getopts("ls:d:xe",\%opt);
my $server     = $opt{s} || "localhost";
my $default_db = $opt{d};
my $expanded   = $opt{e};
my $out_excel  = $opt{x};

# getting file with queries (possibly separated by ; - semicolon)

my $filename = shift
    or die "Error: Missing input SQL filename\n";
my $query = do {
    open(my $in,"<",$filename) or die "\"$filename\" could not be opened";
    local $/;
    <$in>;
};

# get overrides from file itself
if($query =~ /^\s*-- DB:(.*)$/im) {
    $default_db = trim($1);
}
if($query =~ /^\s*-- Server:(.*)$/im) {
    $server = trim($1);
}
if($query =~ /^\s*-- Options:(.*)$/im) {
    for my $item (split /\s+/,trim($1)) {
        $expanded  = 1 if $item =~ /exp/i;
        $out_excel = 1 if $item =~ /exc/i;
        $out_table = 1 if $item =~ /tab/i;
        $quote     = 1 if $item =~ /quo/i;
    }
}

if($out_table && ! HAS_TABULAR) {
    die "Text::TabularDisplay has to be installed\n";
}

my $cfg = $config{$server}
    or die "Undefined server \"$server\"";;

# build dsn and connect into given database
my $driver = $cfg->{driver} || 'mysql';
<<<<<<< HEAD
my $dsn = "$driver:host=$cfg->{serv}";
=======
my $dsn = "$driver:$cfg->{serv}";
>>>>>>> 99705a1f3cd9b0e552c49915aebf241971c1ba04
if($default_db) {
    $dsn .= ";database=$default_db";
}
my $dm = DBI->connect("DBI:$dsn",$cfg->{user},$cfg->{pass},
    { RaiseError => 1, PrintError => 0 });

if($out_excel) {

    # preparation to excel output - init instance of application
    my $excel = CreateObject OLE 'Excel.Application' or die $!;
    $excel->{'Visible'} = 1;
    $workbook = $excel->Workbooks->Add;
}

# remove comments out of query
$query =~ s/-- .*?\n//sg;

# split queries and do them
for $part_query (split /;/,$query) {        # TODO: some more elaborate command splitting
    next if $part_query =~ /^\s*$/s;        # skip empty queries

    trim($part_query);
    my $sth;
    try {
        $sth = $dm->prepare($part_query);
        $sth->execute();
    }
    catch {
        warn "In query \"$part_query\":\n";
        die $_;
    };

    my $columns = $sth->{NAME};

    if($out_excel) {

        # excel output
       	my $sheet = $workbook->Worksheets->Add;
        my $pos   = $sheet->Range("A1:".(('A'..'Z','AA'..'AZ')[$#$columns])."1");

        # print out columns header
        $pos->{'Value'} = $columns;
        $pos->Font->{Bold} = 1;

        # print out data
        my $j = 1;
        while(my $row = $sth->fetchrow_arrayref()) {
            $pos->Offset($j++,0)->{Value} = $row;
        }

        # autofit columns
        my @cols = ('A' .. 'Z');
        for my $col ( $cols[0] .. $cols[$#$columns]) {
            $workbook->ActiveSheet->Columns("$col:$col")->EntireColumn->AutoFit();
        }

    }
    elsif($out_table) {
        my $gen = Text::TabularDisplay->new(@$columns);
        my $total;
        while(my $row = $sth->fetchrow_arrayref()) {
            my @data = @$row;
            if($quote) {
                @data = map { s/\t/\\t/g; tr/\r//d; s/\n/\\n/gs; "\"$_\"" } @data;
            }
            $gen->add(@data);
            $total++;
        }
        print $gen->render,"\n";
        print "$total rows in set\n";
    }
    else {

        # textual output
        unless($expanded) {
            print "$_\t" for(@$columns);
            print "\n";
        }

        # print out data
        while(my $row = $sth->fetchrow_arrayref()) {
            $i = 0;
            for my $item (@$row) {
                $item = defined $item ? $item : "";
                if($expanded) {  printf "[%d] %s\t\"%s\"\n",$i,$$columns[$i],$item; $i++; }
                else          {  print "$item\t"; }
            }
            if($expanded) { print "-----"; }
            print "\n";
        }
    }
}

$dm->disconnect();

=head1 NAME

do_sql - run SQL query from file

=head1 SYNOPSIS

    perl do_sql.pl [-s server] [-d database] [-e] [-x] file.sql

=head1 DESCRIPTION

Runs SQL query from file and present output in various ways.

=head2 OPTIONS

Some options can be specified as comments within SQL file:

=over

=item B<Server>

server nick as specified in group tag of ini file.

=item B<DB>

database to use prior running the query

=item B<Options>

some options, mostly format of output. It can be B<Excel>, B<Expand>,
B<Table> or B<Quote>. Some options can be combined if it makes sense, like
B<Table> with B<Quote>.

=over

=item B<Excel>

Fill resultset into Excel via OLE interface, bolden header and autosize columns.

=item B<Expand>

Prints output similar manner as C<\G> does in mysql console.

=item B<Table>

Prints table via L<Text::TabularDisplay>, if the module is available.

=item B<Quote>

Puts quotes around values. It is sometimes useful to detect
leading/trailing whitespace in data.

=back

=back

=head1 EXAMPLE SQL FILE

    -- Server: localhost
    -- DB: trac
    -- Options: Tabular, Quote

    SELECT DISTINCT author FROM ticket_change ORDER BY author

=head1 INI FILE

Configuration is located with L<Config::Auto> in home directory as C<do_sql.ini>.
The format is standard INI file like this:

    [localhost]
    serv  = localhost
    user  = root
    pass  =

    ....

=cut
