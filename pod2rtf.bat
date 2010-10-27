@perl.exe -MPod::Simple::RTF -e "exit Pod::Simple::RTF->filter(shift)->any_errata_seen" %1 >%1.rtf
