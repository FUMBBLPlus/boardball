@echo off
rem http://stackoverflow.com/a/42358263/2334951
composite -compose Dst_In ^( mask.png -alpha copy ^) %1 -alpha Set PNG32:%1
