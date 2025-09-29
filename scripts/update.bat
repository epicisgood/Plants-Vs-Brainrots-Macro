@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul
cd %temp%

:: Parameters
:: %1 = URL
:: %2 = old folder path
:: %3 = CopySettings flag (1 or 0)
:: %4 = DeleteOld flag (1 or 0)
:: %5 = Version number


if [%1]==[] (
    echo No URL parameter supplied.
    pause
    exit /b 1
)
if [%2]==[] (
    echo No target base folder parameter supplied.
    pause
    exit /b 1
)

set "url=%~1"
set "basefolder=%~2"
set "copysettings=%~3"
set "deleteold=%~4"
set "ver=%~5"

:: Compose new folder name with version appended
for %%I in ("%basefolder%") do set "parentfolder=%%~dpI"
set "parentfolder=%parentfolder:~0,-1%"
set "newfolder=%parentfolder%\Epics_GAG_macro_v%ver%"

:: Create new folder
if not exist "%newfolder%" mkdir "%newfolder%"

:: Copy settings.ini if requested and exists
if "%copysettings%"=="1" (
    if exist "%basefolder%\settings.ini" (
        echo Copying settings.ini to new folder...
        copy /Y "%basefolder%\settings.ini" "%newfolder%\settings.ini"
    ) else (
        echo No settings.ini found to copy.
    )
)

:: Download ZIP to temp
set "zipfile=%temp%\Epics_GAG_macro_v%ver%.zip"
echo Downloading %url%...
powershell -Command "(New-Object Net.WebClient).DownloadFile('%url%', '%zipfile%')"
echo Download complete.

:: Extract ZIP into new folder using WSF script
echo Extracting to "%newfolder%"...
for /f delims^=^ EOL^= %%g in ('cscript //nologo "%~f0?.wsf" "%newfolder%" "%zipfile%"') do set "f=%%g"

echo Extraction complete.

:: Delete ZIP
echo Deleting ZIP file...
del /f /q "%zipfile%"
echo ZIP deleted.

:: Start Macro
echo Starting Macro...
start "" "%newfolder%\scripts\AutoHotkey32.exe" "%newfolder%\scripts\Epic's_GAG_macro.ahk"

:: Delete old folder if requested
if "%deleteold%"=="1" (
    echo Deleting old folder "%basefolder%"...
    rd /s /q "%basefolder%"
    echo Old folder deleted.
)

exit /b 0

:: WSF script to extract ZIP
<job><script language="VBScript">
set fso = CreateObject("Scripting.FileSystemObject")
set objShell = CreateObject("Shell.Application")
set FilesInZip = objShell.NameSpace(WScript.Arguments(1)).items
objShell.NameSpace(WScript.Arguments(0)).CopyHere FilesInZip, 20
set fso = nothing
set objShell = nothing
</script></job>
