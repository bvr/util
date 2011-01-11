use Term::ReadLine;
use HTML::TreeBuilder;
use LWP::Simple;
use Encode;
use List::Util qw(max);

# direction of translate
my $dir = shift || 'en_cz';
$dir = $dir =~ /^(en|us)/i ? "en_cz"
     : $dir =~ /^c[sz]/i   ? "cz_en"
     : $dir;

# words on commandline
if(@ARGV) {
    for (@ARGV) {
        print '>',$_,"\n";
        print_translation($_);
    }
    exit;
}

# otherwise bring user interface
my $term   = Term::ReadLine->new('Seznam Dictionary');
my $prompt = ">";
my $OUT    = $term->OUT || \*STDOUT;
while (defined($word = $term->readline($prompt))) {
    exit if $word =~ /^\s*$/;       # on empty word
    print_translation($word);
    $term->addhistory($word);
}


sub print_translation {
    my $word = shift;

    # underline the entry
    print "-"x (length($word)+2),"\n";

    # get the data from slovnik.seznam.cz
    Encode::from_to($word,"cp852","utf-8");
    my $tree = HTML::TreeBuilder->new_from_content(
        get("http://slovnik.seznam.cz/?q=$word&lang=$dir"));

    # results fetch
    my $res = $tree->look_down(id => 'results');
    if(! defined $res) {
        print "Not found\n\n";
        next;
    }

    # translations
    my $res_text = '';
    for $row ($res->find('tr')) {
        my ($from,$to) = map {
            my $text = $_->as_text;
            Encode::from_to($text,"utf-8","cp852");
            trim($text);
        } $row->find('td');
        $to =~ s/\?-/-/g;
        $to =~ s/\s+- / - /g;
        $to =~ s/(.{50,}?) - / $1 . "\n" . " "x(length $from) . " - "/ge;
        $res_text .=  $from . ' ' . $to . "\n";
    }
    print $res_text,"\n";

    # collocations
    my @colloc = ();
    for $row ($res->look_down(_tag => qr/^(dt|dd)$/i)) {
        my $text = $row->as_text;
        Encode::from_to($text,"utf-8","cp852");
        push @colloc, $text;
    }

    my $longest = max map { length } @colloc[ map { $_*2 } (0..$#colloc/2) ];
    for my $i (0..$#colloc/2) {
        my $line = sprintf "%-${longest}s%s\n",$colloc[2*$i],$colloc[2*$i+1];
        $line =~ s/\?-/-/g;
        print $line;
    }
}

sub trim {
    @_ = @_ ? @_ : $_ if defined wantarray;
    for (@_ ? @_ : $_) { s/\A\s+//; s/\s+\z// }
    return wantarray ? @_ : "@_";
}
