@rem = '--*-Perl-*--
@echo off
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
@rem ';
#!perl

use List::Util qw(first);

# pick proper location
$tool = first { -e $_ }
    q'C:\Program Files\autohotkey\Compiler\Ahk2Exe.exe',
    q'D:\Prog\autohotkey\Compiler\Ahk2Exe.exe';

# for all arguments (expected .ahk file), convert them to .exe
for $file (@ARGV) {
    my $file_exe = $file;
    unless($file_exe =~ s/\.[^.]+$/.exe/) {
        $file_exe .= ".exe";
    }
    my $cmd = "\"$tool\" /in \"$file\" /out \"$file_exe\"";
    warn $cmd,"\n";
    system $cmd;
}

__END__
:endofperl
