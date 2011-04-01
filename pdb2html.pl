# pdb2html.pl

use Getopt::Long;
use Pod::Usage;
use File::Temp qw(tempfile);
use File::Copy;
use File::Basename;
use Encode;
use CGI        qw(escapeHTML);

GetOptions(
    'help'     => sub { help() },
    'output:s' => \my $output,
    'title:s'  => \my $title,
    'show'     => \my $show,
    'auto|O'   => \my $auto_output,
) or help("Commandline parsing failed");

help("An input have to be specified")
    unless @ARGV;

for my $file (@ARGV) {

    # process file
    my @lines = map { s/^\s+//; s/\s+$//; escapeHTML($_) } `makedoc -d "$file"`;
    my ($fh,$filename) = tempfile(SUFFIX => '.html');
    binmode($fh => ':crlf');

    print {$fh} header($title || make_title_from($file));
    for my $line (@lines) {
        Encode::from_to($line,"cp1250","utf-8");
        print {$fh} "<p>$line</p>\n";
    }
    print {$fh} footer();
    close $fh;

    # actions
    if($auto_output) {
        $output = make_title_from($file) . ".html";
    }
    if($output) {
        warn "Creating file \"$output\"\n";
        move($filename,$output);
        $filename = $output;
    }
    if($show || ! $output) {
        warn "Running browser\n";
        system("start \"\" \"$filename\"");
    }
}

sub help {
    my $msg = shift;
    warn "Error: $msg\n\n" if $msg;
    pod2usage(1);
}

sub make_title_from {
    my $file = fileparse($_[0], qr/\.[^.]+/);
    for($file) {
        tr/_/ /;
        s/-/ - /g;
    }
    return $file;
}

sub header {
    my ($title) = @_;
    return <<HEADER;
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title>$title</title>
    <style>
        * { font-family: Georgia }
        body { padding: 10px 10% }
        p    { padding-bottom: 0.5em; line-height: 130%; margin: 0px }
    </style>
</head>
<body>
HEADER
}

sub footer {
    return <<FOOTER;
</body>
</html>
FOOTER
}

=head1 NAME

pdb2html.pl -- convert palmdoc (pdb) text into HTML

=head1 SYNOPSIS

pdb2html.pl [options] file.pdb [files ...]

=head1 OPTIONS

=over 8

=item B<-output> or B<-o>

Name of output HTML file. If not specified, output file is
generated in temp directory and default browser runned to display it.

=item B<-title> or B<-t>

Specify title of the document. Default is input filename.

=item B<-auto> or B<-O>

Automatically generate new filename based on input in current
directory.

=item B<-show> or B<-s>

Run the browser even when C<-output> or C<-auto> is specified.

=item B<-help>

Prints this help message.

=back

=head1 DESCRIPTION

Uses C<makedoc> command-line tool to decode palmdoc (pdb) text,
wraps it in html envelope and run a browser to display it.

If output filename is specified (C<-output> option), the file
is just saved into specified location. C<-auto> option provides
automatical building of filenames based on input.

A C<-title> option can be used to override default title, which
is input filename.

=head1 AUTHOR

Roman Hubacek, 2011

=cut
