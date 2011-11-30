; toclip.ahk       (c) 2011 Beaver
; syntax: toclip [-rf] params
;
; Read/Write access the clipboard
;

if 1 = -r
{
    FileAppend, %clipboard%, *
}
else if 1 = -f
{
    FileName =

    Count = %0%
    Count := Count - 1
    Loop %Count%
    {
        idx := A_Index + 1
        Param := %idx%
        FileName = %FileName% %Param%
    }
    FileRead Text, %FileName%
    clipboard = %Text%
}
else
{
    Text =
    Loop, %0%  ; For each parameter:
    {
        Param := %A_Index%
        Text = %Text% %Param%
    }
    if ! Text
        Text := StdIn()
    clipboard = %Text%
}


StdIn(max_chars=0xfff)
{
    static hStdIn=-1
    ; The following is for vanilla compatibility
    ptrtype := (A_PtrSize = 8) ? "ptr" : "uint"

    if (hStdIn = -1)
    {
        hStdIn := DllCall("GetStdHandle", "UInt", -10,  ptrtype) ; -10=STD_INPUT_HANDLE
        if ErrorLevel
            return 0
    }

    max_chars := VarSetCapacity(text, max_chars*(!!A_IsUnicode+1), 0)

    ret := DllCall("ReadFile"
        ,  ptrtype, hStdIn        ; hFile
        ,  "Str", text          ; lpBuffer
        , "UInt", max_chars*(!!A_IsUnicode+1)     ; nNumberOfBytesToRead
        , "UInt*", bytesRead    ; lpNumberOfBytesRead
        ,  ptrtype, 0)            ; lpOverlapped

    return text
}
