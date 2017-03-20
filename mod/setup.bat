@echo off
setlocal enableextensions enabledelayedexpansion
set /a errno=0
set my_dir=%cd%
set root=%~dp0
set root=%root:~0,-1%

echo Setting up Boardball...

:setup_registry
echo   Setting up registry...
echo     Register Boardball as an Application...
reg add "HKCU\Software\Classes\Applications\boardball.exe\shell\open\command" /ve /t REG_SZ /d "\"%root%\boardball.exe\" \"%%1\"" /f > NUL

rem Check if boardball is already associated with JNLP files
for /f "tokens=1* " %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jnlp\OpenWithList" ^| "%root%\bin\w32\gnuwin32\egrep.exe" -o ".+REG_SZ.+boardball.exe"') do @set jnlp_assoc=%%a
if not "%jnlp_assoc%" == "" goto after_jnlp_assoc
rem Get current MRUList
for /f "delims=" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jnlp\OpenWithList" /v MRUList 2^>NUL ^| "%root%\bin\w32\gnuwin32\sed.exe" "s/.\+MRUList\s\+REG_SZ\s\+\(\w\+\)/\1/"') do @set mrulist_unsorted=%%a
rem Sort MRUList
rem http://stackoverflow.com/a/28310893/2334951
rem http://stackoverflow.com/a/25758360/2334951
set "mrulist="
for /f "delims=" %%a in ('echo %mrulist_unsorted% ^| "%root%\bin\w32\gnuwin32\grep.exe" -o . ^| "%root%\bin\w32\gnuwin32\sort.exe"') do @set "mrulist=!mrulist!%%a"
echo     Associate Boardball with JNLP files...
rem Get last association character (a,b,c,...)
for /f "tokens=1*" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jnlp\OpenWithList" ^| "%root%\bin\w32\gnuwin32\egrep.exe" -o "[[:space:]]\w[[:space:]]+REG_SZ" ^| "%root%\bin\w32\gnuwin32\sort.exe" ^| "%root%\bin\w32\gnuwin32\tail.exe" -1') do @set last_jnlp_assoc_char=%%a
rem If not found, that is an unexpected error
if "%last_jnlp_assoc_char%" == "" goto jnlp_assoc_fail
rem Get next charater for boardball.exe
for /f %%a in ('echo %last_jnlp_assoc_char% ^| "%root%\bin\w32\gnuwin32\tr.exe" "a-yA-Y" "b-zB-Z"') do set jnlp_assoc_char=%%a
rem Append it to MRUList
set "mrulist=%mrulist%%jnlp_assoc_char%"
rem Add association key for boardball.exe and update MRUList
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jnlp\OpenWithList" /v %jnlp_assoc_char% /t REG_SZ /d "boardball.exe" /f 1> NUL
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jnlp\OpenWithList" /v MRUList /t REG_SZ /d %mrulist% /f 1> NUL
goto after_jnlp_assoc
:jnlp_assoc_fail
echo Error. Unable to associate. Java might not have been installed.
echo Otherwise, open JNLP file with boardball.exe manually.
set /a errno=10
:after_jnlp_assoc

:end
echo Done.
endlocal
pause
exit /B %errno%
