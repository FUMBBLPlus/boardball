@echo off

echo Croping pitch...

convert ..\pitches\Boardball\sente_kaya.png -crop 95x147+43+138 +repage png24:background.png

echo Masking...

rem http://stackoverflow.com/a/42358263/2334951
composite -compose Dst_In ^( mask.png -alpha copy ^) background.png -alpha Set PNG32:background.png

echo Adding border...

convert background.png border.png -compose Over -composite PNG32:background.png

echo Done.
