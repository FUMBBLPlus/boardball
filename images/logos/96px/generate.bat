@echo off

echo adding first symbol overlay...

convert ^( stone.png -crop 128x128+1+1 -resize 96x96 +repage ^) symbol.png -compose Overlay -composite png32:logo.png

echo adding second symbol overlay...

convert logo.png symbol.png -compose Overlay -composite png32:logo.png

echo adding 50 percent symbol over...

convert logo.png ^( symbol.png -alpha set -channel Alpha -evaluate Divide 2 ^) -compose Over -composite png32:logo.png

echo done
