@makedoc -d %* | iconv -f CP1250 -t CP852 | perl -MText::Autoformat -pe "$_=autoformat($_);" | less
