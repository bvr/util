; console launcher                        (c) 2009-2010 Roman Hubacek

; read commandline options
Command =
Loop, %0%  ; For each parameter:
{
    Param := %A_Index%
    If InStr(Param," ")
        Command = %Command% "%Param%"
    Else
        Command = %Command% %Param%
}

; launch/activate Console2 application
IfWinExist ahk_class Console_2_Main
{
    ; run add new console tab in existing console
    ControlSend,,^{F1},ahk_class Console_2_Main
    WinActivate
}
Else
{
    ; run the console
    Run,console.exe
    WinWait, ahk_class Console_2_Main,,3
}

SplitPath,A_WorkingDir,OutFileName,OutDir,OutExtension,OutNameNoExt,OutDrive
SplitPath,OutDir,PreOutFileName
If !PreOutFileName
    PreOutFileName = %OutDrive%
CurDirectory = %A_WorkingDir%
SendPlay, %OutDrive% {Enter}pushd "%CurDirectory%"{Enter}cls{Enter}
SendPlay, {F2}%PreOutFileName%\%OutFileName%{Enter}

; if defined, send the command to active window
If %Command%
{
    SendPlay, %Command%{Enter}
}
