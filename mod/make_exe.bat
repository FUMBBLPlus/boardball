@echo off
windres luckboard.rc -O coff -o luckboard.res
gcc -o luckboard.exe luckboard.c luckboard.res
