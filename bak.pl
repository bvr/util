#!perl
# bak.pl        (c) 2004-2006 Beaver
# syntax: perl bak.pl [what]
#
# backup files into directory bak, using filenames 01.zip,02.zip,...
#
$dir='bak';	# adresar kam se zalohuje bez posledniho lomitka 
$ARGV[0] = "*" if !@ARGV;
print "Archiving @ARGV using zip into archive $Dir/\n";

mkdir("$dir") if !-e $dir;
for $num (1..99) {
	$file = sprintf("%02d.zip",$num);
	last if ! -e "$dir/$file";
}
print "Making bak/$file ... \n";
system("zip $dir/$file -r @ARGV -x $dir/* *.dll *.obj *.exe *.pdb *.res *.sbr *.bak *.ico *.idb *.ilk *.lib *.pch *.ocx tags *.ncb *.exp");
