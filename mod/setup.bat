@echo off
setlocal enableextensions enabledelayedexpansion
set /a errno=0
set my_dir=%cd%
set root=%~dp0
set root=%root:~0,-1%

echo Setting up Boardball...

echo   Downloading README.txt ...
call "%root%\bin\w32\gnuwin32\wget" -O "%root%\README.txt" -q --no-check-certificate https://raw.githubusercontent.com/FUMBBLPlus/boardball/master/mod/README.txt 2> NUL

for %%d IN (boardball, jar) do (
  if not exist "%root%\%%d" (
    echo   Creating %%d directory...
  )
  if exist "%root%\%%d" (
    echo   Clearing %%d directory...
    rem http://superuser.com/questions/179660/how-to-recursively-delete-directory-from-command-line-in-windows
    rmdir "%root%\%%d" /s /q 2> NUL
  )
  mkdir "%root%\%%d" 2> NUL
)

for %%s IN (^
  FantasyFootballClient.jar^
  ,^
  FantasyFootballClientResources.jar^
  ,^
  org.osgi.core-4.3.0.jar^
  ,^
  jorbis-0.0.17.jar^
  ,^
  tinysound-1.1.1.jar^
  ,^
  tritonus_share.jar^
  ,^
  vorbisspi1.0.3.jar^
  ) DO (
  echo   Downloading %%s ...
  rem http://stackoverflow.com/a/1459107/2334951
  call "%root%\bin\w32\gnuwin32\wget" -O "%root%\jar\%%s" -q --no-check-certificate http://fumbbl.com/FFBClient/live/%%s 2> NUL
)

rem http://stackoverflow.com/questions/27751630/websocket-client-could-not-find-an-implementation-class/28026505#28026505
echo   Downloading tyrus-standalone-client-1.9.jar ...
call "%root%\bin\w32\gnuwin32\wget" -O "%root%\jar\tyrus-standalone-client-1.9.jar" -q --no-check-certificate http://repo1.maven.org/maven2/org/glassfish/tyrus/bundles/tyrus-standalone-client/1.9/tyrus-standalone-client-1.9.jar 2> NUL

for %%s in (^
  FantasyFootballClient.jar^
  ,^
  FantasyFootballClientResources.jar^
  ) DO (
  call "%root%\bin\w32\7z\7za" l -ba -slt "%root%\jar\%%s" "META-INF\*" > "%root%\META-INF.lst.txt"
  rem http://stackoverflow.com/a/11225757/2334951
  for %%t in ("%root%\META-INF.lst.txt") do if not %%~zt lss 1 (
    echo   Clearing META-INF of %%s ...
    call "%root%\bin\w32\7z\7za" d "%root%\jar\%%s" "META-INF\*" > NUL
  )
  del "%root%\META-INF.lst.txt" > NUL
)

echo   Downloading empty image...
mkdir "%root%\boardball\icons" > NUL
call "%root%\bin\w32\gnuwin32\wget" -O "%root%\boardball\icons\empty.png" -q --no-check-certificate https://raw.githubusercontent.com/FUMBBLPlus/boardball/master/images/empty.png 2> NUL

echo   Adding empty image to FantasyFootballClientResources.jar ...
cd /D "%root%\boardball"
call "%root%\bin\w32\7z\7za" a "%root%\jar\FantasyFootballClientResources.jar" "icons\empty.png" > NUL
cd /D "%my_dir%"

echo   Downloading board...
mkdir "%root%\boardball\icons\cached\pitches" 2> NUL
call "%root%\bin\w32\gnuwin32\wget" -O "%root%\boardball\icons\cached\pitches\default.zip" -q --no-check-certificate https://github.com/FUMBBLPlus/boardball/releases/download/pitch/boardball.zip 2> NUL

echo   Replacing board in FantasyFootballClientResources.jar ...
cd /D "%root%\boardball"
call "%root%\bin\w32\7z\7za" u "%root%\jar\FantasyFootballClientResources.jar" "icons\cached\pitches\default.zip" > NUL
cd /D "%my_dir%"

echo   Extracting client.ini from FantasyFootballClient.jar ...
call "%root%\bin\w32\7z\7za" e -o"%root%\boardball" "%root%\jar\FantasyFootballClient.jar" "client.ini" > NUL

echo   Removing bloodspots...
call "%root%\bin\w32\gnuwin32\sed" "s/\(bloodspot.\+=\).\+/\1empty.png/" "%root%\boardball\client.ini" > "%root%\boardball\client.ini.bak"
del "%root%\boardball\client.ini" > NUL
ren "%root%\boardball\client.ini.bak" "client.ini" > NUL

echo   Replacing modified client.ini in FantasyFootballClient.jar ...
call "%root%\bin\w32\7z\7za" u "%root%\jar\FantasyFootballClient.jar" "%root%\boardball\client.ini" > NUL


:setup_registry
echo   Setting up registry...
echo     Register Boardball as an Application...
reg add "HKCU\Software\Classes\Applications\boardball.exe\shell\open\command" /ve /t REG_SZ /d "\"%root%\boardball.exe\" \"%%1\"" /f > NUL

for /f "tokens=1* " %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jnlp\OpenWithList" ^| "%root%\bin\w32\gnuwin32\egrep.exe" -o ".+REG_SZ.+boardball.exe"') do @set jnlp_assoc=%%a
for /f "delims=" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jnlp\OpenWithList" /v MRUList 2^>NUL ^| "%root%\bin\w32\gnuwin32\sed.exe" "s/.\+MRUList\s\+REG_SZ\s\+\(\w\+\)/\1/"') do @set mrulist_unsorted=%%a
rem sort MRUList
rem http://stackoverflow.com/a/28310893/2334951
rem http://stackoverflow.com/a/25758360/2334951
set "mrulist="
for /f "delims=" %%a in ('echo %mrulist_unsorted% ^| "%root%\bin\w32\gnuwin32\grep.exe" -o . ^| "%root%\bin\w32\gnuwin32\sort.exe"') do @set "mrulist=!mrulist!%%a"
if not "%jnlp_assoc%" == "" goto after_jnlp_assoc
echo     Associate Boardball with JNLP files...
for /f "tokens=1*" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jnlp\OpenWithList" ^| "%root%\bin\w32\gnuwin32\egrep.exe" -o "[[:space:]]\w[[:space:]]+REG_SZ" ^| "%root%\bin\w32\gnuwin32\sort.exe" ^| "%root%\bin\w32\gnuwin32\tail.exe" -1') do @set last_jnlp_assoc_char=%%a
if "%last_jnlp_assoc_char%" == "" goto jnlp_assoc_fail
rem Get next alpha charater for Boardball
for /f %%a in ('echo %last_jnlp_assoc_char% ^| "%root%\bin\w32\gnuwin32\tr.exe" "a-yA-Y" "b-zB-Z"') do set jnlp_assoc_char=%%a
set "mrulist=%mrulist%%jnlp_assoc_char%"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jnlp\OpenWithList" /v %jnlp_assoc_char% /t REG_SZ /d "boardball.exe" /f 1> NUL
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jnlp\OpenWithList" /v MRUList /t REG_SZ /d %mrulist% /f 1> NUL
goto after_jnlp_assoc
:jnlp_assoc_fail
echo Error. Unable to associate.
set /a errno=10
:after_jnlp_assoc

:end
echo Done.
endlocal
pause
exit /B %errno%
