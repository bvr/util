IfWinExist ahk_class Console_2_Main
{
    SplitPath,A_WorkingDir,OutFileName,OutDir,OutExtension,OutNameNoExt,OutDrive
    CurDirectory = %A_WorkingDir%
    ControlSend,,^{F1},ahk_class Console_2_Main
    WinActivate
    SendPlay, %OutDrive% {Enter}cd "%CurDirectory%"{Enter}cls{Enter}^r%OutFileName%{Enter}
}
Else
    Run,console.exe -d .
