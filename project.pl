
# project.pl

use 5.010;
use Path::Class;
use App::Ack;

my $dir = dir(".")->absolute;
my $start_dir = $dir;
my $project_dir;

while(1) {
    if(is_project_dir($dir)) {
        $project_dir = $dir;
        last;
    }
    last if $dir->parent eq $dir;
    $dir = $dir->parent;
}

if($project_dir) {
    print "Directory: $dir\n";
    my $rel_dir = $project_dir->relative->stringify;

    my $opt = App::Ack::get_command_line_options();
    @ARGV = map { ('-G', $_) } @ARGV;
    my $more_opt = App::Ack::get_command_line_options();
    $opt = { %$opt, %$more_opt };
    
    my $what = App::Ack::get_starting_points( [$rel_dir], $opt );
    my $iter = App::Ack::get_iterator( $what, $opt );
    App::Ack::filetype_setup();
    while(defined (my $file = $iter->()) ) {
        printf "%s:1:\n",$file;
    }
}
else {
    print "No project found for $start_dir\n";
}


sub is_project_dir {
    my $dir = shift;

    return 1 if lc($dir->file->basename) ~~ ["lib","trunk"];
    return 1 if lc($dir->parent->file->basename) ~~ ["tags","branches"];
    return 0;
}

=head1 NAME

project - locate files from project

=head1 SYNOPSIS

    project [filter(s)]

=head1 DESCRIPTION

This is small application to locate files from current project. By project is
meant group of files in 

=over

=item * standard perl distribution, i.e. B<lib> and B<bin> directories

=item * subversion repository, i.e. anything in B<trunk> or subdirectories of B<tags> and B<branches>

=back

This app will locate files of the project that current directory belongs to 
and list them in format:

    filename:1:optional description of file

The format is useful to go into file in capable editor (like SciTE).

Without parameters it lists all files of project of specified type, with parameters
the list is filtered.

=head1 SEE ALSO

L<ack>

=cut
