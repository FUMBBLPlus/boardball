@echo off

set arg_n=0
for %%x in (%*) do set /A arg_n+=1
if not %arg_n% EQU 3 (goto usage)

rem http://www.imagemagick.org/discourse-server/viewtopic.php?p=130379#p130379
convert ^
  %1 ^
  ( +clone ^
    -alpha extract ^
    -blur 0x3 ^
    -level 0,50%% ^
    -background #efcea5 ^
    -alpha Shape ^
    +write g.png ^
  ) ^
  -compose DstOver -composite ^
  %2 ^
  -compose DstOver -composite ^
  %3

goto eof

:usage
echo Usage: glow.bat ^<target^> ^<background^> ^<destination^>
goto eof

:eof
