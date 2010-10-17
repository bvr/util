@ls -lA %1 %2 |perl -ne "push@ln,join('',$_=~/^(.).{54}(.*?)\\?$/);END{for(sort map{s/^d/\\/;s/^-/\xff/;$_}@ln){tr|\xff| |;print qq{$_\n}}}"
