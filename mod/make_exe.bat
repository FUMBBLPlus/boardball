@echo off
windres boardball.rc -O coff -o boardball.res
gcc -o boardball.exe boardball.c boardball.res
