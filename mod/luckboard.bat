@echo off
setlocal
set root=%~dp0
set root=%root:~0,-1%
set args=%*

:search_for_java_exe
echo Searching for JAVA.EXE ...
for %%i in (java.exe) do @set "JAVA_EXE=%%~$PATH:i"
if "%JAVA_EXE%" == "" goto java_exe_by_java_home
:java_exe_found
echo JAVA.EXE found: %JAVA_EXE%
goto parse_args

:java_exe_by_java_home
if not "%JAVA_HOME%" == "" goto java_home_set
call "%root%\ensure_java_home.bat"
:java_home_set
set "JAVA_EXE=%JAVA_HOME%\bin\java.exe"
if not exist "%JAVA_EXE%" (
  echo Error. Unable to locate JAVA.EXE.
  exit /B 1
  goto end
)
goto java_exe_found

:parse_args
set arg_n=0
for %%x in (%args%) do set /A arg_n+=1
if not %arg_n% EQU 1 goto run_ffb_client
if not exist %1 goto args_parsed

:parse_jnlp_args
rem TODO: escaping double quotes in team names by doubling them
"%root%\bin\w32\gnuwin32\egrep" -o "<argument>.+?</argument>" %1 | "%root%\bin\w32\gnuwin32\sed" "s/<\/argument>/\n/g" | "%root%\bin\w32\gnuwin32\sed" "s/<argument>\(.\+\)/\"\1\"/" | "%root%\bin\w32\gnuwin32\sed" ":a;N;$!ba;s/\n/ /g" > %root%\args.txt
for /f "delims=" %%v in (%root%\args.txt) do (set "args=%%v")
del %root%\args.txt

:args_parsed
echo FFB Client Arguments: %args%

:run_ffb_client
echo Java ClassPath: "%root%/jar/FantasyFootballClient.jar;%root%/jar/*"
set "main_class=com.balancedbytes.games.ffb.client.FantasyFootballClient"
echo FFB Main Class: %main_class%
"%JAVA_EXE%" -noverify -cp "%root%/jar/FantasyFootballClient.jar;%root%/jar/*" %main_class% %args%
goto end

:end
endlocal
