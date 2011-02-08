@dir /b/s %* | perl -lne "print if !/\.svn|Helpers|doc/ && ! -d" | perl -MPath::Class -lnE "$ln .= qq{ \x22}.file($_)->relative.qq{\x22} }{ system qq{wc $ln}"
