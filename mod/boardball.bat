@echo off
setlocal
set root=%~dp0
set root=%root:~0,-1%
set args=%*

:ensure_java_home
if not "%JAVA_HOME%" == "" goto java_home_set
endlocal
call "%root%\ensure_java_home.bat"
IF %ERRORLEVEL% NEQ 0 goto pause_before_end
setlocal
:java_home_set

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
"%JAVA_HOME%\bin\java" -noverify -cp "%root%/jar/FantasyFootballClient.jar;%root%/jar/*" com.balancedbytes.games.ffb.client.FantasyFootballClient %args%
goto end

:pause_before_end
pause

:end
endlocal
