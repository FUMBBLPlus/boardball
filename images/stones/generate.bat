@echo off

set arg_n=0
for %%x in (%*) do set /A arg_n+=1
if not %arg_n% EQU 1 (goto usage)

rem http://stackoverflow.com/a/11005300/2334951
for /f %%A in ('dir /a-d-s-h /b %1\a_nums ^| find /v /c ""') do set cnt=%%A

echo number of icons to generate: %cnt%

FOR /L %%n IN (1,1,%cnt%) DO (

echo icon: %%n

mkdir temp

setlocal enableextensions enabledelayedexpansion
set /a stone_num = 1

FOR %%s IN (31-0, 31-1, 31-2, 31-3, 31-4, 31-5, 31-6, 31-7, 31-8, 31-9, 31-10, 31-11) DO (

  echo row number: !stone_num!

  set f_stone_num=0!stone_num!
  set f_stone_num=!f_stone_num:~-2!

  echo adding first symbol overlay...

  convert empty\a\%%s.png %1\a_symbol.png -compose Overlay -composite -define png:format=png32 temp\a!f_stone_num!.png
  convert empty\b\31.png  %1\b_symbol.png -compose Overlay -composite -define png:format=png32 temp\b!f_stone_num!.png

  echo adding first number overlay...

  convert temp\a!f_stone_num!.png %1\a_nums\%%n.png -compose Overlay -composite -define png:format=png32 temp\a!f_stone_num!.png
  convert temp\b!f_stone_num!.png %1\b_nums\%%n.png -compose Overlay -composite -define png:format=png32 temp\b!f_stone_num!.png

  echo adding second number overlay...

  convert temp\a!f_stone_num!.png %1\a_symbol.png -compose Overlay -composite -define png:format=png32 temp\a!f_stone_num!.png
  convert temp\b!f_stone_num!.png %1\b_symbol.png -compose Overlay -composite -define png:format=png32 temp\b!f_stone_num!.png

  echo adding second symbol overlay...

  convert temp\a!f_stone_num!.png %1\a_nums\%%n.png -compose Overlay -composite -define png:format=png32 temp\a!f_stone_num!.png
  convert temp\b!f_stone_num!.png %1\b_nums\%%n.png -compose Overlay -composite -define png:format=png32 temp\b!f_stone_num!.png

  echo adding 50 percent symbol over...

  convert temp\a!f_stone_num!.png ^( %1\a_symbol.png -alpha set -channel Alpha -evaluate Divide 2 ^) -compose Over -composite -define png:format=png32 temp\a!f_stone_num!.png

  echo extending to size 32x32...

  convert temp\a!f_stone_num!.png -background transparent -gravity southeast -extent 32x32 +repage -define png:format=png32 temp\a!f_stone_num!.png
  convert temp\b!f_stone_num!.png -background transparent -gravity southeast -extent 32x32 +repage -define png:format=png32 temp\b!f_stone_num!.png

  echo done with row !stone_num!

  set /a stone_num += 1
)

echo appending home icons...
convert -append -define png:format=png32 temp\a*.png %1\a\%%n.png

echo appending selected home icons...
convert %1\a\%%n.png ^( -clone 0 -fill "#FFFF00" -colorize 100%% ^) -compose soft-light -composite %1\an\%%n.png

echo appending away icons...
convert -append -define png:format=png32 temp\b*.png %1\b\%%n.png

echo appending selected away icons...
convert %1\b\%%n.png ^( -clone 0 -fill "#FFFF00" -colorize 100%% ^) -compose soft-light -composite %1\ban\%%n.png

echo appending all four together...

convert +append %1\a\%%n.png %1\an\%%n.png %1\b\%%n.png %1\ban\%%n.png %1\icons\%%n.png

rmdir /s /q temp

echo done
)

endlocal
goto eof

:usage
echo Usage: generate.bat ^<icon_dir^>
goto eof

:eof
