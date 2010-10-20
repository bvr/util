; Activate Total Commander, make new tab and move to current directory
IfWinExist, ahk_class TTOTAL_CMD
    WinActivate
SendInput,^Tcd %A_WorkingDir%{Enter}
