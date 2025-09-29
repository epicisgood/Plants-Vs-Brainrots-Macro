@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul
cd %~dp0

set "arch=%PROCESSOR_ARCHITECTURE%"

set "ahkExe="

if /i "%arch%"=="AMD64" (
	if exist "scripts\AutoHotkey64.exe" (
		set "ahkExe=scripts\AutoHotkey64.exe"
	) else if exist "scripts\AutoHotkey32.exe" (
		set "ahkExe=scripts\AutoHotkey32.exe"
	)
) else (
	if exist "scripts\AutoHotkey32.exe" (
		set "ahkExe=scripts\AutoHotkey32.exe"
	)
)

for /f "delims=#" %%E in ('"prompt #$E# & for %%E in (1) do rem"') do set "\e=%%E"
set red=%\e%[91m
set reset=%\e%[0m

if exist "scripts\Epic's_PVB_macro.ahk" (

	if defined ahkExe (

		start "" "%~dp0!ahkExe!" "%~dp0scripts\Epic's_PVB_macro.ahk" %*
		exit
		
	) else (

		echo %red%No compatible AutoHotkey executable found!%reset%
		echo %red%Please ensure 'AutoHotkey64.exe' or 'AutoHotkey32.exe' is in the 'scripts' folder.%reset%
		echo:
		<nul set /p "=%red%Press any key to exit . . . %reset%"
		pause >nul
		exit

	)

) else (

	echo %red%Could not find 'Epic's_PVB_macro.ahk' script!%reset%
	echo %red%Please ensure it is located in the 'scripts' folder.%reset%
	echo %red%It might be because you did not extract this file.%reset%
	echo:
	<nul set /p "=%red%Press any key to exit . . . %reset%"
	pause >nul
	exit
	
)




echo:	
<nul set /p "=%red%Press any key to exit . . . %reset%"
pause >nul
exit
