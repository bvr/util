@echo off
IF EXIST .svn (
    start "" "c:\Program Files\TortoiseSVN\bin\TortoiseProc.exe" %*
) ELSE (
    start "" "c:\Program Files\TortoiseGit\bin\TortoiseProc.exe" %*
)
