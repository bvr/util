#!perl
# wm.pl        (c) 2006-2011 Beaver
# syntax: perl wm.pl list_file
#
# Call from Total Commander as "perl -S wm.pl %F", show winmerge
# for two selected files
#

open my $in,'<',$ARGV[0] or die;
my @a = map { chomp; "\"$_\"" } <$in>;
system start => ('""', "\"$ENV{HOME}\\WinMerge\\WinMergeU.exe\"", @a);
