@echo off

set root=%~dp0
set root=%root:~0,-1%
set args=%*

if exist "%root%\jar\FantasyFootballClient.jar" goto parse_args

:prepare
call "%root%\prepare.bat"

:parse_args
set arg_n=0
for %%x in (%args%) do set /A arg_n+=1
if not %arg_n% EQU 1 goto run_ffb_client
if not exist %1 goto run_ffb_client

:parse_jnlp_args
rem TODO: escaping double quotes in team names by doubling them
"%root%\bin\w32\gnuwin32\egrep" -o "<argument>.+?</argument>" %1 | "%root%\bin\w32\gnuwin32\sed" "s/<\/argument>/\n/g" | "%root%\bin\w32\gnuwin32\sed" "s/<argument>\(.\+\)/\"\1\"/" | "%root%\bin\w32\gnuwin32\sed" ":a;N;$!ba;s/\n/ /g" > %root%\args.txt
for /f "delims=" %%v in (%root%\args.txt) do (set "args=%%v")
del %root%\args.txt

:run_ffb_client
java -noverify -cp "%root%/jar/FantasyFootballClient.jar;%root%/jar/*" com.balancedbytes.games.ffb.client.FantasyFootballClient %args%

:end
