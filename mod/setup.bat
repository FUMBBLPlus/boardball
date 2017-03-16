@echo off
setlocal enableextensions enabledelayedexpansion
set /a errno=0
set my_dir=%cd%
set root=%~dp0
set root=%root:~0,-1%

echo Setting up Luckboard...

for %%d IN (luckboard, jar) do (
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

echo   Downloading README.txt ...
call "%root%\bin\w32\gnuwin32\wget" -O "%root%\README.txt" -q --no-check-certificate https://raw.githubusercontent.com/FUMBBLPlus/luckboard/master/mod/README.txt 2> NUL

echo   Downloading client.ini ...
call "%root%\bin\w32\gnuwin32\wget" -O "%root%\luckboard\client.ini" -q --no-check-certificate https://raw.githubusercontent.com/FUMBBLPlus/luckboard/master/mod/luckboard/client.ini 2> NUL

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

mkdir "%root%\luckboard\icons" > NUL

echo   Downloading empty image...
call "%root%\bin\w32\gnuwin32\wget" -O "%root%\luckboard\icons\empty.png" -q --no-check-certificate https://raw.githubusercontent.com/FUMBBLPlus/luckboard/master/images/empty.png 2> NUL

echo   Adding empty image to FantasyFootballClientResources.jar ...
cd /D "%root%\luckboard"
call "%root%\bin\w32\7z\7za" a "%root%\jar\FantasyFootballClientResources.jar" "icons\empty.png" > NUL
cd /D "%my_dir%"

mkdir "%root%\luckboard\icons\decorations" > NUL

echo   Downloading decoration: hold luck ...
call "%root%\bin\w32\gnuwin32\wget" -O "%root%\luckboard\icons\decorations\lb_holdluck.png" -q --no-check-certificate https://raw.githubusercontent.com/FUMBBLPlus/luckboard/master/images/luck/holdluck.png 2> NUL

echo   Downloading decoration: selected luck ...
call "%root%\bin\w32\gnuwin32\wget" -O "%root%\luckboard\icons\decorations\lb_selluck.png" -q --no-check-certificate https://raw.githubusercontent.com/FUMBBLPlus/luckboard/master/images/luck/selluck.png 2> NUL

echo   Adding decoration images to FantasyFootballClientResources.jar ...
cd /D "%root%\luckboard"
call "%root%\bin\w32\7z\7za" a "%root%\jar\FantasyFootballClientResources.jar" "icons\decorations\*.*" > NUL
cd /D "%my_dir%"

mkdir "%root%\luckboard\icons\game" > NUL
echo   Downloading luck image...
call "%root%\bin\w32\gnuwin32\wget" -O "%root%\luckboard\icons\game\lb_luck.png" -q --no-check-certificate https://raw.githubusercontent.com/FUMBBLPlus/luckboard/master/images/luck/luck.png 2> NUL

echo   Adding game images to FantasyFootballClientResources.jar ...
cd /D "%root%\luckboard"
call "%root%\bin\w32\7z\7za" a "%root%\jar\FantasyFootballClientResources.jar" "icons\game\*.*" > NUL
cd /D "%my_dir%"

mkdir "%root%\luckboard\sounds" > NUL
for %%s IN (^
  lb_bounce-stone-stone.ogg^
  ,^
  lb_clap.ogg^
  ,^
  lb_cough.ogg^
  ,^
  lb_ding.ogg^
  ,^
  lb_ding-ding.ogg^
  ,^
  lb_double-stone-stone.ogg^
  ,^
  lb_double-stone-wood.ogg^
  ,^
  lb_drop-stone-stone.ogg^
  ,^
  lb_laugh.ogg^
  ,^
  lb_stone-wood.ogg^
  ,^
  empty.wav^
  ) DO (
  echo   Downloading sound: %%s ...
  call "%root%\bin\w32\gnuwin32\wget" -O "%root%\luckboard\sounds\%%s" -q --no-check-certificate https://raw.githubusercontent.com/FUMBBLPlus/luckboard/master/sounds/%%s 2> NUL
)

echo   Adding sounds to FantasyFootballClientResources.jar ...
cd /D "%root%\luckboard"
call "%root%\bin\w32\7z\7za" a "%root%\jar\FantasyFootballClientResources.jar" "sounds\*.*" > NUL
cd /D "%my_dir%"

echo   Downloading board...
mkdir "%root%\luckboard\icons\cached\pitches" 2> NUL
call "%root%\bin\w32\gnuwin32\wget" -O "%root%\luckboard\icons\cached\pitches\default.zip" -q --no-check-certificate https://github.com/FUMBBLPlus/luckboard/releases/download/pitch/luckboard.zip 2> NUL

echo   Replacing board in FantasyFootballClientResources.jar ...
cd /D "%root%\luckboard"
call "%root%\bin\w32\7z\7za" u "%root%\jar\FantasyFootballClientResources.jar" "icons\cached\pitches\default.zip" > NUL
cd /D "%my_dir%"

echo   Replacing client.ini in FantasyFootballClient.jar ...
call "%root%\bin\w32\7z\7za" u "%root%\jar\FantasyFootballClient.jar" "%root%\luckboard\client.ini" > NUL

:setup_registry
echo   Setting up registry...
echo     Register Luckboard as an Application...
reg add "HKCU\Software\Classes\Applications\luckboard.exe\shell\open\command" /ve /t REG_SZ /d "\"%root%\luckboard.exe\" \"%%1\"" /f > NUL

rem Check if luckboard is already associated with JNLP files
for /f "tokens=1* " %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jnlp\OpenWithList" ^| "%root%\bin\w32\gnuwin32\egrep.exe" -o ".+REG_SZ.+luckboard.exe"') do @set jnlp_assoc=%%a
if not "%jnlp_assoc%" == "" goto after_jnlp_assoc
rem Get current MRUList
for /f "delims=" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jnlp\OpenWithList" /v MRUList 2^>NUL ^| "%root%\bin\w32\gnuwin32\sed.exe" "s/.\+MRUList\s\+REG_SZ\s\+\(\w\+\)/\1/"') do @set mrulist_unsorted=%%a
rem Sort MRUList
rem http://stackoverflow.com/a/28310893/2334951
rem http://stackoverflow.com/a/25758360/2334951
set "mrulist="
for /f "delims=" %%a in ('echo %mrulist_unsorted% ^| "%root%\bin\w32\gnuwin32\grep.exe" -o . ^| "%root%\bin\w32\gnuwin32\sort.exe"') do @set "mrulist=!mrulist!%%a"
echo     Associate Luckboard with JNLP files...
rem Get last association character (a,b,c,...)
for /f "tokens=1*" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jnlp\OpenWithList" ^| "%root%\bin\w32\gnuwin32\egrep.exe" -o "[[:space:]]\w[[:space:]]+REG_SZ" ^| "%root%\bin\w32\gnuwin32\sort.exe" ^| "%root%\bin\w32\gnuwin32\tail.exe" -1') do @set last_jnlp_assoc_char=%%a
rem If not found, that is an unexpected error
if "%last_jnlp_assoc_char%" == "" goto jnlp_assoc_fail
rem Get next charater for luckboard.exe
for /f %%a in ('echo %last_jnlp_assoc_char% ^| "%root%\bin\w32\gnuwin32\tr.exe" "a-yA-Y" "b-zB-Z"') do set jnlp_assoc_char=%%a
rem Append it to MRUList
set "mrulist=%mrulist%%jnlp_assoc_char%"
rem Add association key for luckboard.exe and update MRUList
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jnlp\OpenWithList" /v %jnlp_assoc_char% /t REG_SZ /d "luckboard.exe" /f 1> NUL
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jnlp\OpenWithList" /v MRUList /t REG_SZ /d %mrulist% /f 1> NUL
goto after_jnlp_assoc
:jnlp_assoc_fail
echo Error. Unable to associate. Maybe Java is not installed.
set /a errno=10
:after_jnlp_assoc

:end
echo Done.
endlocal
pause
exit /B %errno%
