@echo off
setlocal
set /a errno=0
set my_dir=%cd%
set root=%~dp0
set root=%root:~0,-1%

echo Setting up Boardball...

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
  ) DO (^
  echo   Downloading %%s ...
  rem http://stackoverflow.com/a/1459107/2334951
  call "%root%\bin\w32\gnuwin32\wget" -O "%root%\jar\%%s" -q --no-check-certificate http://www.fumbbl.com/FFBClient/live/%%s 2> NUL
)

rem http://stackoverflow.com/questions/27751630/websocket-client-could-not-find-an-implementation-class/28026505#28026505
echo   Downloading tyrus-standalone-client-1.9.jar ...
call "%root%\bin\w32\gnuwin32\wget" -O "%root%\jar\tyrus-standalone-client-1.9.jar" -q --no-check-certificate http://repo1.maven.org/maven2/org/glassfish/tyrus/bundles/tyrus-standalone-client/1.9/tyrus-standalone-client-1.9.jar 2> NUL

for %%s in (^
  FantasyFootballClient.jar^
  ,^
  FantasyFootballClientResources.jar^
  ) DO (^
  call "%root%\bin\w32\7z\7za" l -ba -slt "%root%\jar\%%s" "META-INF\*" > "%root%\META-INF.lst.txt"
  rem http://stackoverflow.com/a/11225757/2334951
  for %%t in ("%root%\META-INF.lst.txt") do if not %%~zt lss 1 (
    echo   Clearing META-INF of %%s ...
    call "%root%\bin\w32\7z\7za" d "%root%\jar\%%s" "META-INF\*" 1> NUL
  )
  del "%root%\META-INF.lst.txt"
)

if not exist "%root%\boardball\icons\empty.png" (
  echo   Downloading empty image...
  mkdir "%root%\boardball\icons" 2> NUL
  call "%root%\bin\w32\gnuwin32\wget" -O "%root%\boardball\icons\empty.png" -q --no-check-certificate https://raw.githubusercontent.com/FUMBBLPlus/boardball/master/images/empty.png 2> NUL

  echo   Adding empty image to FantasyFootballClientResources.jar ...
  cd /D "%root%\boardball"
  call "%root%\bin\w32\7z\7za" a "%root%\jar\FantasyFootballClientResources.jar" "icons\empty.png" 1> NUL
  cd /D "%my_dir%"
)

if not exist "%root%\boardball\icons\cached\pitches\default.zip" (
  echo   Downloading board...
  mkdir "%root%\boardball\icons\cached\pitches" 2> NUL
  call "%root%\bin\w32\gnuwin32\wget" -O "%root%\boardball\icons\cached\pitches\default.zip" -q --no-check-certificate https://github.com/FUMBBLPlus/boardball/releases/download/pitch/boardball.zip 2> NUL

  echo   Replacing board in FantasyFootballClientResources.jar ...
  cd /D "%root%\boardball"
  call "%root%\bin\w32\7z\7za" u "%root%\jar\FantasyFootballClientResources.jar" "icons\cached\pitches\default.zip" 1> NUL
  cd /D "%my_dir%"
)

if not exist "%root%\boardball\client.ini" (
  echo   Extracting client.ini from FantasyFootballClient.jar ...
  mkdir "%root%\boardball" 2> NUL
  call "%root%\bin\w32\7z\7za" e -o"%root%\boardball" "%root%\jar\FantasyFootballClient.jar" "client.ini" 1> NUL

  echo   Removing bloodspots...
  call "%root%\bin\w32\gnuwin32\sed" "s/\(bloodspot.\+=\).\+/\1empty.png/" "%root%\boardball\client.ini" > "%root%\boardball\client.ini.bak"
  del "%root%\boardball\client.ini"
  ren "%root%\boardball\client.ini.bak" "client.ini"

  echo   Replacing modified client.ini in FantasyFootballClient.jar ...
  call "%root%\bin\w32\7z\7za" u "%root%\jar\FantasyFootballClient.jar" "%root%\boardball\client.ini" 1> NUL
)

:setup_registry
echo   Setting up registry...
echo     Register Boardball as an Application...
reg add "HKCU\Software\Classes\Applications\boardball.exe\shell\open\command" /d "\"%root%\boardball.exe\" \"%%1\"" /t REG_SZ /f 1> NUL
set "jnlp_assoc="
for /f "delims=" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jnlp" /s /d /f "boardball.exe" 2^>NUL ^| "%root%\bin\w32\gnuwin32\egrep.exe" -o ".+REG_SZ.+boardball.exe"') do @set jnlp_assoc=%%a
set "mrulist="
for /f "delims=" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jnlp\OpenWithList" /v MRUList 2^>NUL ^| "%root%\bin\w32\gnuwin32\sed.exe" "s/.\+MRUList\s\+REG_SZ\s\+\(\w\+\)/\1/"') do @set mrulist=%%a

if not "%jnlp_assoc%" == "" goto after_jnlp_assoc
echo     Associate Boardball with JNLP files...
rem reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jnlp\OpenWithList" | "%root%\bin\w32\gnuwin32\egrep.exe" -o ".+.exe" | "%root%\bin\w32\gnuwin32\tail.exe" -1 | "%root%\bin\w32\gnuwin32\sed.exe" "s/\s\+\(\w\)\s\+REG_SZ.\+/\1/" > last_jnlp_assoc_char.txt
for /f "delims=" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jnlp\OpenWithList" ^| "%root%\bin\w32\gnuwin32\egrep.exe" -o ".+.exe" ^| "%root%\bin\w32\gnuwin32\tail.exe" -1 ^| "%root%\bin\w32\gnuwin32\sed.exe" "s/\s\+\(\w\)\s\+REG_SZ.\+/\1/"') do @set last_jnlp_assoc_char=%%a
if "%last_jnlp_assoc_char%" == "" goto jnlp_assoc_fail
rem https://groups.google.com/d/msg/alt.msdos.batch.nt/VEruIR4CYCw/vcDWyuBWeR4J
set alpha=abcdefghijklmnopqrstuvwxyz
call set beta=%%alpha:*%last_jnlp_assoc_char%=%%
set jnlp_assoc_char=%beta:~,1%
set "mrulist=%jnlp_assoc_char%%mrulist%"
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
