@echo off

set arg_n=0
for %%x in (%*) do set /A arg_n+=1
if not %arg_n% EQU 1 (goto usage)

mkdir temp

echo glowing symbol...
call glow.bat %1\symbol.png background.png temp\symbol.png

rem http://stackoverflow.com/a/11005300/2334951
for /f %%A in ('dir /a-d-s-h /b %1\nums ^| find /v /c ""') do set cnt=%%A

echo number of portraits to generate: %cnt%

FOR /L %%n IN (1,1,%cnt%) DO (

echo portrait: %%n

convert temp\symbol.png %1\nums\%%n.png -compose Over -composite PNG32:%1\portraits\%%n.png

echo done
)


rmdir /s /q temp
goto eof

:usage
echo Usage: generate.bat ^<portrait_dir^>
goto eof

:eof
