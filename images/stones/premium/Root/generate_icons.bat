@echo off

mkdir temp

setlocal enableextensions enabledelayedexpansion
set /a stone_num = 1

FOR %%s IN (31-0, 31-1, 31-2, 31-3, 31-4, 31-5, 31-6, 31-7, 31-8, 31-9, 31-10, 31-11) DO (
  set f_stone_num=0!stone_num!
  set f_stone_num=!f_stone_num:~-2!

  convert ..\a_stones\%%s.png a_symbol.png -compose Overlay -composite -define png:format=png32 temp\a!f_stone_num!.png
  convert ..\b_stones\31.png  b_symbol.png -compose Overlay -composite -define png:format=png32 temp\b!f_stone_num!.png

  convert temp\a!f_stone_num!.png a_symbol.png -compose Overlay -composite -define png:format=png32 temp\a!f_stone_num!.png
  convert temp\b!f_stone_num!.png b_symbol.png -compose Overlay -composite -define png:format=png32 temp\b!f_stone_num!.png

  convert temp\a!f_stone_num!.png ^( a_symbol.png -alpha set -channel Alpha -evaluate Divide 2 ^) -compose Over -composite -define png:format=png32 temp\a!f_stone_num!.png

  convert temp\a!f_stone_num!.png -background transparent -gravity southeast -extent 32x32 -define png:format=png32 temp\a!f_stone_num!.png
  convert temp\b!f_stone_num!.png -background transparent -gravity southeast -extent 32x32 -define png:format=png32 temp\b!f_stone_num!.png

  set /a stone_num += 1
)

convert -append -define png:format=png32 temp\a*.png a.png
convert a.png ^( -clone 0 -fill "#FFFF00" -colorize 100%% ^) -compose soft-light -composite an.png
convert -append -define png:format=png32 temp\b*.png b.png
convert b.png ^( -clone 0 -fill "#FFFF00" -colorize 100%% ^) -compose soft-light -composite ban.png

convert +append a.png an.png b.png ban.png icons.png

rmdir /s /q temp
)


