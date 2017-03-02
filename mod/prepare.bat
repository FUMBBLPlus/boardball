@echo off
set my_dir=%cd%
set root=%~dp0
set root=%root:~0,-1%

mkdir "%root%\boardball" 2> NUL
mkdir "%root%\jar" 2> NUL

for %%s IN (^
  FantasyFootballClient.jar^
  ,^
  FantasyFootballClientResources.jar^
  ,^
  jetty-all-8.1.14.v20131031.jar^
  ,^
  jorbis-0.0.17.jar^
  ,^
  tinysound-1.1.1.jar^
  ,^
  tritonus_share.jar^
  ,^
  vorbisspi1.0.3.jar^
  ) DO (^
  if not exist "%root%\jar\%%s" (
    echo Downloading %%s ...
    rem http://stackoverflow.com/a/1459107/2334951
    call "%root%\bin\w32\wget\wget" -O "%root%\jar\%%s" -q --no-check-certificate http://www.fumbbl.com/FFBClient/live/%%s 2> NUL
  )
)

for %%s in (^
  FantasyFootballClient.jar^
  ,^
  FantasyFootballClientResources.jar^
  ) DO (^
  call "%root%\bin\w32\7z\7za" l -ba -slt "%root%\jar\%%s" "META-INF\*" > "%root%\META-INF.lst.txt"
  rem http://stackoverflow.com/a/11225757/2334951
  for %%t in ("%root%\META-INF.lst.txt") do if not %%~zt lss 1 (
    echo Clearing META-INF of %%s ...
    call "%root%\bin\w32\7z\7za" d "%root%\jar\%%s" "META-INF\*" 1> NUL
  )
  del "%root%\META-INF.lst.txt"
)

if not exist "%root%\boardball\icons\empty.png" (
  echo Downloading empty image...
  mkdir "%root%\boardball\icons" 2> NUL
  call "%root%\bin\w32\wget\wget" -O "%root%\boardball\icons\empty.png" -q --no-check-certificate https://raw.githubusercontent.com/FUMBBLPlus/boardball/master/images/portraits/base/Asterisk/nums/1.png 2> NUL

  echo Adding empty image to FantasyFootballClientResources.jar ...
  cd /D "%root%\boardball"
  call "%root%\bin\w32\7z\7za" a "%root%\jar\FantasyFootballClientResources.jar" "icons\empty.png" 1> NUL
  cd /D "%my_dir%"
)

if not exist "%root%\boardball\icons\cached\pitches\default.zip" (
  echo Downloading board...
  mkdir "%root%\boardball\icons\cached\pitches" 2> NUL
  call "%root%\bin\w32\wget\wget" -O "%root%\boardball\icons\cached\pitches\default.zip" -q --no-check-certificate https://github.com/FUMBBLPlus/boardball/releases/download/pitch/boardball.zip 2> NUL

  echo Replacing board in FantasyFootballClientResources.jar ...
  cd /D "%root%\boardball"
  call "%root%\bin\w32\7z\7za" u "%root%\jar\FantasyFootballClientResources.jar" "icons\cached\pitches\default.zip" 1> NUL
  cd /D "%my_dir%"
)

if not exist "%root%\boardball\client.ini" (
  echo Extracting client.ini from FantasyFootballClient.jar ...
  mkdir "%root%\boardball" 2> NUL
  call "%root%\bin\w32\7z\7za" e -o"%root%\boardball" "%root%\jar\FantasyFootballClient.jar" "client.ini" 1> NUL

  echo Removing bloodspots...
  call "%root%\bin\w32\sed\sed" -i.bak "s/\(bloodspot.\+=\).\+/\1empty.png/" "%root%\boardball\client.ini"

  del "%root%\boardball\client.ini.bak"

  echo Replacing modified client.ini in FantasyFootballClient.jar ...
  call "%root%\bin\w32\7z\7za" u "%root%\jar\FantasyFootballClient.jar" "%root%\boardball\client.ini" 1> NUL
)

echo Done.
