@echo off
for %%f in (Backgrounds\*) do (
echo Processing %%~nf...
rem http://www.imagemagick.org/Usage/canvas/
convert -size 782x452 tile:%%f png24:%%~nf.png
for %%l in (Layers\*) do (
for /F "tokens=1,2,3 delims=&" %%a in ("%%~nl") do (
echo    adding layer %%a with transparency 1/%%b and mode %%c...
convert %%~nf.png ^( %%l -alpha set -channel a -evaluate divide %%b ^) -compose %%c -composite %%~nf.png
)
convert %%~nf.png -crop 780x450+0+0 +repage -type palette -colors 255 %%~nf.png
)
echo Done.
)
